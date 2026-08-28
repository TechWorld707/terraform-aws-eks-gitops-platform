resource "aws_eks_node_group" "this" {
  cluster_name    = var.cluster_name
  node_group_name = local.node_group_name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  ami_type       = var.ami_type
  capacity_type  = var.capacity_type
  disk_size      = var.disk_size
  instance_types = var.instance_types

  force_update_version = var.force_update_version

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.minimum_size
    max_size     = var.maximum_size
  }

  update_config {
    max_unavailable = var.maximum_unavailable
  }

  node_repair_config {
    enabled = var.enable_node_repair
  }

  labels = merge(
    {
      environment = var.environment
      node-group  = var.node_group_name
    },
    var.labels
  )

  tags = local.common_tags

  lifecycle {
    ignore_changes = [
      scaling_config[0].desired_size
    ]
  }
}