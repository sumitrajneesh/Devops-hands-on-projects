resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-rds-subnet-group"
  subnet_ids = var.private_subnets

  tags = merge(var.tags, {
    Name = "${var.project_name}-rds-subnet-group"
  })
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow inbound access to RDS from EKS worker nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    # Allow access from the EKS worker nodes' security group
    # This assumes the EKS module provides its worker node security group ID
    security_groups = var.eks_worker_security_group_ids
    description = "Allow EKS Worker Nodes to connect to RDS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Egress to anywhere (e.g., for updates, backups)
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-rds-sg"
  })
}


resource "aws_db_instance" "main" {
  allocated_storage    = var.allocated_storage
  storage_type         = "gp2"
  engine               = var.db_engine
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  identifier           = var.identifier
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  port                 = var.db_port
  parameter_group_name = "default.${var.db_engine}${replace(var.db_engine_version, ".", "")}"

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id] # Attach the custom RDS SG
  publicly_accessible    = false # Keep private within VPC
  multi_az               = var.multi_az
  skip_final_snapshot    = true # For dev/test environments, avoid snapshot retention
  copy_tags_to_snapshot  = true

  tags = merge(var.tags, {
    Name = var.identifier
  })
}