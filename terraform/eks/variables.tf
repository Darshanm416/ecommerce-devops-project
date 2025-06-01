variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev/staging/prod)"
  type        = string
}

variable "eks_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "desired_capacity" {
  description = "EKS node group desired capacity"
  type        = number
}

variable "min_size" {
  description = "EKS node group min size"
  type        = number
}

variable "max_size" {
  description = "EKS node group max size"
  type        = number
}

variable "instance_types" {
  description = "EC2 instance types for worker nodes"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
}
