data "aws_partition" "current" {}

locals {
  resource_name = "${var.name}-${var.environment}"

  cluster_role_name = "${local.resource_name}-cluster-role"
  node_role_name    = "${local.resource_name}-node-role"

  common_tags = merge(
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "iam"
      Project     = var.name
    },
    var.tags
  )
}