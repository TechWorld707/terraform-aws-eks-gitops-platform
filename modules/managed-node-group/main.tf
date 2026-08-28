locals {
  node_group_name = "${var.name}-${var.environment}-${var.node_group_name}"

  common_tags = merge(
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "managed-node-group"
      Project     = var.name
    },
    var.tags
  )
}