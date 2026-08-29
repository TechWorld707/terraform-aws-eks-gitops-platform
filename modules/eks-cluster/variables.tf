variable "name" {
  description = "Name prefix applied to EKS resources."
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

variable "cluster_role_arn" {
  description = "ARN of the IAM role used by the EKS control plane."
  type        = string

  validation {
    condition = can(
      regex(
        "^arn:[^:]+:iam::[0-9]{12}:role/.+$",
        var.cluster_role_arn
      )
    )

    error_message = "cluster_role_arn must be a valid IAM role ARN."
  }
}

variable "subnet_ids" {
  description = "Private subnet IDs used by the EKS control plane."
  type        = list(string)

  validation {
    condition = (
      length(var.subnet_ids) >= 2 &&
      length(distinct(var.subnet_ids)) == length(var.subnet_ids) &&
      alltrue([
        for subnet_id in var.subnet_ids :
        can(regex("^subnet-[0-9a-f]+$", subnet_id))
      ])
    )

    error_message = "subnet_ids must contain at least two unique subnet IDs."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version used by the EKS cluster."
  type        = string

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+$", var.kubernetes_version))
    error_message = "kubernetes_version must use major.minor format, such as 1.33."
  }
}

variable "endpoint_private_access" {
  description = "Enable private access to the Kubernetes API endpoint."
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public access to the Kubernetes API endpoint."
  type        = bool
  default     = false
}

variable "public_access_cidrs" {
  description = "CIDR blocks permitted to access the public Kubernetes API endpoint."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.public_access_cidrs :
      can(cidrhost(cidr, 0))
    ])

    error_message = "Every public_access_cidrs entry must be a valid CIDR block."
  }
}

variable "enabled_cluster_log_types" {
  description = "EKS control-plane log types sent to CloudWatch Logs."
  type        = set(string)

  default = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  validation {
    condition = alltrue([
      for log_type in var.enabled_cluster_log_types :
      contains(
        [
          "api",
          "audit",
          "authenticator",
          "controllerManager",
          "scheduler"
        ],
        log_type
      )
    ])

    error_message = "enabled_cluster_log_types contains an unsupported EKS log type."
  }
}

variable "authentication_mode" {
  description = "Method used to grant IAM principals access to the cluster."
  type        = string
  default     = "API"

  validation {
    condition = contains(
      ["API", "API_AND_CONFIG_MAP"],
      var.authentication_mode
    )

    error_message = "authentication_mode must be API or API_AND_CONFIG_MAP."
  }
}

variable "bootstrap_cluster_creator_admin_permissions" {
  description = "Grant the cluster creator permanent Kubernetes administrator access."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Protect the EKS cluster from accidental deletion."
  type        = bool
  default     = true
}

variable "kms_deletion_window_days" {
  description = "Waiting period before deletion of the Kubernetes secrets KMS key."
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
  description = "Additional tags applied to EKS resources."
  type        = map(string)
  default     = {}
}

variable "access_entries" {
  description = "Map of IAM principals granted access to the EKS cluster."

  type = map(object({
    principal_arn     = string
    type              = optional(string, "STANDARD")
    user_name         = optional(string)
    kubernetes_groups = optional(set(string), [])

    policy_arn = string

    access_scope = object({
      type       = string
      namespaces = optional(set(string), [])
    })
  }))

  default = {}

  validation {
    condition = alltrue([
      for entry in values(var.access_entries) :
      can(regex(
        "^arn:[^:]+:iam::[0-9]{12}:(role|user)/.+$",
        entry.principal_arn
      ))
    ])

    error_message = "Every access entry principal must be a durable IAM role or user ARN."
  }

  validation {
    condition = alltrue([
      for entry in values(var.access_entries) :
      can(regex(
        "^arn:[^:]+:eks::aws:cluster-access-policy/.+$",
        entry.policy_arn
      ))
    ])

    error_message = "Every access entry policy_arn must be a valid EKS cluster access policy ARN."
  }

  validation {
    condition = alltrue([
      for entry in values(var.access_entries) :
      contains(["cluster", "namespace"], entry.access_scope.type)
    ])

    error_message = "Every access scope type must be cluster or namespace."
  }

  validation {
    condition = alltrue([
      for entry in values(var.access_entries) :
      (
        entry.access_scope.type == "namespace" ||
        length(entry.access_scope.namespaces) == 0
      )
    ])

    error_message = "Namespace values may only be supplied for namespace-scoped access."
  }
}