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

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

run "secure_application_repositories" {
  command = plan

  variables {
    name        = "three-tier-eks"
    environment = "dev"
  }

  assert {
    condition     = length(aws_ecr_repository.this) == 2
    error_message = "The module must create backend and frontend repositories."
  }

  assert {
    condition = (
      aws_ecr_repository.this["backend"].name ==
      "three-tier-eks-dev-backend"
    )

    error_message = "The backend repository name is incorrect."
  }

  assert {
    condition = (
      aws_ecr_repository.this["frontend"].name ==
      "three-tier-eks-dev-frontend"
    )

    error_message = "The frontend repository name is incorrect."
  }

  assert {
    condition = alltrue([
      for repository in aws_ecr_repository.this :
      repository.image_tag_mutability == "IMMUTABLE"
    ])

    error_message = "Every ECR repository must use immutable image tags."
  }

  assert {
    condition = alltrue([
      for repository in aws_ecr_repository.this :
      repository.force_delete == false
    ])

    error_message = "ECR repositories must not allow forced deletion by default."
  }

  assert {
    condition = alltrue([
      for repository in aws_ecr_repository.this :
      one(repository.image_scanning_configuration).scan_on_push
    ])

    error_message = "Every ECR repository must scan images on push."
  }

  assert {
    condition = alltrue([
      for repository in aws_ecr_repository.this :
      one(repository.encryption_configuration).encryption_type == "KMS"
    ])

    error_message = "Every ECR repository must use KMS encryption."
  }

  assert {
    condition     = aws_kms_key.ecr.enable_key_rotation
    error_message = "The ECR encryption key must have automatic rotation enabled."
  }

  assert {
    condition = (
      aws_kms_key.ecr.deletion_window_in_days ==
      var.kms_deletion_window_days
    )

    error_message = "The ECR encryption key must use the configured deletion window."
  }

  assert {
    condition = alltrue([
      for lifecycle_policy in aws_ecr_lifecycle_policy.this :
      length(jsondecode(lifecycle_policy.policy).rules) == 2
    ])

    error_message = "Every repository must have both lifecycle cleanup rules."
  }

  assert {
    condition = alltrue([
      for lifecycle_policy in aws_ecr_lifecycle_policy.this :
      jsondecode(lifecycle_policy.policy).rules[0].selection.countNumber ==
      var.untagged_image_retention_days
    ])

    error_message = "The untagged-image lifecycle rule must use the configured retention period."
  }

  assert {
    condition = alltrue([
      for lifecycle_policy in aws_ecr_lifecycle_policy.this :
      jsondecode(lifecycle_policy.policy).rules[1].selection.countNumber ==
      var.maximum_image_count
    ])

    error_message = "The image-count lifecycle rule must use the configured maximum."
  }
}
