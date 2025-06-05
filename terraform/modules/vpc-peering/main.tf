resource "aws_vpc_peering_connection" "this" {
  vpc_id        = var.eks_vpc_id
  peer_vpc_id   = var.jenkins_vpc_id
  auto_accept   = true

  tags = {
    Name = "${var.environment}-vpc-peering"
    Environment = var.environment
  }
}

# 1. Route from EKS VPC Private RTs to Jenkins VPC
# Loop through each EKS private route table ID passed to this module
resource "aws_route" "eks_private_to_jenkins_vpc" {
  count                     = length(var.eks_route_table_ids) # <--- Loop over the list
  route_table_id            = var.eks_route_table_ids[count.index] # <--- Use specific instance from list
  destination_cidr_block    = var.jenkins_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id # Renamed to 'this'
}

# 2. Route from Jenkins VPC's RT to EKS VPC
resource "aws_route" "jenkins_to_eks_vpc" {
  route_table_id            = var.jenkins_route_table_id # Assuming this is a single ID
  destination_cidr_block    = var.eks_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id # Renamed to 'this'
}

# 1. In EKS Cluster's Security Group: Allow inbound HTTPS (443) from Jenkins VPC CIDR
resource "aws_security_group_rule" "eks_cluster_ingress_from_jenkins" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.jenkins_vpc_cidr]
  security_group_id = var.eks_cluster_security_group_id # <--- NOW USING THE VARIABLE
  description       = "Allow Jenkins VPC to EKS API"
}

# In Jenkins Server's Security Group: Allow outbound HTTPS (443) to EKS VPC CIDR
# This will likely need to be passed as a variable to this module
resource "aws_security_group_rule" "jenkins_egress_to_eks_cluster" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp" # Changed from "-1" to specific tcp
  cidr_blocks       = [var.eks_vpc_cidr]
  security_group_id = "sg-0e86dbf3b974d8886" # <--- REPLACE WITH YOUR JENKINS SERVER'S SECURITY GROUP ID (or pass as var)
  description       = "Allow Jenkins to EKS API"
}
