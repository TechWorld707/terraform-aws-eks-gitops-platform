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

variable "load_balancer_controller_chart_version" {
  description = "Pinned Helm chart version for the AWS Load Balancer Controller."
  type        = string
  default     = "1.14.0"

  validation {
    condition = can(
      regex(
        "^[0-9]+\\.[0-9]+\\.[0-9]+$",
        var.load_balancer_controller_chart_version
      )
    )

    error_message = "load_balancer_controller_chart_version must use semantic version format."
  }
}

variable "load_balancer_controller_replicas" {
  description = "Number of AWS Load Balancer Controller replicas."
  type        = number
  default     = 2

  validation {
    condition     = var.load_balancer_controller_replicas >= 2
    error_message = "At least two controller replicas are required for availability."
  }
}

variable "external_dns_hosted_zone_ids" {
  description = "Route 53 hosted-zone IDs ExternalDNS may modify."
  type        = set(string)

  validation {
    condition = (
      length(var.external_dns_hosted_zone_ids) > 0 &&
      alltrue([
        for zone_id in var.external_dns_hosted_zone_ids :
        can(regex("^Z[A-Z0-9]+$", zone_id))
      ])
    )

    error_message = "external_dns_hosted_zone_ids must contain at least one valid Route 53 hosted-zone ID."
  }
}

variable "external_dns_domain_filters" {
  description = "DNS domains ExternalDNS is permitted to manage."
  type        = set(string)

  validation {
    condition = (
      length(var.external_dns_domain_filters) > 0 &&
      alltrue([
        for domain in var.external_dns_domain_filters :
        can(regex(
          "^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+$",
          domain
        ))
      ])
    )

    error_message = "external_dns_domain_filters must contain at least one valid DNS domain."
  }
}

variable "external_dns_chart_version" {
  description = "Pinned official ExternalDNS Helm chart version."
  type        = string
  default     = "1.21.1"

  validation {
    condition = can(
      regex(
        "^[0-9]+\\.[0-9]+\\.[0-9]+$",
        var.external_dns_chart_version
      )
    )

    error_message = "external_dns_chart_version must use semantic version format."
  }
}

variable "external_dns_policy" {
  description = "ExternalDNS record-management policy."
  type        = string
  default     = "upsert-only"

  validation {
    condition = contains(
      ["create-only", "upsert-only", "sync"],
      var.external_dns_policy
    )

    error_message = "external_dns_policy must be create-only, upsert-only or sync."
  }
}

variable "external_dns_txt_owner_id" {
  description = "Unique owner ID stored in ExternalDNS TXT ownership records."
  type        = string
  default     = "three-tier-eks-dev"

  validation {
    condition     = length(var.external_dns_txt_owner_id) > 0
    error_message = "external_dns_txt_owner_id must not be empty."
  }
}

variable "external_secrets_secret_arns" {
  description = "Secrets Manager secret ARNs External Secrets Operator may read."
  type        = set(string)

  validation {
    condition = (
      length(var.external_secrets_secret_arns) > 0 &&
      alltrue([
        for secret_arn in var.external_secrets_secret_arns :
        can(regex(
          "^arn:[^:]+:secretsmanager:[^:]+:[0-9]{12}:secret:.+$",
          secret_arn
        ))
      ])
    )

    error_message = "external_secrets_secret_arns must contain at least one valid Secrets Manager secret ARN."
  }
}

variable "external_secrets_kms_key_arns" {
  description = "Customer-managed KMS key ARNs used to encrypt approved secrets."
  type        = set(string)
  default     = []

  validation {
    condition = alltrue([
      for key_arn in var.external_secrets_kms_key_arns :
      can(regex(
        "^arn:[^:]+:kms:[^:]+:[0-9]{12}:key/.+$",
        key_arn
      ))
    ])

    error_message = "external_secrets_kms_key_arns must contain valid KMS key ARNs."
  }
}

variable "external_secrets_chart_version" {
  description = "Pinned official External Secrets Operator Helm chart version."
  type        = string
  default     = "2.9.0"

  validation {
    condition = can(
      regex(
        "^[0-9]+\\.[0-9]+\\.[0-9]+$",
        var.external_secrets_chart_version
      )
    )

    error_message = "external_secrets_chart_version must use semantic version format."
  }
}

variable "external_secrets_replicas" {
  description = "Number of External Secrets Operator replicas."
  type        = number
  default     = 2

  validation {
    condition     = var.external_secrets_replicas >= 2
    error_message = "At least two External Secrets Operator replicas are required for availability."
  }
}
