module "network" {
  source = "../../../modules/network"

  name        = var.project_name
  environment = var.environment

  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs

  private_subnet_cidrs = var.private_subnet_cidrs

  single_nat_gateway         = var.single_nat_gateway
  enable_s3_gateway_endpoint = var.enable_s3_gateway_endpoint
  enable_interface_endpoints = var.enable_interface_endpoints
  flow_log_retention_days    = var.flow_log_retention_days

  tags = var.tags
}

module "ecr" {
  source = "../../../modules/ecr"

  name        = var.project_name
  environment = var.environment

  repository_names              = var.ecr_repository_names
  image_tag_mutability          = var.ecr_image_tag_mutability
  scan_on_push                  = var.ecr_scan_on_push
  force_delete                  = var.ecr_force_delete
  untagged_image_retention_days = var.ecr_untagged_image_retention_days
  maximum_image_count           = var.ecr_maximum_image_count
  kms_deletion_window_days      = var.ecr_kms_deletion_window_days

  tags = var.tags
}

module "iam" {
  source = "../../../modules/iam"

  name        = var.project_name
  environment = var.environment

  tags = var.tags
}

module "eks_cluster" {
  source = "../../../modules/eks-cluster"

  name        = var.project_name
  environment = var.environment

  cluster_role_arn   = module.iam.cluster_role_arn
  subnet_ids         = module.network.private_subnet_ids
  kubernetes_version = var.eks_kubernetes_version

  endpoint_private_access = true
  endpoint_public_access  = var.eks_endpoint_public_access
  public_access_cidrs     = var.eks_public_access_cidrs

  bootstrap_cluster_creator_admin_permissions = (
    var.eks_bootstrap_cluster_creator_admin_permissions
  )

  deletion_protection      = var.eks_deletion_protection
  kms_deletion_window_days = var.eks_kms_deletion_window_days

  tags = var.tags

  depends_on = [module.iam]
}

module "managed_node_group" {
  source = "../../../modules/managed-node-group"

  name        = var.project_name
  environment = var.environment

  cluster_name  = module.eks_cluster.cluster_name
  node_role_arn = module.iam.node_role_arn
  subnet_ids    = module.network.private_subnet_ids

  node_group_name = var.node_group_name
  capacity_type   = var.node_capacity_type
  instance_types  = var.node_instance_types
  disk_size       = var.node_disk_size

  minimum_size = var.node_minimum_size
  desired_size = var.node_desired_size
  maximum_size = var.node_maximum_size

  maximum_unavailable = var.node_maximum_unavailable
  enable_node_repair  = var.node_enable_repair

  tags = var.tags

  depends_on = [
    module.iam,
    module.eks_cluster
  ]
}