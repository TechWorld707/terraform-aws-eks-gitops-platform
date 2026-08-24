variable "name" {
  description = "Name prefix applied to network resources."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must not be empty."
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

variable "vpc_cidr" {
  description = "IPv4 CIDR block assigned to the VPC."
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "Availability Zones used by the public and private subnets."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two Availability Zones must be supplied."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks assigned to the public subnets."
  type        = list(string)

  validation {
    condition = (
      length(var.public_subnet_cidrs) >= 2 &&
      alltrue([
        for cidr in var.public_subnet_cidrs :
        can(cidrhost(cidr, 0))
      ])
    )
    error_message = "At least two valid public subnet CIDR blocks must be supplied."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks assigned to the private EKS workload subnets."
  type        = list(string)

  validation {
    condition = (
      length(var.private_subnet_cidrs) >= 2 &&
      alltrue([
        for cidr in var.private_subnet_cidrs :
        can(cidrhost(cidr, 0))
      ])
    )
    error_message = "At least two valid private subnet CIDR blocks must be supplied."
  }
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway for all private subnets instead of one per Availability Zone."
  type        = bool
  default     = false
}

variable "enable_vpc_endpoints" {
  description = "Create selected VPC endpoints to reduce private-subnet traffic through NAT gateways."
  type        = bool
  default     = true
}

variable "enable_s3_gateway_endpoint" {
  description = "Create the free S3 gateway endpoint and associate it with private route tables."
  type        = bool
  default     = true
}

variable "enable_interface_endpoints" {
  description = "Create chargeable interface endpoints for selected AWS services."
  type        = bool
  default     = false
}

variable "flow_log_retention_days" {
  description = "Number of days that VPC Flow Logs are retained in CloudWatch Logs; the minimum is one year."
  type        = number
  default     = 365

  validation {
    condition = contains(
      [
        365,
        400,
        545,
        731,
        1096,
        1827,
        2192,
        2557,
        2922,
        3288,
        3653
      ],
      var.flow_log_retention_days
    )

    error_message = "flow_log_retention_days must be a supported CloudWatch Logs retention value of at least 365 days."

  }
}

variable "tags" {
  description = "Additional tags applied to network resources."
  type        = map(string)
  default     = {}
}