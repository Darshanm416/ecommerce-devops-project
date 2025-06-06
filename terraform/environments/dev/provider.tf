# environments/dev/providers.tf

# Configure the AWS Provider to use the EC2 Instance Profile
provider "aws" {
  region = var.aws_region # Uses the region defined in variables.tf
  # Terraform will automatically use the EC2 Instance Profile attached to your Jenkins server.
}

# Configure the Kubernetes Provider
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.aws_region]
  }
}

# Configure the Helm Provider
provider "helm" {
  kubernetes { # This block tells Helm how to connect to Kubernetes
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.aws_region]
    }
  }
}
