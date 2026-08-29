output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "ARN of the EKS cluster."
  value       = aws_eks_cluster.this.arn
}

output "cluster_id" {
  description = "ID of the EKS cluster."
  value       = aws_eks_cluster.this.id
}

output "cluster_endpoint" {
  description = "Endpoint of the Kubernetes API server."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded certificate authority data for the cluster."
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "Security group created by EKS for the cluster."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "oidc_issuer_url" {
  description = "OpenID Connect issuer URL for the EKS cluster."
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "kms_key_arn" {
  description = "ARN of the KMS key encrypting Kubernetes secrets."
  value       = aws_kms_key.cluster.arn
}

output "kms_alias_name" {
  description = "Alias of the KMS key encrypting Kubernetes secrets."
  value       = aws_kms_alias.cluster.name
}

output "access_entry_principal_arns" {
  description = "Map of access-entry key to IAM principal ARN."

  value = {
    for key, entry in aws_eks_access_entry.this :
    key => entry.principal_arn
  }
}

output "access_policy_arns" {
  description = "Map of access-entry key to associated EKS access policy ARN."

  value = {
    for key, association in aws_eks_access_policy_association.this :
    key => association.policy_arn
  }
}