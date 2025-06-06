variable "project" {
  default = "sears-devops"
}

variable "cluster_name" {
  default = "sears-eks-cluster"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet" {
  type    = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "kubernetes_version" {
  default = "1.29"
}

variable "jenkins_vpc_id" {
  default = "vpc-0afac25e9d5f745d9"
}

variable "jenkins_vpc_cidr" {
  default = "172.31.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones to use"
}