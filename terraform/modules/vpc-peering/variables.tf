variable "eks_vpc_id" {
  description = "VPC ID of the EKS VPC"
  type        = string
}

variable "jenkins_vpc_id" {
  description = "VPC ID of the Jenkins VPC"
  type        = string
}

variable "eks_vpc_cidr" {
  description = "CIDR block of the EKS VPC"
  type        = string
}

variable "jenkins_vpc_cidr" {
  description = "CIDR block of the Jenkins VPC"
  type        = string
}

variable "eks_private_route_table_ids" {
  description = "List of EKS private route table IDs"
  type        = list(string)
}

variable "eks_public_route_table_ids" {
  description = "List of EKS public route table IDs"
  type        = list(string)
}

variable "project" {
  description = "Project name or tag"
  type        = string
}

variable "jenkins_route_table_ids" {
  description = "List of Jenkins route table IDs (manually passed)"
  type        = list(string)
  default     = []
}
