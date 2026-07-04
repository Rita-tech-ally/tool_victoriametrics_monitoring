output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID of the created VPC."
}

output "public_subnets" {
  value       = aws_subnet.public[*].id
  description = "List of IDs for the public subnets."
}

output "private_subnets" {
  value       = aws_subnet.private[*].id
  description = "List of IDs for the private subnets."
}