output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.main.id
}

output "private_subnets" {
  description = "List of IDs of private subnets."
  value       = aws_subnet.private[*].id
}

output "public_subnets" {
  description = "List of IDs of public subnets."
  value       = aws_subnet.public[*].id
}

output "default_security_group_id" {
  description = "The ID of the default security group for the VPC."
  value       = aws_security_group.default.id
}