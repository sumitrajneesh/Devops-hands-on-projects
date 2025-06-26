variable "aws_region" {
  description = "The AWS region to deploy resources to."
  type        = string
  default     = "ap-south-1" # Mumbai region, or choose your preferred region
}

variable "project_name" {
  description = "Name of the project for tagging resources."
  type        = string
  default     = "todo-app"
}

variable "rds_username" {
  description = "Username for the RDS PostgreSQL database."
  type        = string
  default     = "todoappuser"
}

variable "rds_password" {
  description = "Password for the RDS PostgreSQL database."
  type        = string
  sensitive   = true # Mark as sensitive to prevent showing in logs
}

variable "rds_database_name" {
  description = "Name of the database inside PostgreSQL."
  type        = string
  default     = "todoappdb"
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = "todo-eks-cluster"
}

variable "instance_type" {
  description = "EC2 instance type for EKS worker nodes (t3.medium recommended for small clusters)."
  type        = string
  default     = "t3.medium" # t2.micro is free-tier eligible but might be too small for EKS
}

variable "desired_size" {
  description = "Desired number of EKS worker nodes."
  type        = number
  default     = 2 # Start with 2 for basic HA, increase if needed
}

variable "max_size" {
  description = "Maximum number of EKS worker nodes."
  type        = number
  default     = 3
}