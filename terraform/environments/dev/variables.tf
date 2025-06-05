variable "vpc_cidr" {}
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "availability_zones" { type = list(string) }
variable "cluster_name" {}
variable "cluster_version" {}
variable "environment" {}
variable "jenkins_vpc_id" {
  description = "VPC ID of Jenkins server"
  type        = string
}

variable "jenkins_route_table_id" {
  description = "Route table ID of Jenkins VPC"
  type        = string
}

variable "jenkins_vpc_cidr" {
  description = "CIDR block of Jenkins VPC"
  type        = string
}
