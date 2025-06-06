module "vpc" {
  source              = "../../modules/vpc"
  project             = var.project
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "eks" {
  source              = "../../modules/eks"
  project             = var.project
  cluster_name        = var.cluster_name
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  kubernetes_version  = var.kubernetes_version
}

module "vpc_peering" {
  source = "../../modules/vpc-peering"

  project                     = var.project
  eks_vpc_id                  = module.vpc.vpc_id
  eks_vpc_cidr                = var.vpc_cidr
  eks_private_route_table_ids = module.vpc.private_route_table_ids
  eks_public_route_table_ids  = module.vpc.public_route_table_ids

  jenkins_vpc_id              = var.jenkins_vpc_id
  jenkins_vpc_cidr            = var.jenkins_vpc_cidr
  jenkins_route_table_ids     = var.jenkins_route_table_ids
}
