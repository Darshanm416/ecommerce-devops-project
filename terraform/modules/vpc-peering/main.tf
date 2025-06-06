resource "aws_vpc_peering_connection" "jenkins_eks_peer" {
  vpc_id        = var.jenkins_vpc_id
  peer_vpc_id   = var.eks_vpc_id
  auto_accept   = true

  tags = {
    Name = "${var.project}-jenkins-eks-peer"
  }
}

# Route in EKS VPC (both public and private) to Jenkins VPC
resource "aws_route" "eks_private_to_jenkins" {
  count                  = length(var.eks_private_route_table_ids)
  route_table_id         = var.eks_private_route_table_ids[count.index]
  destination_cidr_block = var.jenkins_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.jenkins_eks_peer.id
}

resource "aws_route" "eks_public_to_jenkins" {
  count                  = length(var.eks_public_route_table_ids)
  route_table_id         = var.eks_public_route_table_ids[count.index]
  destination_cidr_block = var.jenkins_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.jenkins_eks_peer.id
}

# OPTIONAL: You can do this only if you have Jenkins route table IDs (you can pass them as a variable)
# Example:
# variable "jenkins_route_table_ids" { type = list(string) }

resource "aws_route" "jenkins_to_eks" {
  count                  = length(var.jenkins_route_table_ids)
  route_table_id         = var.jenkins_route_table_ids[count.index]
  destination_cidr_block = var.eks_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.jenkins_eks_peer.id
}
