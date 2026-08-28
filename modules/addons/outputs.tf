output "addon_names" {
  description = "Map of logical add-on key to EKS add-on name."

  value = merge(
    {
      pod_identity_agent = aws_eks_addon.pod_identity_agent.addon_name
    },
    {
      for key, addon in aws_eks_addon.managed :
      key => addon.addon_name
    }
  )
}

output "addon_arns" {
  description = "Map of logical add-on key to EKS add-on ARN."

  value = merge(
    {
      pod_identity_agent = aws_eks_addon.pod_identity_agent.arn
    },
    {
      for key, addon in aws_eks_addon.managed :
      key => addon.arn
    }
  )
}

output "addon_versions" {
  description = "Map of logical add-on key to installed EKS add-on version."

  value = merge(
    {
      pod_identity_agent = aws_eks_addon.pod_identity_agent.addon_version
    },
    {
      for key, addon in aws_eks_addon.managed :
      key => addon.addon_version
    }
  )
}

output "pod_identity_role_names" {
  description = "Map of add-on key to Pod Identity IAM role name."

  value = {
    for key, role in aws_iam_role.pod_identity :
    key => role.name
  }
}

output "pod_identity_role_arns" {
  description = "Map of add-on key to Pod Identity IAM role ARN."

  value = {
    for key, role in aws_iam_role.pod_identity :
    key => role.arn
  }
}

output "pod_identity_association_ids" {
  description = "Map of add-on key to EKS Pod Identity association ID."

  value = {
    for key, association in aws_eks_pod_identity_association.this :
    key => association.id
  }
}
