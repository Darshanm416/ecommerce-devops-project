variable "vpc_cidr" {}
variable "public_subnets" {
  type = list(string)
}
variable "availability_zones" {
  type = list(string)
}
variable "environment" {}
variable "cluster_name" {}
variable "cluster_version" {}
variable "node_instance_types" {
  type = list(string)
}
variable "min_size" {}
variable "max_size" {}
variable "desired_size" {}

