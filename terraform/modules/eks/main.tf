module "eks" {
  source          = "terraform-aws-modules/eks/aws"
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

 # --- ADD THIS BLOCK TO MAP YOUR JENKINS SERVER'S IAM ROLE ---
  # This ensures the IAM Role attached to your Jenkins EC2 instance has 'system:masters' access in Kubernetes
  # 'manage_aws_auth = true' is the default for this module, so no need to explicitly set it unless you changed it.
  map_roles = [
    # Default mapping for EKS worker nodes (usually handled by the module internally, but explicit is good)
    # This might already be implicitly managed by the module's node group configuration,
    # but if you need to ensure the node group role has master access too, you can add it.
    # {
    #   rolearn  = "arn:aws:iam::${var.account_id}:role/your-eks-node-group-role" # Example: Replace with your actual node group role ARN
    #   username = "system:node:{{EC2PrivateDNSName}}"
    #   groups   = ["system:bootstrappers", "system:nodes"]
    # },
    # --- THIS IS THE CRUCIAL ENTRY FOR YOUR JENKINS SERVER'S IAM ROLE ---
    {
      rolearn  = "arn:aws:iam::160885263644:role/jenkins-admin-role" # <--- IMPORTANT: REPLACE THIS WITH YOUR JENKINS SERVER'S IAM ROLE ARN (e.g., from 'aws sts get-caller-identity')
      username = "jenkins-eks-admin" # A logical name for the Kubernetes user associated with this role
      groups   = ["system:masters"] # Grants full admin permissions in Kubernetes for this role
    }
  ]
  # --- END OF ADDED BLOCK ---

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }


}
