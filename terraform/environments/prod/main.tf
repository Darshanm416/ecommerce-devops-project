module "vpc" {
  source             = "../../modules/vpc"
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  availability_zones = var.availability_zones
  environment        = var.environment
}

module "eks" {
  source             = "../../modules/eks"
  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  private_subnets    = module.vpc.public_subnets  # Use public_subnets if no private here
  vpc_id             = module.vpc.vpc_id
  node_instance_types = var.node_instance_types
  min_size           = var.min_size
  max_size           = var.max_size
  desired_size       = var.desired_size
  environment        = var.environment
}