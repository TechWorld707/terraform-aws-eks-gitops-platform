data "aws_iam_policy_document" "external_secrets" {
  statement {
    sid    = "ReadApprovedSecrets"
    effect = "Allow"

    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue"
    ]

    resources = sort(tolist(var.external_secrets_secret_arns))
  }

  dynamic "statement" {
    for_each = length(var.external_secrets_kms_key_arns) > 0 ? [1] : []

    content {
      sid       = "DecryptApprovedSecretKeys"
      effect    = "Allow"
      actions   = ["kms:Decrypt"]
      resources = sort(tolist(var.external_secrets_kms_key_arns))
    }
  }
}

resource "aws_iam_policy" "external_secrets" {
  name        = "${local.resource_name}-external-secrets"
  description = "Scoped Secrets Manager access for External Secrets Operator."
  policy      = data.aws_iam_policy_document.external_secrets.json

  tags = merge(
    local.common_tags,
    {
      Controller = "external-secrets"
    }
  )
}

resource "aws_iam_role" "external_secrets" {
  name = "${local.resource_name}-external-secrets"

  description          = "Pod Identity role for External Secrets Operator."
  assume_role_policy   = data.aws_iam_policy_document.pod_identity_assume_role.json
  permissions_boundary = var.permissions_boundary_arn

  tags = merge(
    local.common_tags,
    {
      Controller = "external-secrets"
    }
  )
}

resource "aws_iam_role_policy_attachment" "external_secrets" {
  role       = aws_iam_role.external_secrets.name
  policy_arn = aws_iam_policy.external_secrets.arn
}

resource "aws_eks_pod_identity_association" "external_secrets" {
  cluster_name    = var.cluster_name
  namespace       = "external-secrets"
  service_account = "external-secrets"
  role_arn        = aws_iam_role.external_secrets.arn

  depends_on = [
    aws_iam_role_policy_attachment.external_secrets,
    aws_eks_addon.pod_identity_agent
  ]
}