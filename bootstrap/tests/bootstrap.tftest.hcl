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

run "bootstrap_security_controls" {
  command = plan

  assert {
    condition     = aws_kms_key.terraform_state.enable_key_rotation
    error_message = "The Terraform-state KMS key must have automatic rotation enabled."
  }

  assert {
    condition     = aws_s3_bucket.terraform_state.force_destroy == false
    error_message = "The Terraform-state bucket must not allow force deletion."
  }

  assert {
    condition = (
      aws_s3_bucket_public_access_block.terraform_state.block_public_acls &&
      aws_s3_bucket_public_access_block.terraform_state.block_public_policy &&
      aws_s3_bucket_public_access_block.terraform_state.ignore_public_acls &&
      aws_s3_bucket_public_access_block.terraform_state.restrict_public_buckets
    )

    error_message = "Every S3 public-access-block control must be enabled."
  }

  assert {
    condition = (
      aws_s3_bucket_versioning.terraform_state.versioning_configuration[0].status == "Enabled"
    )

    error_message = "Terraform-state bucket versioning must be enabled."
  }

  assert {
    condition = (
      one(aws_s3_bucket_server_side_encryption_configuration.terraform_state.rule).apply_server_side_encryption_by_default[0].sse_algorithm == "aws:kms"
    )

    error_message = "Terraform state must use AWS KMS encryption."
  }

  assert {
    condition = (
      one(aws_s3_bucket_lifecycle_configuration.terraform_state.rule).noncurrent_version_expiration[0].noncurrent_days == var.state_noncurrent_version_expiration_days
    )

    error_message = "The configured noncurrent state-version retention must be applied."
  }

  assert {
    condition = (
      one(aws_s3_bucket_lifecycle_configuration.terraform_state.rule).abort_incomplete_multipart_upload[0].days_after_initiation == 7
    )

    error_message = "Incomplete multipart uploads must be removed after seven days."
  }
}