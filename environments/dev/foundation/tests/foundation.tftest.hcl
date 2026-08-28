mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
      arn        = "arn:aws:iam::123456789012:user/terraform-test"
      user_id    = "AIDATEST"
    }
  }

  mock_data "aws_partition" {
    defaults = {
      partition  = "aws"
      dns_suffix = "amazonaws.com"
    }
  }

  mock_data "aws_region" {
    defaults = {
      region = "us-east-1"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

run "development_foundation" {
  command = plan

  assert {
    condition = (
      module.iam.cluster_role_name ==
      "three-tier-eks-dev-cluster-role"
    )

    error_message = "The foundation must create the expected EKS cluster IAM role."
  }

  assert {
    condition = (
      module.iam.node_role_name ==
      "three-tier-eks-dev-node-role"
    )

    error_message = "The foundation must create the expected EKS node IAM role."
  }

  assert {
    condition     = var.eks_kubernetes_version == "1.36"
    error_message = "Development must use Kubernetes 1.36."
  }

  assert {
    condition = (
      module.eks_cluster.cluster_name ==
      "three-tier-eks-dev"
    )

    error_message = "The foundation must create the expected EKS cluster."
  }

  assert {
    condition     = !var.eks_endpoint_public_access
    error_message = "The public Kubernetes API endpoint must remain disabled."
  }

  assert {
    condition     = length(var.eks_public_access_cidrs) == 0
    error_message = "Development must not configure public Kubernetes API CIDRs."
  }

  assert {
    condition     = var.eks_bootstrap_cluster_creator_admin_permissions
    error_message = "Temporary bootstrap administrator access must remain enabled until access entries are implemented."
  }

  assert {
    condition     = !var.eks_deletion_protection
    error_message = "Development EKS deletion protection must remain disabled for teardown."
  }

  assert {
    condition = (
      module.managed_node_group.node_group_name ==
      "three-tier-eks-dev-general"
    )

    error_message = "The foundation must create the expected managed node group."
  }

  assert {
    condition = (
      var.node_capacity_type == "ON_DEMAND" &&
      length(var.node_instance_types) == 1 &&
      contains(var.node_instance_types, "t3.medium")
    )

    error_message = "Development worker nodes must use the expected On-Demand instance configuration."
  }

  assert {
    condition = (
      var.node_minimum_size == 1 &&
      var.node_desired_size == 2 &&
      var.node_maximum_size == 4
    )

    error_message = "Development node-group scaling must use the expected limits."
  }

  assert {
    condition     = var.node_enable_repair
    error_message = "Automatic node repair must remain enabled."
  }

  assert {
    condition     = var.aws_region == "us-east-1"
    error_message = "The development foundation must use us-east-1."
  }

  assert {
    condition     = var.project_name == "three-tier-eks"
    error_message = "The development foundation must use the expected project name."
  }

  assert {
    condition     = var.environment == "dev"
    error_message = "The development foundation must use the dev environment."
  }

  assert {
    condition     = module.network.vpc_cidr_block == "10.20.0.0/16"
    error_message = "The development VPC must use CIDR 10.20.0.0/16."
  }

  assert {
    condition     = var.ecr_repository_names == toset(["backend", "frontend"])
    error_message = "Development must configure backend and frontend ECR repositories."
  }

  assert {
    condition     = var.ecr_image_tag_mutability == "IMMUTABLE"
    error_message = "Development ECR repositories must use immutable image tags."
  }

  assert {
    condition     = var.ecr_scan_on_push
    error_message = "Development ECR repositories must scan images when pushed."
  }

  assert {
    condition     = !var.ecr_force_delete
    error_message = "Development ECR repositories must not allow force deletion."
  }

  assert {
    condition     = var.ecr_untagged_image_retention_days == 7
    error_message = "Development must retain untagged ECR images for seven days."
  }

  assert {
    condition     = var.ecr_maximum_image_count == 30
    error_message = "Development must retain no more than 30 images per ECR repository."
  }

  assert {
    condition     = var.ecr_kms_deletion_window_days == 30
    error_message = "The ECR KMS key must use a 30-day deletion window."
  }

  assert {
    condition     = length(module.ecr.repository_names) == 2
    error_message = "The ECR module must create two application repositories."
  }

  assert {
    condition = (
      contains(keys(module.ecr.repository_names), "backend") &&
      contains(keys(module.ecr.repository_names), "frontend")
    )
    error_message = "The ECR module must expose backend and frontend repositories."
  }

  assert {
    condition     = length(module.network.availability_zones) == 3
    error_message = "The development network must use three Availability Zones."
  }

  assert {
    condition     = length(module.network.public_subnet_ids) == 3
    error_message = "The development network must create three public subnets."
  }

  assert {
    condition     = length(module.network.private_subnet_ids) == 3
    error_message = "The development network must create three private subnets."
  }

  assert {
    condition     = length(module.network.nat_gateway_ids) == 1
    error_message = "Development must use one NAT gateway for cost control."
  }

  assert {
    condition     = var.enable_s3_gateway_endpoint
    error_message = "The free S3 gateway endpoint must be enabled."
  }

  assert {
    condition     = !var.enable_interface_endpoints
    error_message = "Chargeable interface endpoints must remain disabled in development."
  }

  assert {
    condition     = var.flow_log_retention_days == 365
    error_message = "Development VPC Flow Logs must be retained for 365 days."
  }

  assert {
    condition     = length(module.network.interface_endpoint_ids) == 0
    error_message = "Development must not plan chargeable interface endpoints."
  }
}