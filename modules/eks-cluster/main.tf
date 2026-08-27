locals {
  cluster_name = "${var.name}-${var.environment}"

  common_tags = merge(
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "eks-cluster"
      Project     = var.name
    },
    var.tags
  )
}