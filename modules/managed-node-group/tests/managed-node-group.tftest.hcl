mock_provider "aws" {
  override_during = plan
}

run "secure_general_worker_nodes" {
  command = plan

  variables {
    name            = "three-tier-eks"
    environment     = "dev"
    cluster_name    = "three-tier-eks-dev"
    node_group_name = "general"

    node_role_arn = "arn:aws:iam::123456789012:role/three-tier-eks-dev-node-role"

    subnet_ids = [
      "subnet-0123456789abcdef0",
      "subnet-0123456789abcdef1",
      "subnet-0123456789abcdef2"
    ]

    tags = {
      Owner = "platform-engineering"
    }
  }

  assert {
    condition = (
      aws_eks_node_group.this.node_group_name ==
      "three-tier-eks-dev-general"
    )

    error_message = "The managed node-group name is incorrect."
  }

  assert {
    condition     = aws_eks_node_group.this.cluster_name == var.cluster_name
    error_message = "The managed node group must use the supplied cluster name."
  }

  assert {
    condition     = aws_eks_node_group.this.node_role_arn == var.node_role_arn
    error_message = "The managed node group must use the supplied node IAM role."
  }

  assert {
    condition     = length(aws_eks_node_group.this.subnet_ids) == 3
    error_message = "The managed node group must use all three private subnets."
  }

  assert {
    condition     = aws_eks_node_group.this.capacity_type == "ON_DEMAND"
    error_message = "The node group must use On-Demand capacity by default."
  }

  assert {
    condition = (
      length(aws_eks_node_group.this.instance_types) == 1 &&
      contains(
        aws_eks_node_group.this.instance_types,
        "t3.medium"
      )
    )

    error_message = "The default worker-node instance type is incorrect."
  }

  assert {
    condition = (
      aws_eks_node_group.this.scaling_config[0].min_size == 1 &&
      aws_eks_node_group.this.scaling_config[0].desired_size == 2 &&
      aws_eks_node_group.this.scaling_config[0].max_size == 4
    )

    error_message = "The default scaling configuration is incorrect."
  }

  assert {
    condition = (
      aws_eks_node_group.this.update_config[0].max_unavailable == 1
    )

    error_message = "Updates must allow only one unavailable node."
  }

  assert {
    condition     = aws_eks_node_group.this.node_repair_config[0].enabled
    error_message = "Automatic node repair must be enabled."
  }

  assert {
    condition = (
      aws_eks_node_group.this.labels["environment"] == "dev" &&
      aws_eks_node_group.this.labels["node-group"] == "general"
    )

    error_message = "Required Kubernetes node labels are missing."
  }

  assert {
    condition = (
      aws_eks_node_group.this.tags["Module"] == "managed-node-group" &&
      aws_eks_node_group.this.tags["Owner"] == "platform-engineering"
    )

    error_message = "Required resource tags are missing."
  }
}