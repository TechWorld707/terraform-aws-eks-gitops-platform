data "aws_iam_policy_document" "pod_identity_assume_role" {
  statement {
    sid    = "AllowEksPodIdentity"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

locals {
  pod_identity_roles = {
    vpc_cni = {
      name = "${local.resource_name}-vpc-cni"
      policy_arn = (
        "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKS_CNI_Policy"
      )
    }

    ebs_csi = {
      name = "${local.resource_name}-ebs-csi"
      policy_arn = (
        "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEBSCSIDriverPolicyV2"
      )
    }
  }
}

resource "aws_iam_role" "pod_identity" {
  for_each = local.pod_identity_roles

  name                 = each.value.name
  description          = "Pod Identity role for ${each.key} on ${var.cluster_name}."
  assume_role_policy   = data.aws_iam_policy_document.pod_identity_assume_role.json
  permissions_boundary = var.permissions_boundary_arn

  tags = merge(
    local.common_tags,
    {
      Addon = each.key
    }
  )
}

resource "aws_iam_role_policy_attachment" "pod_identity" {
  for_each = local.pod_identity_roles

  role       = aws_iam_role.pod_identity[each.key].name
  policy_arn = each.value.policy_arn
}
