# CI-CD-Project
## Project Overviw:
![](https://github.com/OmarMFathy219/ITI-Final-CI-CD-Project/blob/main/Screenshot/Jenkins%20digram.drawio.png)
Deploy a Python web application on GKE using CI/CD jenkins Pipeline using the following steps and high-level diagram:
1. Implement secure GKE Cliuster
2. Deploy and configure Jenkins on GKE
3. Deploy backend application on GKE using Jenkins pipeline

## Tools:
| Tool | Purpose |
| ------ | ------ |
| [ Google Kubernetes Engine (GKE) ](https://cloud.google.com/kubernetes-engine) | Google Kubernetes Engine (GKE) is a managed, production-ready environment for running containerized applications. |
| [ Jenkins ](https://www.jenkins.io) | Jenkins – an open source automation server which enables developers around the world to reliably build, test, and deploy their software. |
| [ Helm ](https://helm.sh) | Helm helps you manage Kubernetes applications — Helm Charts help you define, install, and upgrade even the most complex Kubernetes application. |
| [ Docker ](https://www.docker.com) | Docker is a set of platform as a service (PaaS) products that use OS-level virtualization to deliver software in containers|
| [ Terraform ](https://www.terraform.io) | Terraform is an open-source infrastructure as code software tool that enables you to safely and predictably create, change, and improve infrastructure. |

## Project Architecture:
![](https://github.com/OmarMFathy219/ITI-Final-CI-CD-Project/blob/main/Screenshot/GCP-Diagram.png)

## First Part: Infrastructure Overview
![1_-yXfoGjebJS0RIwUNzJ6Ig](https://user-images.githubusercontent.com/52250018/199336829-1d104ab7-aa80-4809-9775-b4b3cf8dfea9.png)

- ###  Network Files Consist of :
  - Two subnets one for GKE and another for Bastion Host
  - NAT Gateway 
  - Firewall to allow SSH Connection

- ### GKE Files Consist of:
  - private container cluster resource with authorize networks configuration
  - node pool with count 3 
- ### Bastion File: 
    - for Creating a Private VM to Connect with GKE Cluster

## Secound Part: Build the Infrastructure
### 1. Clone The Repo:
```
git clone hhttps://github.com/OmarMFathy219/ITI-Final-CI-CD-Project.git
```
### 2. Navigate to the Terrafrom Code
> After you clone the code you need to navigate to `terraform` folder to build the infrastructure:
```
cd terraform/
```
#### 3. Initialize Terraform
```
terraform init
```

#### 4. Check Plan
```
terraform plan
```

#### 5. Apply the plan *it will take some time to complete*
```
terraform apply
```
## Third Part: Connect to Private GKE Cluster through Bastion VM
> Now after the Infrastructure built navigate to `Compute Engine` from GCP console then `VM instances` and click the SSH to `private-vm2` to run this commands:
![](https://github.com/OmarMFathy219/ITI-Final-CI-CD-Project/blob/main/Screenshot/VM.png)

### 1. Install Kubectl
```
sudo apt-get install kubectl
```
### 2. Install GKE gcloud auth Plugin
```
sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin
```
### 3. Login with your Credintial
```
gcloud auth login
```
### 4. Set your active Application Default Credentials
> to set your active Application Default Credentials to your account run this commands:
```
gcloud auth application-default login
```
### 5. Connect to GKE Cluster
> Go to `Kubernetes Engine` Page in your `Clusters` tab you will find the `private-cluster`
![](https://github.com/OmarMFathy219/ITI-Final-CI-CD-Project/blob/main/Screenshot/GKE.png)

> Click on the `Action button` "Three dots" then `Connect`, Copy the command and paste it in the `VM SSH window`
```
gcloud container clusters get-credentials private-cluster --zone us-central1-a --project <Your-Project-ID>
```
## 4th Part: Install Jenkins using Helm on GKE Cluster
### 1. Install Helm
```
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```
### 2. Create Namespace to install Jenkins in it
```
pull jenkins with helm
```
### 3. Add Jenkins Repo
```
   helm repo add jenkins https://charts.jenkins.io
   helm repo update
```
### 4. Pull Jenkins with Helm
```
   helm pull --untar jenkins/jenkins
```
### 5. Edit jenkins Chart values.yaml file
```
cd jenkins
vim values.yaml
```
> Replace `ServiceType` value from `ClusterIP` to `LoadBlancer` in Line 129:
```
serviceType: LoadBalancer
```
> Replace `All InstallPlugins` version to latest in line 241
```
installPlugins:
    - kubernetes:latest
    - workflow-aggregator:latest
    - git:latest
    - configuration-as-code:latest
```
> Save the file and go back to the home Driectory
```
cd ..
```
### 6.Now Install Jenkins Chart
```
helm install jenkins ./jenkins -n jenkins
```
### 7. Get `admin` user Password
```
  kubectl exec --namespace jenkins -it svc/jenkins2 -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo
```
### 8. Get the `Jenkins URL`
```
export SERVICE_IP=$(kubectl get svc --namespace jenkins jenkins2 --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
echo http://$SERVICE_IP:8080/login
```
![](https://github.com/OmarMFathy219/ITI-Final-CI-CD-Project/blob/main/Screenshot/jenkins.png)

## 5th Part: Build CI/CD Pipeline using Jenkins
![](https://github.com/OmarMFathy219/ITI-Final-CI-CD-Project/blob/main/Screenshot/Pipeline-Stages.png)

#### Once a commit is made Jenkins will:
- Build image from Dockerfile
- Push image to DockerHub
- Apply deployment for the app based on the image
- Apply LoadBalancer service for the app

### 1. Add Credentials in Jenkins
- #### DockerHub Credentials
> Add your DockerHub Credentials `(Username and Password)` and save the id with this value `DockerHub-Cred`.

- #### Service Account Credentials
> Go to GCP Console and navigate to  `Service accounts` from  `IAM & Admin` page.

![](https://github.com/OmarMFathy219/ITI-Final-CI-CD-Project/blob/main/Screenshot/Service-Account.png)

> Click on your `Service accounts` then click on `KEYS` Tab then `Add Key` then `Create new key`, for `Key type` Select `JSON`

![](https://github.com/OmarMFathy219/ITI-Final-CI-CD-Project/blob/main/Screenshot/Add-New-Key.png)
![](https://github.com/OmarMFathy219/ITI-Final-CI-CD-Project/blob/main/Screenshot/Key-Type.png)

> Now go to Jenkins and Make a New credentials, select `Secret` for `credentials kind` then uplaoad the Service Account you just downloaded.
> NOTE: for `Secret ID` eneter `Service-Account-Cred`.

![](https://github.com/OmarMFathy219/ITI-Final-CI-CD-Project/blob/main/Screenshot/Jenkins-Cred.png)

### 2. Create CI Pipline:
- Pull Code from GitHub
- Build the Application image using Docker
- Push Image to DockerHub
- Trigger CD Pipline to Run

### 3. Create CD Pipline:
- Deploy our Application in GKE

![](https://github.com/OmarMFathy219/ITI-Final-CI-CD-Project/blob/main/Screenshot/Pipeline-Finished.png)

## Final Part: Clean up 💣
```
terraform destroy 
```




