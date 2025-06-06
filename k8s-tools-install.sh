#!/bin/bash

set -e

echo "🚀 Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

echo "✅ kubectl installed."

echo "🚀 Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version

echo "✅ Helm installed."

echo "🚀 Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install
aws --version

echo "✅ AWS CLI installed."

echo "🔐 Configuring kubeconfig for EKS..."
aws eks update-kubeconfig --region <your-region> --name <your-cluster-name>

echo "✅ kubeconfig set."

echo "🎉 Jenkins server is ready for Helm-based CD deployments!"
