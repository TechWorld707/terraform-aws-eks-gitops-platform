data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

locals {
  resource_name = "${var.name}-${var.environment}"

  repositories = {
    for repository_name in var.repository_names :
    repository_name => "${local.resource_name}-${repository_name}"
  }

  common_tags = merge(
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.name
      Module      = "ecr"
    },
    var.tags
  )
}
