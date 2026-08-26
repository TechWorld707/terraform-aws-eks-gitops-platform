data "aws_iam_policy_document" "ecr_kms" {
  #checkov:skip=CKV_AWS_109:KMS key administration is restricted to the current AWS account root principal, which delegates authorization to account IAM policies.
  #checkov:skip=CKV_AWS_111:KMS key administration requires write actions and is restricted to the current AWS account root principal.
  #checkov:skip=CKV_AWS_356:In a KMS key policy, Resource "*" represents only the KMS key to which the policy is attached.

  statement {
    sid    = "EnableAccountAdministration"
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }
}

resource "aws_kms_key" "ecr" {
  description = "Encrypts ECR repositories for ${local.resource_name}"

  deletion_window_in_days = var.kms_deletion_window_days
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.ecr_kms.json

  tags = merge(

    local.common_tags,
    {
      Name = "${local.resource_name}-ecr"
    }
  )
}

resource "aws_kms_alias" "ecr" {
  name          = "alias/${local.resource_name}-ecr"
  target_key_id = aws_kms_key.ecr.key_id
}