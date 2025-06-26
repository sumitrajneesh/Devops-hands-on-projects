output "db_instance_endpoint" {
  description = "The connection endpoint of the RDS instance."
  value       = aws_db_instance.main.address
}

output "db_instance_port" {
  description = "The port of the RDS instance."
  value       = aws_db_instance.main.port
}

output "db_instance_security_group_id" {
  description = "The ID of the RDS security group."
  value       = aws_security_group.rds_sg.id
}