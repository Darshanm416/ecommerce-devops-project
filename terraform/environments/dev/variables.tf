# environments/dev/variables.tf

variable "environment" {
  description = "Deployment environment name (e.g., dev, prod)."
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones for VPC and subnets."
  type        = list(string)
}

# EKS VPC CIDR blocks
variable "eks_vpc_cidr" {
  description = "CIDR block for the EKS VPC."
  type        = string
}

variable "eks_public_subnets" {
  description = "List of public subnet CIDR blocks for EKS VPC."
  type        = list(string)
}

variable "eks_private_subnets" {
  description = "List of private subnet CIDR blocks for EKS VPC."
  type        = list(string)
}

# Jenkins Server VPC Details (REQUIRED for VPC Peering and security group rules)
variable "jenkins_vpc_id" {
  description = "ID of the VPC where the Jenkins server resides."
  type        = string
}

variable "jenkins_vpc_cidr" {
  description = "CIDR block of the VPC where the Jenkins server resides."
  type        = string
}

variable "jenkins_server_subnet_id" {
  description = "ID of the subnet where the Jenkins server's EC2 instance resides."
  type        = string
}

variable "jenkins_server_security_group_id" {
  description = "ID of the security group attached to the Jenkins server's EC2 instance."
  type        = string
}

variable "jenkins_server_role_name" {
  description = "The name of the IAM role attached to the Jenkins EC2 instance."
  type        = string
}

# AWS region (used in kubernetes provider exec block)
variable "aws_region" {
  description = "AWS region for the deployment."
  type        = string
}

# --- APPLICATION-SPECIFIC VARIABLES ---
variable "app_namespace" {
  description = "Kubernetes namespace for the applications."
  type        = string
  default     = "ecommerce"
}

variable "frontend_image_repo" {
  description = "Docker image repository for the frontend application."
  type        = string
  # Example: "yourdockerhub/frontend-app" or "your-account-id.dkr.ecr.your-region.amazonaws.com/frontend-app"
}

variable "frontend_image_tag" {
  description = "Docker image tag for the frontend application."
  type        = string
  default     = "latest"
}

variable "frontend_service_port" {
  description = "Port the frontend service listens on inside the cluster."
  type        = number
  default     = 80
}

variable "frontend_domain_name" {
  description = "Domain name for the frontend application (e.g., 'www.backend.local')."
  type        = string
  default     = "frontend.backend.local"
}

variable "backend_image_repo" {
  description = "Docker image repository for the backend application."
  type        = string
  # Example: "yourdockerhub/backend-app" or "your-account-id.dkr.ecr.your-region.amazonaws.com/backend-app"
}

variable "backend_image_tag" {
  description = "Docker image tag for the backend application."
  type        = string
  default     = "latest"
}

variable "backend_service_port" {
  description = "Port the backend service listens on inside the cluster."
  type        = number
  default     = 5000
}

variable "backend_domain_name" {
  description = "Domain name for the backend application (e.g., 'api.backend.local')."
  type        = string
  default     = "api.backend.local"
}

variable "backend_mongo_url" {
  description = "MongoDB connection URL for the backend."
  type        = string
  default     = "mongodb://mongodb-service:27017/ecommerce"
}
