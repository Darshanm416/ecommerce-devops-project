output "vpc_peering_connection_id" {
  value = aws_vpc_peering_connection.jenkins_eks_peer.id
}
