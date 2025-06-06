output "vpc_id" {
  value = aws_vpc.eks_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "private_route_table_ids" {
  value = [for rt in aws_route_table.private_rt : rt.id]
}

output "public_route_table_ids" {
  value = [for rt in aws_route_table.public_rt : rt.id]
}
