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

output "load_balancer_controller_role_name" {
  description = "Name of the AWS Load Balancer Controller Pod Identity role."
  value       = aws_iam_role.load_balancer_controller.name
}

output "load_balancer_controller_role_arn" {
  description = "ARN of the AWS Load Balancer Controller Pod Identity role."
  value       = aws_iam_role.load_balancer_controller.arn
}

output "load_balancer_controller_policy_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM policy."
  value       = aws_iam_policy.load_balancer_controller.arn
}

output "load_balancer_controller_association_id" {
  description = "ID of the AWS Load Balancer Controller Pod Identity association."
  value       = aws_eks_pod_identity_association.load_balancer_controller.id
}

output "external_dns_role_name" {
  description = "Name of the ExternalDNS Pod Identity IAM role."
  value       = aws_iam_role.external_dns.name
}

output "external_dns_role_arn" {
  description = "ARN of the ExternalDNS Pod Identity IAM role."
  value       = aws_iam_role.external_dns.arn
}

output "external_dns_policy_arn" {
  description = "ARN of the Route 53 policy assigned to ExternalDNS."
  value       = aws_iam_policy.external_dns.arn
}

output "external_dns_association_id" {
  description = "ID of the ExternalDNS EKS Pod Identity association."
  value       = aws_eks_pod_identity_association.external_dns.association_id
}

output "external_secrets_role_name" {
  description = "Name of the External Secrets Pod Identity IAM role."
  value       = aws_iam_role.external_secrets.name
}

output "external_secrets_role_arn" {
  description = "ARN of the External Secrets Pod Identity IAM role."
  value       = aws_iam_role.external_secrets.arn
}

output "external_secrets_policy_arn" {
  description = "ARN of the External Secrets IAM policy."
  value       = aws_iam_policy.external_secrets.arn
}

output "external_secrets_association_id" {
  description = "ID of the External Secrets EKS Pod Identity association."
  value       = aws_eks_pod_identity_association.external_secrets.association_id
}