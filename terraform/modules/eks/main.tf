# modules/eks/main.tf (Your local wrapper module for EKS)

module "eks_cluster_core" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0" # Specify a version that is known to be stable and supports required features

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = var.vpc_id
  subnet_ids      = var.private_subnet_ids # EKS module expects subnet IDs, not CIDRs

  # Recommended EKS logging for observability
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  eks_managed_node_group_defaults = {
    instance_types = ["t3.medium"]
    ami_type       = "AL2_x86_64" # Amazon Linux 2 AMI is a common choice
    disk_size      = 20           # Default disk size for nodes
    # Add an instance profile name if you have a custom one
    # instance_profile_name = "your-custom-eks-node-instance-profile"
  }

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
      # Ensure node group tags are correct for Kubernetes discovery and ownership
      tags = {
        "kubernetes.io/cluster/${var.cluster_name}" = "owned"
      }
    }
  }

  # --- IMPORTANT: No map_roles argument here ---
  # The 'aws-auth' ConfigMap is managed directly in environments/dev/main.tf
  # using the 'kubernetes_config_map_v1' resource.

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}
