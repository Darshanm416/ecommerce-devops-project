output "cluster_id" {
  description = "The ID of the EKS cluster."
  value       = module.eks_cluster_core.cluster_id # Corrected from module.eks
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks_cluster_core.cluster_endpoint # Corrected from module.eks
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with your cluster."
  value       = module.eks_cluster_core.cluster_certificate_authority_data # Corrected from module.eks
}

output "eks_managed_node_groups_default_iam_role_arn" {
  description = "The ARN of the default EKS managed node group IAM role."
  # This path is correct as it refers to the output of the inner module call
  value       = module.eks_cluster_core.eks_managed_node_groups["default"].iam_role_arn
}