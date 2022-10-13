terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  region     = var.AWS_DEFAULT_REGION
}

data "aws_availability_zones" "available" {}

/*
* Calling modules who create the initial AWS VPC / AWS ELB
* and AWS IAM Roles for Kubernetes Deployment
*/

module "aws-vpc" {
  source = "./modules/vpc"

  aws_cluster_name         = var.aws_cluster_name
  aws_vpc_cidr_block       = var.aws_vpc_cidr_block
  aws_avail_zones          = data.aws_availability_zones.available.names
  aws_cidr_subnets_private = var.aws_cidr_subnets_private
  aws_cidr_subnets_public  = var.aws_cidr_subnets_public
  default_tags             = var.default_tags
}

module "aws-nlb" {
  source = "./modules/nlb"

  aws_cluster_name      = var.aws_cluster_name
  aws_vpc_id            = module.aws-vpc.aws_vpc_id
  aws_avail_zones       = data.aws_availability_zones.available.names
  aws_subnet_ids_public = module.aws-vpc.aws_subnet_ids_public
  aws_nlb_api_port      = var.aws_nlb_api_port
  k8s_secure_api_port   = var.k8s_secure_api_port
  default_tags          = var.default_tags
}

/*
* Create Bastion Instances in AWS
*
*/

resource "aws_instance" "bastion-server" {
  ami                         = "ami-09b18720cb71042df"
  instance_type               = var.aws_bastion_size
  count                       = var.aws_bastion_num
  associate_public_ip_address = true
  subnet_id                   = element(module.aws-vpc.aws_subnet_ids_public, count.index)

  vpc_security_group_ids = module.aws-vpc.aws_security_group
  #user_data  file("")
  key_name = var.AWS_SSH_KEY_NAME
  connection {
        type        = "ssh"
        user        = "ubuntu"
        private_key = file("/root/.ssh/terraform.pem")
        host     = self.public_ip
      }
        provisioner "file" {
                source      = "/root/.ssh/terraform.pem"
                destination = "/home/ubuntu/.ssh/terraform.pem"
      }
        provisioner "file" {
                source      = "/cloud/aws-terraform/k8s_preinstall.sh"
                destination = "/home/ubuntu/k8s_preinstall.sh"
      }
	provisioner "file" {
    		source	    = "/cloud/aws-terraform/inventory/hosts"
		destination = "/home/ubuntu/inventory.ini"
      }
        provisioner "remote-exec" {
                inline = [
                        "sudo ufw disable",
                        "sudo chmod 600 /home/ubuntu/.ssh/terraform.pem",
                        "git clone https://github.com/kubernetes-sigs/kubespray.git",
			"mv /home/ubuntu/k8s_preinstall.sh /home/ubuntu/kubespray/k8s_preinstall.sh",
			"chmod +x /home/ubuntu/kubespray/k8s_preinstall.sh",
        ]
      }
  tags = merge(var.default_tags, tomap({
    Name    = "kubernetes-${var.aws_cluster_name}-bastion-${count.index}"
    Cluster = var.aws_cluster_name
    Role    = "bastion-${var.aws_cluster_name}-${count.index}"
  }))
}

/*
* Create K8s Master and worker nodes and etcd instances
*
*/

resource "aws_instance" "k8s-master" {
  ami           = "ami-09b18720cb71042df"
  instance_type = var.aws_kube_master_size

  count = var.aws_kube_master_num

  subnet_id = element(module.aws-vpc.aws_subnet_ids_private, count.index)

  vpc_security_group_ids = module.aws-vpc.aws_security_group

  root_block_device {
    volume_size = var.aws_kube_master_disk_size
  }

  key_name             = var.AWS_SSH_KEY_NAME
  user_data = <<-EOF
    #!/bin/sh
    echo "<center><h2>TEAM HWARANGHAYO</center></h2>" | sudo tee /home/ubuntu/index.html
    EOF
  tags = merge(var.default_tags, tomap({
    Name                                            = "kubernetes-${var.aws_cluster_name}-master${count.index}"
    "kubernetes.io/cluster/${var.aws_cluster_name}" = "member"
    Role                                            = "master"
  }))
}

resource "aws_lb_target_group_attachment" "tg-attach_worker_nodes" {
  count            = var.aws_kube_worker_num
  target_group_arn = module.aws-nlb.aws_nlb_api_tg_arn
  target_id        = element(aws_instance.k8s-worker.*.private_ip, count.index)
}
resource "aws_instance" "k8s-etcd" {
  ami           = "ami-09b18720cb71042df"
  instance_type = var.aws_etcd_size

  count = var.aws_etcd_num

  subnet_id = element(module.aws-vpc.aws_subnet_ids_private, count.index)

  vpc_security_group_ids = module.aws-vpc.aws_security_group

  root_block_device {
    volume_size = var.aws_etcd_disk_size
  }

  key_name = var.AWS_SSH_KEY_NAME

  tags = merge(var.default_tags, tomap({
    Name                                            = "kubernetes-${var.aws_cluster_name}-etcd${count.index}"
    "kubernetes.io/cluster/${var.aws_cluster_name}" = "member"
    Role                                            = "etcd"
  }))
}

resource "aws_instance" "k8s-worker" {
  ami           = "ami-09b18720cb71042df"
  instance_type = var.aws_kube_worker_size

  count = var.aws_kube_worker_num

  subnet_id = element(module.aws-vpc.aws_subnet_ids_private, count.index)

  vpc_security_group_ids = module.aws-vpc.aws_security_group

  root_block_device {
    volume_size = var.aws_kube_worker_disk_size
  }

  key_name             = var.AWS_SSH_KEY_NAME

  tags = merge(var.default_tags, tomap({
    Name                                            = "kubernetes-${var.aws_cluster_name}-worker${count.index}"
    "kubernetes.io/cluster/${var.aws_cluster_name}" = "member"
    Role                                            = "worker"
  }))
}

/*
* Create Kubespray Inventory File
*
*/
data "template_file" "inventory" {
  template = file("${path.module}/templates/inventory.tpl")

  vars = {
    public_ip_address_bastion = join("\n", formatlist("bastion ansible_host=%s", aws_instance.bastion-server.*.public_ip))
    connection_strings_master = join("\n", formatlist("%s ansible_host=%s", aws_instance.k8s-master.*.private_dns, aws_instance.k8s-master.*.private_ip))
    connection_strings_node   = join("\n", formatlist("%s ansible_host=%s", aws_instance.k8s-worker.*.private_dns, aws_instance.k8s-worker.*.private_ip))
    list_master               = join("\n", aws_instance.k8s-master.*.private_dns)
    list_node                 = join("\n", aws_instance.k8s-worker.*.private_dns)
    connection_strings_etcd   = join("\n", formatlist("%s ansible_host=%s", aws_instance.k8s-etcd.*.private_dns, aws_instance.k8s-etcd.*.private_ip))
    list_etcd                 = join("\n", ((var.aws_etcd_num > 0) ? (aws_instance.k8s-etcd.*.private_dns) : (aws_instance.k8s-master.*.private_dns)))
    nlb_api_fqdn              = "apiserver_loadbalancer_domain_name=\"${module.aws-nlb.aws_nlb_api_fqdn}\""
  }
}

resource "null_resource" "inventories" {
  provisioner "local-exec" {
    command = "echo '${data.template_file.inventory.rendered}' > ${var.inventory_file}"
  }

  triggers = {
    template = data.template_file.inventory.rendered
  }
}
