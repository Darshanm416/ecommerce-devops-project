# modules/vpc-peering/main.tf

# --- VPC Peering Connection ---
resource "aws_vpc_peering_connection" "this" {
  peer_vpc_id   = var.jenkins_vpc_id # The ID of the Jenkins VPC
  vpc_id        = var.eks_vpc_id     # The ID of the EKS VPC
  auto_accept   = true               # Set to true if both VPCs are in the same account/managed by same Terraform

  tags = {
    Name        = "${var.environment}-vpc-peering"
    Environment = var.environment
  }
}

# --- Route Table Updates (Crucial for traffic flow across peered VPCs!) ---

# 1. Route from EKS VPC Private Route Tables to Jenkins VPC
# This adds a route to all private route tables within the EKS VPC,
# allowing traffic from Jenkins to reach EKS resources via private IPs.
resource "aws_route" "eks_private_to_jenkins_vpc" {
  count                     = length(var.eks_private_route_table_ids)
  route_table_id            = var.eks_private_route_table_ids[count.index]
  destination_cidr_block    = var.jenkins_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

# 2. Route from Jenkins VPC's Route Table to EKS VPC
# This adds a route to the specific route table associated with the Jenkins server's subnet,
# allowing Jenkins to reach EKS resources via private IPs.
resource "aws_route" "jenkins_to_eks_vpc" {
  route_table_id            = var.jenkins_route_table_id
  destination_cidr_block    = var.eks_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}


# --- Security Group Rule Updates (Allowing specific traffic across peered VPCs) ---

# 1. In EKS Cluster's Security Group: Allow inbound HTTPS (443) from Jenkins Server's SG
# This allows the Jenkins server to connect to the EKS API endpoint over the peering connection.
resource "aws_security_group_rule" "eks_cluster_ingress_from_jenkins_sg" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = var.jenkins_server_security_group_id # Reference Jenkins SG ID
  security_group_id        = var.eks_cluster_security_group_id    # Reference EKS Cluster SG ID
  description              = "Allow Jenkins Server to EKS API"
}

# 2. In Jenkins Server's Security Group: Allow outbound HTTPS (443) to EKS Cluster SG
# This allows the Jenkins server to initiate connections to the EKS API endpoint.
resource "aws_security_group_rule" "jenkins_egress_to_eks_cluster_sg" {
  type                        = "egress"
  from_port                   = 443
  to_port                     = 443
  protocol                    = "tcp"
  destination_security_group_id = var.eks_cluster_security_group_id # Reference EKS Cluster SG ID
  security_group_id           = var.jenkins_server_security_group_id  # Reference Jenkins Server SG ID
  description                 = "Allow Jenkins to EKS API"
}
