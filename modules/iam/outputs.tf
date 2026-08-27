output "cluster_role_name" {
  description = "Name of the EKS cluster IAM role."
  value       = aws_iam_role.cluster.name
}

output "cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role."
  value       = aws_iam_role.cluster.arn
}

output "node_role_name" {
  description = "Name of the EKS worker-node IAM role."
  value       = aws_iam_role.node.name
}

output "node_role_arn" {
  description = "ARN of the EKS worker-node IAM role."
  value       = aws_iam_role.node.arn
}