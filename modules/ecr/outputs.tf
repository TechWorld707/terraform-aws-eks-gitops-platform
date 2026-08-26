output "repository_names" {
  description = "Map of logical component name to ECR repository name."
  value = {
    for component, repository in aws_ecr_repository.this :
    component => repository.name
  }
}

output "repository_arns" {
  description = "Map of logical component name to ECR repository ARN."
  value = {
    for component, repository in aws_ecr_repository.this :
    component => repository.arn
  }
}

output "repository_urls" {
  description = "Map of logical component name to ECR repository URL."
  value = {
    for component, repository in aws_ecr_repository.this :
    component => repository.repository_url
  }
}

output "registry_id" {
  description = "AWS account registry ID containing the ECR repositories."
  value = one(
    toset([
      for repository in aws_ecr_repository.this :
      repository.registry_id
    ])
  )
}

output "kms_key_arn" {
  description = "ARN of the KMS key encrypting the ECR repositories."
  value       = aws_kms_key.ecr.arn
}

output "kms_alias_name" {
  description = "Alias of the KMS key encrypting the ECR repositories."
  value       = aws_kms_alias.ecr.name
}