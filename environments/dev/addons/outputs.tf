output "cluster_name" {
  description = "Name of the EKS cluster receiving the development add-ons."
  value       = data.terraform_remote_state.foundation.outputs.eks_cluster_name
}

output "addon_names" {
  description = "Map of logical add-on key to EKS add-on name."
  value       = module.addons.addon_names
}

output "addon_arns" {
  description = "Map of logical add-on key to EKS add-on ARN."
  value       = module.addons.addon_arns
}

output "addon_versions" {
  description = "Map of logical add-on key to installed EKS add-on version."
  value       = module.addons.addon_versions
}

output "pod_identity_role_names" {
  description = "Map of add-on key to Pod Identity IAM role name."
  value       = module.addons.pod_identity_role_names
}

output "pod_identity_role_arns" {
  description = "Map of add-on key to Pod Identity IAM role ARN."
  value       = module.addons.pod_identity_role_arns
}

output "pod_identity_association_ids" {
  description = "Map of add-on key to EKS Pod Identity association ID."
  value       = module.addons.pod_identity_association_ids
}

output "load_balancer_controller_role_arn" {
  description = "ARN of the AWS Load Balancer Controller Pod Identity role."
  value       = module.addons.load_balancer_controller_role_arn
}

output "load_balancer_controller_policy_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM policy."
  value       = module.addons.load_balancer_controller_policy_arn
}

output "load_balancer_controller_chart_version" {
  description = "Installed AWS Load Balancer Controller Helm chart version."
  value       = helm_release.aws_load_balancer_controller.version
}

output "external_dns_role_name" {
  description = "Name of the ExternalDNS Pod Identity IAM role."
  value       = module.addons.external_dns_role_name
}

output "external_dns_role_arn" {
  description = "ARN of the ExternalDNS Pod Identity IAM role."
  value       = module.addons.external_dns_role_arn
}

output "external_dns_policy_arn" {
  description = "ARN of the Route 53 policy assigned to ExternalDNS."
  value       = module.addons.external_dns_policy_arn
}

output "external_dns_association_id" {
  description = "ID of the ExternalDNS EKS Pod Identity association."
  value       = module.addons.external_dns_association_id
}

output "external_dns_chart_version" {
  description = "Deployed ExternalDNS Helm chart version."
  value       = helm_release.external_dns.version
}