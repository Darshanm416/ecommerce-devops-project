# modules/vpc-peering/variables.tf

variable "eks_vpc_id" {
  description = "The ID of the EKS VPC."
  type        = string
}

variable "jenkins_vpc_id" {
  description = "The ID of the VPC where the Jenkins server resides."
  type        = string
}

variable "eks_private_route_table_ids" {
  description = "List of IDs of the EKS VPC's private route tables."
  type        = list(string)
}

variable "jenkins_route_table_id" {
  description = "ID of the route table associated with the subnet where the Jenkins server resides."
  type        = string
}

variable "eks_vpc_cidr" {
  description = "CIDR block of the EKS VPC."
  type        = string
}

variable "jenkins_vpc_cidr" {
  description = "CIDR block of the Jenkins VPC."
  type        = string
}

variable "eks_cluster_security_group_id" {
  description = "The ID of the EKS cluster's primary security group."
  type        = string
}

variable "jenkins_server_security_group_id" {
  description = "The ID of the security group attached to the Jenkins server's EC2 instance."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}
