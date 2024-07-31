#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Update package lists
sudo apt update -y

# Install OpenJDK 17
sudo apt install openjdk-17-jre openjdk-17-jdk -y
java --version

# Install Jenkins
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io.key | sudo gpg --dearmor -o /usr/share/keyrings/jenkins-keyring.gpg
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] https://pkg.jenkins.io/debian binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update -y
sudo apt install jenkins -y

# Install Docker
sudo apt install docker.io -y
sudo usermod -aG docker jenkins
sudo usermod -aG docker $USER  # Add the current user to the docker group
sudo systemctl restart docker
sudo chmod 660 /var/run/docker.sock  

# Run Docker Container of Portainer
docker run -d \
  -p 9000:9000 \
  --name portainer \
  --restart always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce


# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install

# Install Kubectl
sudo apt install curl -y
curl -LO "https://dl.k8s.io/release/v1.28.4/bin/linux/amd64/kubectl"
sudo chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version

# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
sudo apt update -y
sudo apt install terraform -y

# Install Trivy
sudo apt install wget apt-transport-https gnupg lsb-release -y
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/trivy.list > /dev/null
sudo apt update -y
sudo apt install trivy -y

# Install Helm
sudo snap install helm --classic

echo "--------------------Installing Minikube--------------------"
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

echo "--------------------Installing K9s--------------------"
wget https://github.com/derailed/k9s/releases/download/v0.25.18/k9s_Linux_x86_64.tar.gz
tar -xvzf k9s_Linux_x86_64.tar.gz
sudo install -m 755 k9s /usr/local/bin

echo "--------------------Jenkins Password--------------------"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
