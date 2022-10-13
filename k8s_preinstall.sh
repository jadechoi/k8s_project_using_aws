#!/bin/bash
sudo apt-get update
sudo apt-get install python3-pip -y
sudo pip3 install -r requirements.txt
sudo pip3 install -r contrib/inventory_builder/requirements.txt
cp -rfp inventory/sample inventory/kubecluster
sed -i 's/# kube_read_only_port: 10255/kube_read_only_port: 10255/' /home/ubuntu/kubespray/inventory/kubecluster/group_vars/all/all.yml
sed -i '/bastion/d' /home/ubuntu/inventory.ini
mv /home/ubuntu/inventory.ini /home/ubuntu/kubespray/inventory/kubecluster/inventory.ini

