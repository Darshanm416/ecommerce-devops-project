variable "cluster_name" {}
variable "cluster_version" {}
variable "private_subnets" {
  type = list(string)
}
variable "vpc_id" {}
variable "node_instance_types" {
  type = list(string)
}
variable "min_size" {}
variable "max_size" {}
variable "desired_size" {}
variable "environment" {}
