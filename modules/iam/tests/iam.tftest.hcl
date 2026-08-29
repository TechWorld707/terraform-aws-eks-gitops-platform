mock_provider "aws" {
  mock_data "aws_partition" {
    defaults = {
      partition  = "aws"
      dns_suffix = "amazonaws.com"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

run "eks_cluster_and_node_roles" {
  command = plan

  variables {
    name        = "three-tier-eks"
    environment = "dev"

    tags = {
      Owner = "platform-engineering"
    }
  }

  assert {
    condition     = aws_iam_role.cluster.name == "three-tier-eks-dev-cluster-role"
    error_message = "The EKS cluster role name is incorrect."
  }

  assert {
    condition     = aws_iam_role.node.name == "three-tier-eks-dev-node-role"
    error_message = "The EKS node role name is incorrect."
  }

  assert {
    condition = anytrue([
      for _, attachment in aws_iam_role_policy_attachment.node :
      attachment.policy_arn ==
      "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
    ])

    error_message = "The node role must have permission to pull images from ECR."
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.node) == 3
    error_message = "The node role must have three required managed policies."
  }

  assert {
    condition = anytrue([
      for _, attachment in aws_iam_role_policy_attachment.node :
      attachment.policy_arn ==
      "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    ])

    error_message = "The node role must use AmazonEKSWorkerNodePolicy."
  }


  assert {
    condition     = aws_iam_role.cluster.tags["Module"] == "iam"
    error_message = "The cluster role must include the IAM module tag."
  }

  assert {
    condition     = aws_iam_role.node.tags["Owner"] == "platform-engineering"
    error_message = "Additional tags must be applied to the node role."
  }

  assert {
    condition     = aws_iam_role.cluster.permissions_boundary == null
    error_message = "A permissions boundary must not be applied by default."
  }

  assert {
    condition     = aws_iam_role.node.permissions_boundary == null
    error_message = "A permissions boundary must not be applied by default."
  }
}