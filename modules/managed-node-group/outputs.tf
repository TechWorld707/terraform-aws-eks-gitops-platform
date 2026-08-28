output "node_group_name" {
  description = "Name of the EKS managed node group."
  value       = aws_eks_node_group.this.node_group_name
}

output "node_group_arn" {
  description = "ARN of the EKS managed node group."
  value       = aws_eks_node_group.this.arn
}

output "node_group_id" {
  description = "ID of the EKS managed node group."
  value       = aws_eks_node_group.this.id
}

output "node_group_status" {
  description = "Current status of the EKS managed node group."
  value       = aws_eks_node_group.this.status
}

output "autoscaling_group_names" {
  description = "Names of the Auto Scaling groups backing the managed node group."

  value = try(
    aws_eks_node_group.this.resources[0].autoscaling_groups[*].name,
    []
  )
}