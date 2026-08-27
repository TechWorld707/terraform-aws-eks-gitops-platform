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