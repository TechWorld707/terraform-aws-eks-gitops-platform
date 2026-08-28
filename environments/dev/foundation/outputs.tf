output "vpc_id" {
  description = "ID of the development VPC."
  value       = module.network.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block assigned to the development VPC."
  value       = module.network.vpc_cidr_block
}

output "availability_zones" {
  description = "Availability Zones used by the development network."
  value       = module.network.availability_zones
}

output "public_subnet_ids" {
  description = "Ordered public subnet IDs used by internet-facing load balancers and NAT gateways."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Ordered private subnet IDs used by EKS managed nodes and application workloads."
  value       = module.network.private_subnet_ids
}

output "public_route_table_id" {
  description = "ID of the shared public route table."
  value       = module.network.public_route_table_id
}

output "private_route_table_ids" {
  description = "Ordered private route-table IDs."
  value       = module.network.private_route_table_ids
}

output "internet_gateway_id" {
  description = "ID of the development VPC internet gateway."
  value       = module.network.internet_gateway_id
}

output "nat_gateway_ids" {
  description = "Map of Availability Zone to NAT gateway ID."
  value       = module.network.nat_gateway_ids
}

output "nat_gateway_public_ips" {
  description = "Map of Availability Zone to NAT gateway public IP."
  value       = module.network.nat_gateway_public_ips
}

output "flow_log_id" {
  description = "ID of the development VPC Flow Log."
  value       = module.network.flow_log_id
}

output "flow_log_group_name" {
  description = "CloudWatch Logs group receiving development VPC Flow Logs."
  value       = module.network.flow_log_group_name
}

output "flow_log_kms_key_arn" {
  description = "ARN of the KMS key encrypting the VPC Flow Log group."
  value       = module.network.flow_log_kms_key_arn
}

output "s3_gateway_endpoint_id" {
  description = "ID of the S3 gateway endpoint when enabled."
  value       = module.network.s3_gateway_endpoint_id
}

output "interface_endpoint_ids" {
  description = "Map of enabled interface endpoint service names to endpoint IDs."
  value       = module.network.interface_endpoint_ids
}

output "interface_endpoint_security_group_id" {
  description = "ID of the interface endpoint security group when enabled."
  value       = module.network.interface_endpoint_security_group_id
}

output "default_security_group_id" {
  description = "ID of the managed deny-all default VPC security group."
  value       = module.network.default_security_group_id
}

output "ecr_repository_names" {
  description = "Map of application components to ECR repository names."
  value       = module.ecr.repository_names
}

output "ecr_repository_arns" {
  description = "Map of application components to ECR repository ARNs."
  value       = module.ecr.repository_arns
}

output "ecr_repository_urls" {
  description = "Map of application components to ECR repository URLs."
  value       = module.ecr.repository_urls
}

output "ecr_registry_id" {
  description = "AWS account registry ID containing the application repositories."
  value       = module.ecr.registry_id
}

output "ecr_kms_key_arn" {
  description = "ARN of the KMS key encrypting the ECR repositories."
  value       = module.ecr.kms_key_arn
}

output "eks_cluster_role_name" {
  description = "Name of the development EKS cluster IAM role."
  value       = module.iam.cluster_role_name
}

output "eks_cluster_role_arn" {
  description = "ARN of the development EKS cluster IAM role."
  value       = module.iam.cluster_role_arn
}

output "eks_node_role_name" {
  description = "Name of the development EKS worker-node IAM role."
  value       = module.iam.node_role_name
}

output "eks_node_role_arn" {
  description = "ARN of the development EKS worker-node IAM role."
  value       = module.iam.node_role_arn
}

output "eks_cluster_name" {
  description = "Name of the development EKS cluster."
  value       = module.eks_cluster.cluster_name
}

output "eks_cluster_arn" {
  description = "ARN of the development EKS cluster."
  value       = module.eks_cluster.cluster_arn
}

output "eks_cluster_endpoint" {
  description = "Endpoint of the development Kubernetes API server."
  value       = module.eks_cluster.cluster_endpoint
}

output "eks_cluster_certificate_authority_data" {
  description = "Base64-encoded certificate authority data for the development cluster."
  value       = module.eks_cluster.cluster_certificate_authority_data
  sensitive   = true
}

output "eks_cluster_security_group_id" {
  description = "Security group created by EKS for the development cluster."
  value       = module.eks_cluster.cluster_security_group_id
}

output "eks_oidc_issuer_url" {
  description = "OIDC issuer URL used for EKS workload identities."
  value       = module.eks_cluster.oidc_issuer_url
}

output "eks_secrets_kms_key_arn" {
  description = "ARN of the KMS key encrypting Kubernetes secrets."
  value       = module.eks_cluster.kms_key_arn
}

output "eks_node_group_name" {
  description = "Name of the development EKS managed node group."
  value       = module.managed_node_group.node_group_name
}

output "eks_node_group_arn" {
  description = "ARN of the development EKS managed node group."
  value       = module.managed_node_group.node_group_arn
}

output "eks_node_group_status" {
  description = "Status of the development EKS managed node group."
  value       = module.managed_node_group.node_group_status
}

output "eks_node_autoscaling_group_names" {
  description = "Auto Scaling groups backing the development managed node group."
  value       = module.managed_node_group.autoscaling_group_names
}
