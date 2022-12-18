# Terraform & Ansible을 활용한 Kubernetes Cluster 구성 자동화
Terraform 과 Ansible을 통해 public cloud 환경의 Infra를 각각 구성하고 구성한 인프라 환경에서 Kubernetes Cluster를 구성하는것을 자동화 하는 프로젝트 <br/>  
[데모영상](https://youtu.be/xdSnza5Gf_4)<br/><br/>


## 기술 스택
<img src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=Terraform&logoColor=white"> 
- BE : Django
- FE : HTML, CSS, JS
- Monitoring : Prometheus, Grafana <br/>

## 구현 기능
- 스택
  * 스택 생성
  + 스택 리스트 조회
  + 스택 상세정보 조회
  + 스택 삭제
- 서비스
  * 서비스 리스트 조회
  + 서비스 상세정보 조회
  + 이미지 업데이트
  + 스케일 조정
  + 서비스 롤백
- 네트워크
  * 네트워크 생성
  + 네트워크 리스트 조회
  + 네트워크 상세정보 조회
  + 네트워크 삭제
- 볼륨
  * 볼륨 생성
  + 볼륨 리스트 조회
  + 볼륨 상세정보 조회
  + 볼륨 삭제
- 로그인
  * 도커허브 로그인
- 모니터링
  * 스웜클러스터 노드의 CPU, 메모리 사용량 확인<br/>
  
## 시스템 아키텍처
<img width="985" alt="image" src="https://user-images.githubusercontent.com/96777428/208294660-c069c01e-543c-4338-8ec1-6aaf8287fc2c.png">
