# Terraform & Ansible을 활용한 Kubernetes Cluster 구성 자동화
Terraform 과 Ansible을 통해 public cloud 환경의 Infra를 구성하고 구성한 인프라 환경에서 Kubernetes Cluster를 구성하는것을 자동화 하는 프로젝트 <br/>  
[데모영상](https://youtu.be/xdSnza5Gf_4)<br/><br/>


## 기술 스택
<img src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=Terraform&logoColor=white"> <img src="https://img.shields.io/badge/Ansible-EE0000?style=for-the-badge&logo=Ansible&logoColor=white"> <img src="https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=Kubernetes&logoColor=white"> <img src="https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=Ubuntu&logoColor=white"> <img src="https://img.shields.io/badge/Amazon AWS-232F3E?style=for-the-badge&logo=Amazon AWS&logoColor=white">

## 시스템 아키텍처
![image](https://user-images.githubusercontent.com/96777428/208297063-b6ec8462-6cc4-4b1d-91f3-484c7a668117.png)

## 인프라 구축
- Terraform을 활용하여 AWS 클라우드 인프라 구축 (VPC,LB,EC2)
- Kubernetes Clusterf를 Private Subnet에 구성
- Kubespray를 통해 Kubernetes Cluster 구성 (Ansible 활용)


  
