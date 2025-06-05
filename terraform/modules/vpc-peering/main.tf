resource "aws_vpc_peering_connection" "this" {
  vpc_id        = var.eks_vpc_id
  peer_vpc_id   = var.jenkins_vpc_id
  auto_accept   = true

  tags = {
    Name = "${var.environment}-vpc-peering"
  }
}

resource "aws_route" "eks_to_jenkins" {
  route_table_id         = var.eks_route_table_id
  destination_cidr_block = var.jenkins_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

resource "aws_route" "jenkins_to_eks" {
  route_table_id         = var.jenkins_route_table_id
  destination_cidr_block = var.eks_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}
