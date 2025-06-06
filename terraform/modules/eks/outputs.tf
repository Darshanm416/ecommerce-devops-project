# modules/eks/outputs.tf

output "cluster_id" {
  description = "The ID of the EKS cluster."
  value       = module.eks_cluster_core.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks_cluster_core.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with your cluster."
  value       = module.eks_cluster_core.cluster_certificate_authority_data
}

output "cluster_security_group_id" {
  description = "The ID of the EKS cluster's primary security group."
  value       = module.eks_cluster_core.cluster_security_group_id
}

output "eks_managed_node_groups_default_iam_role_arn" {
  description = "The ARN of the default EKS managed node group IAM role."
  value       = module.eks_cluster_core.eks_managed_node_groups["default"].iam_role_arn
}
