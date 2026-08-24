variable "aws_region" {
  description = "AWS Region in which the development EKS foundation is deployed."
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
  description = "Project name used to identify EKS foundation resources."
  type        = string
  default     = "three-tier-eks"

  validation {
    condition = can(
      regex(
        "^[a-z0-9][a-z0-9-]{1,30}[a-z0-9]$",
        var.project_name
      )
    )

    error_message = "project_name must contain 3-32 lowercase letters, numbers or hyphens."
  }
}

variable "environment" {
  description = "Deployment environment represented by this Terraform root."
  type        = string
  default     = "dev"

  validation {
    condition     = var.environment == "dev"
    error_message = "The development foundation root must use environment = dev."
  }
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block assigned to the development VPC."
  type        = string
  default     = "10.20.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "Availability Zones used by the development public and private subnets."
  type        = list(string)

  default = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c"
  ]

  validation {
    condition = (
      length(var.availability_zones) == 3 &&
      length(distinct(var.availability_zones)) == 3
    )

    error_message = "Exactly three unique Availability Zones must be supplied."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks assigned to development public subnets."
  type        = list(string)

  default = [
    "10.20.0.0/24",
    "10.20.1.0/24",
    "10.20.2.0/24"
  ]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks assigned to private EKS workload subnets."
  type        = list(string)

  default = [
    "10.20.10.0/24",
    "10.20.11.0/24",
    "10.20.12.0/24"
  ]
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway for all development private subnets to control cost."
  type        = bool
  default     = true
}

variable "enable_s3_gateway_endpoint" {
  description = "Create the free S3 gateway endpoint for private-subnet S3 access."
  type        = bool
  default     = true
}

variable "enable_interface_endpoints" {
  description = "Create chargeable interface endpoints for ECR, CloudWatch Logs and STS."
  type        = bool
  default     = false
}

variable "flow_log_retention_days" {
  description = "Number of days development VPC Flow Logs are retained."
  type        = number
  default     = 365
}

variable "tags" {
  description = "Additional tags applied to development foundation resources."
  type        = map(string)

  default = {
    Owner = "platform-engineering"
  }
}