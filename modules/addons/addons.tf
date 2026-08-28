resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = var.cluster_name
  addon_name   = "eks-pod-identity-agent"

  addon_version = try(
    var.addon_versions["eks-pod-identity-agent"],
    null
  )

  resolve_conflicts_on_create = var.resolve_conflicts_on_create
  resolve_conflicts_on_update = var.resolve_conflicts_on_update

  tags = local.common_tags
}

locals {
  pod_identity_associations = {
    vpc_cni = {
      namespace       = "kube-system"
      service_account = "aws-node"
      role_key        = "vpc_cni"
    }

    ebs_csi = {
      namespace       = "kube-system"
      service_account = "ebs-csi-controller-sa"
      role_key        = "ebs_csi"
    }
  }
}

resource "aws_eks_pod_identity_association" "this" {
  for_each = local.pod_identity_associations

  cluster_name    = var.cluster_name
  namespace       = each.value.namespace
  service_account = each.value.service_account
  role_arn        = aws_iam_role.pod_identity[each.value.role_key].arn

  depends_on = [
    aws_eks_addon.pod_identity_agent,
    aws_iam_role_policy_attachment.pod_identity
  ]
}

resource "aws_eks_addon" "managed" {
  for_each = local.managed_addons

  cluster_name  = var.cluster_name
  addon_name    = each.value.name
  addon_version = each.value.version

  resolve_conflicts_on_create = var.resolve_conflicts_on_create
  resolve_conflicts_on_update = var.resolve_conflicts_on_update

  tags = local.common_tags

  depends_on = [
    aws_eks_addon.pod_identity_agent,
    aws_eks_pod_identity_association.this
  ]
}
