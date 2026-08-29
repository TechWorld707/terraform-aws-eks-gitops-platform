variable "name" {
  description = "Name prefix applied to EKS add-on resources."
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

variable "cluster_name" {
  description = "Name of the EKS cluster receiving the add-ons."
  type        = string

  validation {
    condition     = length(var.cluster_name) > 0
    error_message = "cluster_name must not be empty."
  }
}

variable "addon_versions" {
  description = "Optional map of EKS add-on name to explicit add-on version."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for addon_name in keys(var.addon_versions) :
      contains(
        [
          "aws-ebs-csi-driver",
          "coredns",
          "eks-pod-identity-agent",
          "kube-proxy",
          "vpc-cni"
        ],
        addon_name
      )
    ])

    error_message = "addon_versions contains an unsupported EKS add-on name."
  }
}

variable "resolve_conflicts_on_create" {
  description = "Conflict-resolution behavior when creating EKS add-ons."
  type        = string
  default     = "OVERWRITE"

  validation {
    condition = contains(
      ["NONE", "OVERWRITE"],
      var.resolve_conflicts_on_create
    )

    error_message = "resolve_conflicts_on_create must be NONE or OVERWRITE."
  }
}

variable "resolve_conflicts_on_update" {
  description = "Conflict-resolution behavior when updating EKS add-ons."
  type        = string
  default     = "PRESERVE"

  validation {
    condition = contains(
      ["NONE", "OVERWRITE", "PRESERVE"],
      var.resolve_conflicts_on_update
    )

    error_message = "resolve_conflicts_on_update must be NONE, OVERWRITE or PRESERVE."
  }
}

variable "permissions_boundary_arn" {
  description = "Optional permissions boundary applied to add-on IAM roles."
  type        = string
  default     = null

  validation {
    condition = (
      var.permissions_boundary_arn == null ||
      can(regex(
        "^arn:[^:]+:iam::[0-9]{12}:policy/.+$",
        var.permissions_boundary_arn
      ))
    )

    error_message = "permissions_boundary_arn must be null or a valid IAM policy ARN."
  }
}

variable "tags" {
  description = "Additional tags applied to EKS add-on resources."
  type        = map(string)
  default     = {}
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