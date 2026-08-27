resource "aws_kms_key" "cluster" {
  description             = "KMS key for ${local.cluster_name} Kubernetes secrets."
  deletion_window_in_days = var.kms_deletion_window_days
  enable_key_rotation     = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.cluster_name}-secrets"
    }
  )
}

resource "aws_kms_alias" "cluster" {
  name          = "alias/${local.cluster_name}-secrets"
  target_key_id = aws_kms_key.cluster.key_id
}