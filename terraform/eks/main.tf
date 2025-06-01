provider "aws" {
  region = var.region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "${var.environment}-eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = merge(var.tags, {
    Name = "${var.environment}-eks-vpc"
  })
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"

  cluster_name    = var.cluster_name
  cluster_version = var.eks_version
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  eks_managed_node_group_defaults = {
    instance_types = var.instance_types
  }

  eks_managed_node_groups = {
    default_node_group = {
      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_capacity
    }
  }

  tags = merge(var.tags, {
    Name = var.cluster_name
  })
}
