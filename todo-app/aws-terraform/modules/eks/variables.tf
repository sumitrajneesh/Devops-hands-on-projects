variable "project_name" {
  description = "Name of the project."
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.29"
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for EKS worker nodes."
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type for EKS worker nodes."
  type        = string
  default     = "t3.medium"
}

variable "desired_size" {
  description = "Desired number of EKS worker nodes."
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of EKS worker nodes."
  type        = number
  default     = 3
}

variable "min_size" {
  description = "Minimum number of EKS worker nodes."
  type        = number
  default     = 1
}

variable "node_disk_size" {
  description = "Disk size for EKS worker nodes in GB."
  type        = number
  default     = 20
}

variable "ami_type" {
  description = "The AMI type to use for the EKS worker nodes."
  type        = string
  default     = "AL2023_x86_64_STANDARD" # Latest Amazon Linux 2023
}

variable "aws_region" {
  description = "The AWS region where resources are deployed."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}