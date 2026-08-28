variable "name" {
  description = "Name prefix applied to managed node-group resources."
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
  description = "Name of the EKS cluster receiving the managed node group."
  type        = string

  validation {
    condition     = length(var.cluster_name) > 0
    error_message = "cluster_name must not be empty."
  }
}

variable "node_group_name" {
  description = "Logical name of the managed node group."
  type        = string
  default     = "general"

  validation {
    condition = can(
      regex(
        "^[a-z0-9][a-z0-9-]{1,30}[a-z0-9]$",
        var.node_group_name
      )
    )

    error_message = "node_group_name must contain 3-32 lowercase letters, numbers or hyphens."
  }
}

variable "node_role_arn" {
  description = "ARN of the IAM role used by the EKS worker nodes."
  type        = string

  validation {
    condition = can(
      regex(
        "^arn:[^:]+:iam::[0-9]{12}:role/.+$",
        var.node_role_arn
      )
    )

    error_message = "node_role_arn must be a valid IAM role ARN."
  }
}

variable "subnet_ids" {
  description = "Private subnet IDs used by the managed node group."
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

variable "ami_type" {
  description = "AMI type used by the managed worker nodes."
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}

variable "capacity_type" {
  description = "EC2 capacity type used by the managed node group."
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition = contains(
      ["ON_DEMAND", "SPOT"],
      var.capacity_type
    )

    error_message = "capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "instance_types" {
  description = "EC2 instance types available to the managed node group."
  type        = list(string)

  default = [
    "t3.medium"
  ]

  validation {
    condition = (
      length(var.instance_types) > 0 &&
      length(distinct(var.instance_types)) == length(var.instance_types)
    )

    error_message = "instance_types must contain at least one unique instance type."
  }
}

variable "disk_size" {
  description = "Worker-node root volume size in GiB."
  type        = number
  default     = 50

  validation {
    condition = (
      var.disk_size >= 20 &&
      var.disk_size <= 500
    )

    error_message = "disk_size must be between 20 and 500 GiB."
  }
}

variable "desired_size" {
  description = "Initial desired number of worker nodes."
  type        = number
  default     = 2

  validation {
    condition     = var.desired_size >= 0
    error_message = "desired_size must be zero or greater."
  }
}

variable "minimum_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 1

  validation {
    condition     = var.minimum_size >= 0
    error_message = "minimum_size must be zero or greater."
  }
}

variable "maximum_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 4

  validation {
    condition     = var.maximum_size >= 1
    error_message = "maximum_size must be one or greater."
  }
}

variable "maximum_unavailable" {
  description = "Maximum number of unavailable nodes during an update."
  type        = number
  default     = 1

  validation {
    condition = (
      var.maximum_unavailable >= 1 &&
      var.maximum_unavailable <= 100
    )

    error_message = "maximum_unavailable must be between 1 and 100."
  }
}

variable "enable_node_repair" {
  description = "Enable automatic repair of unhealthy managed nodes."
  type        = bool
  default     = true
}

variable "force_update_version" {
  description = "Force a node-group version update when Pods cannot be drained."
  type        = bool
  default     = false
}

variable "labels" {
  description = "Additional Kubernetes labels applied to worker nodes."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Additional tags applied to managed node-group resources."
  type        = map(string)
  default     = {}
}

check "valid_scaling_configuration" {
  assert {
    condition = (
      var.minimum_size <= var.desired_size &&
      var.desired_size <= var.maximum_size
    )

    error_message = "Scaling sizes must satisfy minimum_size <= desired_size <= maximum_size."
  }
}