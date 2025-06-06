# modules/eks/variables.tf

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the EKS cluster will be deployed."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the EKS cluster nodes."
  type        = list(string)
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}
