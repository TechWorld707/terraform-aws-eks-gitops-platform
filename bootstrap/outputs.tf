output "aws_account_id" {
  description = "AWS account ID containing the Terraform state infrastructure."
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS Region containing the Terraform state infrastructure."
  value       = var.aws_region
}

output "terraform_state_bucket_name" {
  description = "Name of the S3 bucket storing Terraform state."
  value       = aws_s3_bucket.terraform_state.id
}

output "terraform_state_bucket_arn" {
  description = "ARN of the S3 bucket storing Terraform state."
  value       = aws_s3_bucket.terraform_state.arn
}

output "terraform_state_kms_key_arn" {
  description = "ARN of the KMS key encrypting Terraform state."
  value       = aws_kms_key.terraform_state.arn
}

output "terraform_state_kms_alias" {
  description = "Alias of the KMS key encrypting Terraform state."
  value       = aws_kms_alias.terraform_state.name
}

output "foundation_state_key" {
  description = "S3 object key reserved for the development foundation state."
  value       = "eks-gitops/dev/foundation/terraform.tfstate"
}

output "addons_state_key" {
  description = "S3 object key reserved for the development add-ons state."
  value       = "eks-gitops/dev/addons/terraform.tfstate"
}