data "aws_iam_policy_document" "external_dns" {
  statement {
    sid    = "ChangeApprovedHostedZones"
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets"
    ]

    resources = [
      for zone_id in var.external_dns_hosted_zone_ids :
      "arn:${data.aws_partition.current.partition}:route53:::hostedzone/${zone_id}"
    ]
  }

  statement {
    sid    = "DiscoverHostedZones"
    effect = "Allow"

    actions = [
      "route53:GetHostedZone",
      "route53:ListHostedZones",
      "route53:ListHostedZonesByName",
      "route53:ListTagsForResource"
    ]

    resources = ["*"]
  }

  statement {
    sid       = "ReadRoute53Changes"
    effect    = "Allow"
    actions   = ["route53:GetChange"]
    resources = ["arn:${data.aws_partition.current.partition}:route53:::change/*"]
  }
}

resource "aws_iam_policy" "external_dns" {
  name        = "${local.resource_name}-external-dns"
  description = "Scoped Route 53 permissions for ExternalDNS on ${var.cluster_name}."
  policy      = data.aws_iam_policy_document.external_dns.json

  tags = merge(
    local.common_tags,
    {
      Controller = "external-dns"
    }
  )
}

resource "aws_iam_role" "external_dns" {
  name = "${local.resource_name}-external-dns"

  description          = "Pod Identity role for ExternalDNS."
  assume_role_policy   = data.aws_iam_policy_document.pod_identity_assume_role.json
  permissions_boundary = var.permissions_boundary_arn

  tags = merge(
    local.common_tags,
    {
      Controller = "external-dns"
    }
  )
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}

resource "aws_eks_pod_identity_association" "external_dns" {
  cluster_name    = var.cluster_name
  namespace       = "external-dns"
  service_account = "external-dns"
  role_arn        = aws_iam_role.external_dns.arn

  depends_on = [
    aws_iam_role_policy_attachment.external_dns,
    aws_eks_addon.pod_identity_agent
  ]
}