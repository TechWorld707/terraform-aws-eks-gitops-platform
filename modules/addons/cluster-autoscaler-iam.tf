data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid    = "DescribeScalingResources"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeScalingActivities",
      "autoscaling:DescribeTags",
      "ec2:DescribeImages",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:GetInstanceTypesFromInstanceRequirements",
      "eks:DescribeNodegroup"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ScaleDiscoveredNodeGroups"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/k8s.io/cluster-autoscaler/${var.cluster_name}"
      values   = ["owned"]
    }
  }
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name        = "${local.resource_name}-cluster-autoscaler"
  description = "Scoped permissions for Kubernetes Cluster Autoscaler."
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json

  tags = merge(
    local.common_tags,
    {
      Controller = "cluster-autoscaler"
    }
  )
}

resource "aws_iam_role" "cluster_autoscaler" {
  name = "${local.resource_name}-cluster-autoscaler"

  description          = "Pod Identity role for Kubernetes Cluster Autoscaler."
  assume_role_policy   = data.aws_iam_policy_document.pod_identity_assume_role.json
  permissions_boundary = var.permissions_boundary_arn

  tags = merge(
    local.common_tags,
    {
      Controller = "cluster-autoscaler"
    }
  )
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  role       = aws_iam_role.cluster_autoscaler.name
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
}

resource "aws_eks_pod_identity_association" "cluster_autoscaler" {
  cluster_name    = var.cluster_name
  namespace       = "kube-system"
  service_account = "cluster-autoscaler"
  role_arn        = aws_iam_role.cluster_autoscaler.arn

  depends_on = [
    aws_iam_role_policy_attachment.cluster_autoscaler,
    aws_eks_addon.pod_identity_agent
  ]
}