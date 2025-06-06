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
  description = "List of private route table IDs."
  # Since aws_route_table.private_rt is a single resource, access its ID directly
  # and wrap it in a list to match the `list(string)` type expected by the peering module.
  value = [aws_route_table.private_rt.id]
}

output "public_route_table_ids" {
  description = "List of public route table IDs."
  # Since aws_route_table.public_rt is a single resource, access its ID directly
  # and wrap it in a list to match the `list(string)` type expected by the peering module.
  value = [aws_route_table.public_rt.id]
}
