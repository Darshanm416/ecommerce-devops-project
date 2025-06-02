module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.8.4"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  subnet_ids      = var.private_subnets
  vpc_id          = var.vpc_id

  eks_managed_node_group_defaults = {
    instance_types = var.node_instance_types
  }

  eks_managed_node_groups = {
    default_node_group = {
      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size
    }
  }

  tags = {
    Environment = var.environment
    Project     = "ecommerce"
  }
}
