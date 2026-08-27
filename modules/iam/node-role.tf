data "aws_iam_policy_document" "node_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node" {
  name                 = local.node_role_name
  description          = "IAM role used by Amazon EKS managed worker nodes."
  assume_role_policy   = data.aws_iam_policy_document.node_assume_role.json
  permissions_boundary = var.permissions_boundary_arn

  tags = merge(
    local.common_tags,
    {
      Role = "eks-node"
    }
  )
}

locals {
  node_managed_policy_arns = {
    worker_node = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    ecr_pull    = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  }
}

resource "aws_iam_role_policy_attachment" "node" {
  for_each = local.node_managed_policy_arns

  role       = aws_iam_role.node.name
  policy_arn = each.value
}