variable "project_name" {
  description = "Name of the project."
  type        = string
}

variable "identifier" {
  description = "The name of the DB instance."
  type        = string
  default     = "todo-app-db"
}

variable "db_engine" {
  description = "The database engine to use (e.g., 'postgresql')."
  type        = string
  default     = "postgresql"
}

variable "db_engine_version" {
  description = "The database engine version."
  type        = string
  default     = "15.5" # Match your desired version
}

variable "db_instance_class" {
  description = "The instance type of the RDS database."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "The allocated storage in GB."
  type        = number
  default     = 20
}

variable "db_name" {
  description = "The name of the database to create."
  type        = string
}

variable "db_username" {
  description = "Username for the database."
  type        = string
}

variable "db_password" {
  description = "Password for the database."
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "Port for the database."
  type        = number
  default     = 5432
}

variable "multi_az" {
  description = "Specifies if the DB instance is a Multi-AZ deployment."
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for the DB subnet group."
  type        = list(string)
}

variable "eks_worker_security_group_ids" {
  description = "List of Security Group IDs for EKS worker nodes to allow RDS access."
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}