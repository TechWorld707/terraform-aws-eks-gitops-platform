variable "aws_region" {
  description = "AWS Region containing the development EKS cluster."
  type        = string
  default     = "us-east-1"

  validation {
    condition = can(
      regex(
        "^[a-z]{2}(-gov)?-[a-z]+-[0-9]+$",
        var.aws_region
      )
    )

    error_message = "aws_region must be a valid AWS Region name."
  }
}

variable "project_name" {
  description = "Project name used to identify development add-on resources."
  type        = string
  default     = "three-tier-eks"
}

variable "environment" {
  description = "Deployment environment represented by this Terraform root."
  type        = string
  default     = "dev"

  validation {
    condition     = var.environment == "dev"
    error_message = "The development add-ons root must use environment = dev."
  }
}

variable "foundation_state_bucket" {
  description = "S3 bucket containing the development foundation Terraform state."
  type        = string

  validation {
    condition     = length(var.foundation_state_bucket) >= 3
    error_message = "foundation_state_bucket must contain a valid S3 bucket name."
  }
}

variable "foundation_state_key" {
  description = "S3 object key containing the development foundation Terraform state."
  type        = string
  default     = "eks-gitops/dev/foundation/terraform.tfstate"
}

variable "addon_versions" {
  description = "Optional map of EKS add-on names to explicit versions."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Additional tags applied to development add-on resources."
  type        = map(string)

  default = {
    Owner = "platform-engineering"
  }
}
