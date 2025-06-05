module "eks_cluster_core" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 19.0"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = var.vpc_id
  subnet_ids      = var.private_subnets

  eks_managed_node_group_defaults = {
    instance_types = ["t3.medium"]
  }

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }

  map_roles = [
    {
      rolearn  = "arn:aws:iam::160885263644:role/jenkins-admin-role" # <--- REPLACE WITH YOUR ACTUAL JENKINS SERVER'S IAM ROLE ARN
      username = "jenkins-eks-admin"
      groups   = ["system:masters"]
    }
  ]

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }


}
