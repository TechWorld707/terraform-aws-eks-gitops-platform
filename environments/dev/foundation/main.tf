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