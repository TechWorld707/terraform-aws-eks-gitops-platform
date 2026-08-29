data "aws_iam_policy_document" "load_balancer_controller" {
  source_policy_documents = [
    file(
      "${path.module}/policies/aws-load-balancer-controller-v2.14.1.json"
    )
  ]
}

resource "aws_iam_policy" "load_balancer_controller" {
  name = "${local.resource_name}-load-balancer-controller"

  description = "Permissions for the AWS Load Balancer Controller on ${var.cluster_name}."
  policy      = data.aws_iam_policy_document.load_balancer_controller.json

  tags = merge(
    local.common_tags,
    {
      Controller = "aws-load-balancer-controller"
    }
  )
}

resource "aws_iam_role" "load_balancer_controller" {
  name = "${local.resource_name}-load-balancer-controller"

  description          = "Pod Identity role for the AWS Load Balancer Controller."
  assume_role_policy   = data.aws_iam_policy_document.pod_identity_assume_role.json
  permissions_boundary = var.permissions_boundary_arn

  tags = merge(
    local.common_tags,
    {
      Controller = "aws-load-balancer-controller"
    }
  )
}

resource "aws_iam_role_policy_attachment" "load_balancer_controller" {
  role       = aws_iam_role.load_balancer_controller.name
  policy_arn = aws_iam_policy.load_balancer_controller.arn
}

resource "aws_eks_pod_identity_association" "load_balancer_controller" {
  cluster_name = var.cluster_name
  namespace    = "kube-system"

  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.load_balancer_controller.arn

  depends_on = [
    aws_iam_role_policy_attachment.load_balancer_controller,
    aws_eks_addon.pod_identity_agent
  ]
}