resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids             = var.private_subnets
    security_group_ids     = [aws_security_group.eks_cluster_sg.id]
    endpoint_private_access = true # Access control plane privately
    endpoint_public_access  = true # Allow public access to control plane (for kubectl from outside VPC)
  }

  tags = merge(var.tags, {
    Name = var.cluster_name
  })

  # Depends on the EKS role and its policy attachments
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.project_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller_policy" {
  # Required for EKS cluster to create/manage VPC resources like ENIs for pods
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}


# --- EKS Worker Node Group (Managed Node Group) ---
resource "aws_iam_role" "eks_node_group_role" {
  name = "${var.project_name}-eks-nodegroup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "ecr_readonly_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = var.private_subnets # Worker nodes typically in private subnets
  instance_types  = [var.instance_type]
  ami_type        = var.ami_type # Example: "AL2_x86_64" or "AL2023_x86_64_STANDARD"
  disk_size       = var.node_disk_size

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable_percentage = 33 # Rolling update config
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-node-group"
  })

  # Depends on the EKS cluster to be active and node group role
  depends_on = [
    aws_eks_cluster.main,
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_readonly_policy,
  ]
}

# --- Security Group for EKS Cluster Control Plane (allows worker nodes to talk to control plane) ---
resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.project_name}-eks-cluster-sg"
  description = "Security group for EKS cluster control plane communication"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 9443 # EKS control plane communicates on this port
    to_port     = 9443
    protocol    = "tcp"
    # Allow access from the EKS worker nodes' security group
    #source_security_group_id = aws_eks_node_group.main.node_group_security_group_id # This SG is created by EKS managed node group
    description = "Allow EKS Worker Nodes to communicate with Control Plane"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-eks-cluster-sg"
  })
}

# --- AWS Load Balancer Controller (Helm Chart) ---
# This is crucial for Ingress to provision AWS ALBs
resource "kubernetes_service_account" "aws_lb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_lb_controller_role.arn
    }
  }
}

resource "aws_iam_role" "aws_lb_controller_role" {
  name = "${var.project_name}-aws-lb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "${module.eks.oidc_provider_arn}"
        }
        Condition = {
          StringEquals = {
            "${replace(module.eks.oidc_provider, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      },
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "aws_lb_controller_policy" {
  name        = "${var.project_name}-aws-lb-controller-policy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy = file("${path.module}/iam_policy_lb_controller.json") # Policy file must be present
  # Download from: https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
}

resource "aws_iam_role_policy_attachment" "aws_lb_controller_attach" {
  role       = aws_iam_role.aws_lb_controller_role.name
  policy_arn = aws_iam_policy.aws_lb_controller_policy.arn
}

resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.6.0" # Check for latest compatible version with your EKS cluster
  depends_on = [
    aws_eks_node_group.main,
    kubernetes_service_account.aws_lb_controller,
    aws_iam_role_policy_attachment.aws_lb_controller_attach,
  ]

  set {
    name  = "clusterName"
    value = var.cluster_name
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.aws_lb_controller.metadata[0].name
  }
  set {
    name = "region"
    value = var.aws_region
  }
  set {
    name = "vpcId"
    value = var.vpc_id
  }
}