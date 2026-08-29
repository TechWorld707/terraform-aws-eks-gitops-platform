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
