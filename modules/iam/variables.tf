variable "name" {
  description = "Name prefix applied to IAM resources."
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

variable "permissions_boundary_arn" {
  description = "Optional permissions boundary applied to the IAM roles."
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
  description = "Additional tags applied to IAM resources."
  type        = map(string)
  default     = {}
}