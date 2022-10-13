#Global Vars
aws_cluster_name = "devtest"

#VPC Vars
aws_vpc_cidr_block       = "10.250.192.0/18"
aws_cidr_subnets_private = ["10.250.192.0/20"]
aws_cidr_subnets_public  = ["10.250.224.0/20"]

#Bastion Host
aws_bastion_num  = 1
aws_bastion_size = "t2.small"

#Kubernetes Cluster
aws_kube_master_num       = 1
aws_kube_master_size      = "t2.medium"
aws_kube_master_disk_size = 50

aws_etcd_num       = 0
aws_etcd_size      = "t2.medium"
aws_etcd_disk_size = 50

aws_kube_worker_num       = 3
aws_kube_worker_size      = "t2.medium"
aws_kube_worker_disk_size = 50

#Settings AWS ELB
aws_nlb_api_port    = 80
k8s_secure_api_port = 80

default_tags = {
  #  Env = "devtest"
  #  Product = "kubernetes"
}

#Create inventory file 
inventory_file = "/cloud/aws-terraform/inventory/hosts"
