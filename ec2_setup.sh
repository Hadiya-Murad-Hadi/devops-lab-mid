#!/usr/bin/env bash
# Run ONCE on a fresh Ubuntu 22.04 EC2 (t2.medium+):  bash ec2_setup.sh
set -euo pipefail

sudo apt-get update -y
sudo apt-get install -y docker.io git curl python3 python3-pip python3-venv fontconfig openjdk-17-jre

# Jenkins (official stable repo)
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  | sudo tee /etc/apt/sources.list.d/jenkins.list >/dev/null
sudo apt-get update -y
sudo apt-get install -y jenkins

# Let Jenkins run docker
sudo usermod -aG docker jenkins
sudo systemctl enable --now docker
sudo systemctl restart jenkins

# 2 GB swap so training + docker build don't OOM on small instances
if ! swapon --show | grep -q swapfile; then
  sudo fallocate -l 2G /swapfile && sudo chmod 600 /swapfile
  sudo mkswap /swapfile && sudo swapon /swapfile
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab >/dev/null
fi

echo; echo "Jenkins initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "Open http://<EC2-ELASTIC-IP>:8080"
