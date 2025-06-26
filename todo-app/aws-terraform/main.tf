provider "aws" {
  region = var.aws_region
}

# --- VPC Module ---
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.0.0" # Use a specific version

  name = "${var.project_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"] # Use 2 AZs for basic HA
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true # Single NAT Gateway for cost-effectiveness
  enable_dns_hostnames   = true
  enable_dns_support     = true

  tags = {
    Environment = "Dev"
    Project     = var.project_name
  }
}

# --- RDS Module ---
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.0.0" # Use a specific version

  identifier = "${var.project_name}-db"
  engine     = "postgresql"
  engine_version = "15.5" # Match your desired version
  instance_class = "db.t3.micro" # Free tier eligible, but check latest eligibility
  allocated_storage = 20 # Minimum for free tier
  db_name    = var.rds_database_name
  username   = var.rds_username
  password   = var.rds_password
  port       = 5432

  multi_az                = false # Set to true for production (higher cost)
  publicly_accessible     = false
  create_db_subnet_group  = true
  vpc_security_group_ids  = [module.vpc.default_security_group_id] # Temporarily for simplicity, refine later

  # This creates a dedicated security group for RDS and allows access from VPC CIDR
  # In a real scenario, you'd limit this to specific security groups (e.g., EKS worker nodes SG)
  # to_port: 5432 # Default PostgreSQL port
  # from_port: 5432
  # ingress_cidr_blocks: ["10.0.0.0/16"] # Allow access from within the VPC

  tags = {
    Environment = "Dev"
    Project     = var.project_name
  }
}

# --- EKS Cluster Module ---
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "20.0.0" # Use a specific version

  cluster_name    = var.cluster_name
  cluster_version = "1.29" # Match your desired K8s version

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets # EKS control plane network interfaces

  # EKS Managed Node Groups
  eks_managed_node_groups = {
    main = {
      desired_size = var.desired_size
      max_size     = var.max_size
      min_size     = 1 # Keep at least one node
      instance_types = [var.instance_type]
      # Set AMI type to AL2023 for latest Amazon Linux 2023 optimized AMI
      ami_type       = "AL2023_x86_64_STANDARD"
      # Adding a public IP allows nodes to pull images from ECR without NAT Gateway for ECR VPC endpoint
      # In private subnets, NAT Gateway is required for internet access, or VPC endpoints
      # For simplicity, if your subnets are truly private, ensure NAT Gateway is configured and working.
      # If you set worker nodes in public subnets, you could enable public IP, but it's less secure.
      # Ideally, worker nodes in private subnets, and ECR VPC endpoint for image pull.
      enable_monitoring = true
    }
  }

  tags = {
    Environment = "Dev"
    Project     = var.project_name
  }
}

# --- ECR Repositories ---
resource "aws_ecr_repository" "frontend_repo" {
  name = "${var.project_name}-frontend"
  image_tag_mutability = "MUTABLE" # Or "IMMUTABLE" for stricter policies

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "Dev"
    Project     = var.project_name
  }
}

resource "aws_ecr_repository" "backend_repo" {
  name = "${var.project_name}-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "Dev"
    Project     = var.project_name
  }
}