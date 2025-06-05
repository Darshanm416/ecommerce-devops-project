output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

# modules/vpc/outputs.tf

output "public_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = aws_subnet.public[*].id # This exports the IDs of all public subnets created by the module
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}