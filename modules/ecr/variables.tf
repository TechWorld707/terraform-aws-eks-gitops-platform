variable "name" {
  description = "Name prefix applied to ECR resources."
  type        = string

  validation {
    condition = can(
      regex(
        "^[a-z0-9][a-z0-9-]{1,30}[a-z0-9]$",
        var.name
      )
    )

    error_message = "name must contain 3-32 lowercase letters, numbers or hyphens."
  }
}

variable "environment" {
  description = "Deployment environment, such as dev, staging or production."
  type        = string

  validation {
    condition = contains(
      ["dev", "staging", "production"],
      var.environment
    )

    error_message = "environment must be dev, staging or production."
  }
}

variable "repository_names" {
  description = "Logical names of the application container repositories."
  type        = set(string)

  default = [
    "backend",
    "frontend"
  ]

  validation {
    condition = (
      length(var.repository_names) > 0 &&
      alltrue([
        for repository_name in var.repository_names :
        can(
          regex(
            "^[a-z0-9][a-z0-9._-]{1,126}[a-z0-9]$",
            repository_name
          )
        )
      ])
    )

    error_message = "repository_names must contain valid lowercase ECR repository name components."
  }
}

variable "image_tag_mutability" {
  description = "Image-tag mutability setting applied to each ECR repository."
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition = contains(
      ["IMMUTABLE", "MUTABLE"],
      var.image_tag_mutability
    )

    error_message = "image_tag_mutability must be IMMUTABLE or MUTABLE."
  }
}

variable "scan_on_push" {
  description = "Enable ECR image vulnerability scanning when an image is pushed."
  type        = bool
  default     = true
}

variable "force_delete" {
  description = "Allow repositories to be deleted while they still contain images."
  type        = bool
  default     = false
}

variable "untagged_image_retention_days" {
  description = "Number of days untagged images are retained."
  type        = number
  default     = 7

  validation {
    condition = (
      var.untagged_image_retention_days >= 1 &&
      var.untagged_image_retention_days <= 30
    )

    error_message = "untagged_image_retention_days must be between 1 and 30."
  }
}

variable "maximum_image_count" {
  description = "Maximum number of images retained in each repository."
  type        = number
  default     = 30

  validation {
    condition = (
      var.maximum_image_count >= 10 &&
      var.maximum_image_count <= 500
    )

    error_message = "maximum_image_count must be between 10 and 500."
  }
}

variable "kms_deletion_window_days" {
  description = "Waiting period before deletion of the ECR KMS key."
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

variable "tags" {
  description = "Additional tags applied to ECR resources."
  type        = map(string)
  default     = {}
}