variable "eks_vpc_id" {
  description = "VPC ID of EKS cluster"
  type        = string
}

variable "jenkins_vpc_id" {
  description = "VPC ID of Jenkins server"
  type        = string
}

variable "eks_route_table_id" {
  description = "Route Table ID of EKS VPC"
  type        = string
}

variable "jenkins_route_table_id" {
  description = "Route Table ID of Jenkins VPC"
  type        = string
}

variable "eks_vpc_cidr" {
  description = "CIDR block of EKS VPC"
  type        = string
}

variable "jenkins_vpc_cidr" {
  description = "CIDR block of Jenkins VPC"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}
