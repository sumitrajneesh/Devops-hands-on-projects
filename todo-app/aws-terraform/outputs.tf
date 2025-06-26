output "eks_cluster_name" {
  description = "Name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "eks_kubeconfig" {
  description = "Kubernetes config for connecting to the EKS cluster."
  value       = module.eks.kubeconfig
  sensitive   = true
}

output "rds_endpoint" {
  description = "RDS PostgreSQL database endpoint."
  value       = module.rds.db_instance_endpoint
}

output "frontend_ingress_hostname" {
  description = "Hostname of the Ingress for the React frontend."
  value       = "You will need to get this from `kubectl get ingress` after apply" # ALB hostname will be here
}

output "ecr_frontend_repo_url" {
  description = "URL of the ECR repository for the React frontend."
  value       = aws_ecr_repository.frontend_repo.repository_url
}

output "ecr_backend_repo_url" {
  description = "URL of the ECR repository for the Spring Boot backend."
  value       = aws_ecr_repository.backend_repo.repository_url
}