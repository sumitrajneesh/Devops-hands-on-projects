variable "project_name" {
  description = "Name of the project."
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets_cidrs" {
  description = "A list of CIDR blocks for the public subnets."
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "private_subnets_cidrs" {
  description = "A list of CIDR blocks for the private subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "azs" {
  description = "A list of availability zones to use for subnets."
  type        = list(string)
  # IMPORTANT: Adjust this based on the AWS region you are using.
  # Example for us-east-1: ["us-east-1a", "us-east-1b"]
  # Example for ap-south-1: ["ap-south-1a", "ap-south-1b"]
  # You should get this dynamically or hardcode for your region.
  # For Kolkata, ap-south-1 is correct.
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "single_nat_gateway" {
  description = "Whether to deploy a single NAT Gateway (true) or one per AZ (false)."
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "Name of the EKS cluster (used for Kubernetes tags on subnets)."
  type        = string
}