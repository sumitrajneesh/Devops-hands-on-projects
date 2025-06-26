output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = aws_eks_cluster.main.name
}

output "kubeconfig" {
  description = "The raw kubeconfig for the cluster."
  value = <<-EOT
    apiVersion: v1
    clusters:
    - cluster:
        server: ${aws_eks_cluster.main.endpoint}
        certificate-authority-data: ${aws_eks_cluster.main.certificate_authority[0].data}
      name: ${aws_eks_cluster.main.name}
    contexts:
    - context:
        cluster: ${aws_eks_cluster.main.name}
        user: aws
      name: ${aws_eks_cluster.main.name}
    current-context: ${aws_eks_cluster.main.name}
    kind: Config
    preferences: {}
    users:
    - name: aws
      user:
        exec:
          apiVersion: client.authentication.k8s.io/v1beta1
          command: aws
          args:
            - "eks"
            - "get-token"
            - "--cluster-name"
            - "${aws_eks_cluster.main.name}"
            - "--region"
            - "${var.aws_region}"
          env:
            - name: AWS_PROFILE
              value: "${var.aws_profile_name}" # You might need to set this if using named profiles
    EOT
  sensitive = true
}

output "oidc_provider" {
  description = "The URL of the OIDC identity provider for the cluster."
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC identity provider for the cluster."
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "cluster_security_group_id" {
  description = "The ID of the EKS cluster security group."
  value       = aws_security_group.eks_cluster_sg.id
}

output "node_group_security_group_id" {
  description = "The ID of the security group attached to the EKS worker nodes."
  value       = aws_eks_node_group.main.node_group_security_group_id
}

# OIDC Provider resource for IAM Roles for Service Accounts (IRSA)
resource "aws_iam_openid_connect_provider" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    # Get the thumbprint by running:
    # openssl s_client -servername <OIDC_URL_HOST> -showcerts -connect <OIDC_URL_HOST>:443 < /dev/null 2>/dev/null | openssl x509 -fingerprint -noout
    # Replace <OIDC_URL_HOST> with the host part of aws_eks_cluster.main.identity[0].oidc[0].issuer
    # For example, if issuer is "https://oidc.eks.us-east-1.amazonaws.com/id/ABCD1234EFG", the host is "oidc.eks.us-east-1.amazonaws.com"
    # This might need to be retrieved after EKS cluster creation if it changes.
    # A common public thumbprint for Amazon's OIDC is "9157D0D97491C650A2000A13B01A27FADF053F0F" (but verify!)
    "9157D0D97491C650A2000A13B01A27FADF053F0F"
  ]
}