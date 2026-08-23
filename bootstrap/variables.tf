variable "aws_region" {
  description = "AWS Region used for the Terraform remote-state infrastructure."
  type        = string
  default     = "us-east-1"

  validation {
    condition = can(
      regex(
        "^[a-z]{2}(-[a-z]+)+-[0-9]+$",
        var.aws_region
      )
    )

    error_message = "aws_region must be a valid AWS Region name."
  }
}

variable "project_name" {
  description = "Project identifier used when naming bootstrap resources."
  type        = string
  default     = "eks-gitops-platform"

  validation {
    condition = (
      length(var.project_name) >= 3 &&
      length(var.project_name) <= 32 &&
      can(regex("^[a-z0-9-]+$", var.project_name))
    )

    error_message = "project_name must contain 3-32 lowercase letters, numbers or hyphens."
  }
}

variable "kms_deletion_window_days" {
  description = "Waiting period before permanent deletion of the Terraform-state KMS key."
  type        = number
  default     = 30

  validation {
    condition = (
      var.kms_deletion_window_days >= 7 &&
      var.kms_deletion_window_days <= 30
    )

    error_message = "kms_deletion_window_days must be between 7 and 30."
  }
}

variable "state_noncurrent_version_expiration_days" {
  description = "Days retained for noncurrent Terraform state object versions."
  type        = number
  default     = 365

  validation {
    condition = (
      var.state_noncurrent_version_expiration_days >= 30 &&
      var.state_noncurrent_version_expiration_days <= 3650
    )

    error_message = "state_noncurrent_version_expiration_days must be between 30 and 3650."
  }
}

variable "tags" {
  description = "Additional tags applied to bootstrap resources."
  type        = map(string)
  default     = {}
}
