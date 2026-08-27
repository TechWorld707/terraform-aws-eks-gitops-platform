resource "aws_eks_cluster" "this" {
  name     = local.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  enabled_cluster_log_types = var.enabled_cluster_log_types
  deletion_protection       = var.deletion_protection

  access_config {
    authentication_mode                         = var.authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.bootstrap_cluster_creator_admin_permissions
  }

  vpc_config {
    subnet_ids = var.subnet_ids

    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  encryption_config {
    resources = ["secrets"]

    provider {
      key_arn = aws_kms_key.cluster.arn
    }
  }

  tags = local.common_tags
}