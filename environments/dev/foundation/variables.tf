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

variable "ecr_repository_names" {
  description = "Application components requiring ECR repositories."
  type        = set(string)
  default     = ["backend", "frontend"]
}

variable "ecr_image_tag_mutability" {
  description = "Image-tag mutability setting for development ECR repositories."
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["IMMUTABLE", "MUTABLE"], var.ecr_image_tag_mutability)
    error_message = "ecr_image_tag_mutability must be IMMUTABLE or MUTABLE."
  }
}

variable "ecr_scan_on_push" {
  description = "Scan container images for vulnerabilities when pushed."
  type        = bool
  default     = true
}

variable "ecr_force_delete" {
  description = "Allow development ECR repositories to be deleted when they contain images."
  type        = bool
  default     = false
}

variable "ecr_untagged_image_retention_days" {
  description = "Number of days to retain untagged development images."
  type        = number
  default     = 7
}

variable "ecr_maximum_image_count" {
  description = "Maximum number of images retained in each development repository."
  type        = number
  default     = 30
}

variable "ecr_kms_deletion_window_days" {
  description = "Waiting period before deletion of the ECR KMS key."
  type        = number
  default     = 30
}

variable "eks_kubernetes_version" {
  description = "Kubernetes version used by the development EKS cluster."
  type        = string
  default     = "1.36"

  validation {
    condition = can(
      regex(
        "^[0-9]+\\.[0-9]+$",
        var.eks_kubernetes_version
      )
    )

    error_message = "eks_kubernetes_version must use major.minor format."
  }
}

variable "eks_endpoint_public_access" {
  description = "Enable public access to the development Kubernetes API endpoint."
  type        = bool
  default     = false
}

variable "eks_public_access_cidrs" {
  description = "CIDR blocks permitted to access the public Kubernetes API endpoint."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.eks_public_access_cidrs :
      can(cidrhost(cidr, 0))
    ])

    error_message = "Every eks_public_access_cidrs entry must be a valid CIDR block."
  }
}
variable "eks_bootstrap_cluster_creator_admin_permissions" {
  description = "Grant the cluster creator Kubernetes administrator access."
  type        = bool
  default     = false
}

variable "eks_deletion_protection" {
  description = "Protect the development EKS cluster from accidental deletion."
  type        = bool
  default     = false
}

variable "eks_kms_deletion_window_days" {
  description = "Waiting period before deletion of the EKS secrets KMS key."
  type        = number
  default     = 30

  validation {
    condition = (
      var.eks_kms_deletion_window_days >= 7 &&
      var.eks_kms_deletion_window_days <= 30
    )

    error_message = "eks_kms_deletion_window_days must be between 7 and 30."
  }
}

variable "node_group_name" {
  description = "Logical name of the development managed node group."
  type        = string
  default     = "general"
}

variable "node_capacity_type" {
  description = "EC2 capacity type used by development worker nodes."
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition = contains(
      ["ON_DEMAND", "SPOT"],
      var.node_capacity_type
    )

    error_message = "node_capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "node_instance_types" {
  description = "EC2 instance types used by development worker nodes."
  type        = list(string)

  default = [
    "t3.medium"
  ]

  validation {
    condition = (
      length(var.node_instance_types) > 0 &&
      length(distinct(var.node_instance_types)) ==
      length(var.node_instance_types)
    )

    error_message = "node_instance_types must contain at least one unique instance type."
  }
}

variable "node_disk_size" {
  description = "Worker-node root volume size in GiB."
  type        = number
  default     = 50

  validation {
    condition = (
      var.node_disk_size >= 20 &&
      var.node_disk_size <= 500
    )

    error_message = "node_disk_size must be between 20 and 500 GiB."
  }
}

variable "node_minimum_size" {
  description = "Minimum number of development worker nodes."
  type        = number
  default     = 1
}

variable "node_desired_size" {
  description = "Initial desired number of development worker nodes."
  type        = number
  default     = 2
}

variable "node_maximum_size" {
  description = "Maximum number of development worker nodes."
  type        = number
  default     = 4
}

variable "node_maximum_unavailable" {
  description = "Maximum unavailable worker nodes during an update."
  type        = number
  default     = 1

  validation {
    condition = (
      var.node_maximum_unavailable >= 1 &&
      var.node_maximum_unavailable <= 100
    )

    error_message = "node_maximum_unavailable must be between 1 and 100."
  }
}

variable "eks_admin_principal_arn" {
  description = "Durable IAM role ARN granted administrator access to the development EKS cluster."
  type        = string

  validation {
    condition = can(
      regex(
        "^arn:[^:]+:iam::[0-9]{12}:role/.+$",
        var.eks_admin_principal_arn
      )
    )

    error_message = "eks_admin_principal_arn must be a valid IAM role ARN."
  }
}

variable "node_enable_repair" {
  description = "Enable automatic repair of unhealthy development worker nodes."
  type        = bool
  default     = true
}

check "valid_development_node_scaling" {
  assert {
    condition = (
      var.node_minimum_size >= 0 &&
      var.node_minimum_size <= var.node_desired_size &&
      var.node_desired_size <= var.node_maximum_size
    )

    error_message = "Node scaling must satisfy 0 <= minimum <= desired <= maximum."
  }
}

check "valid_development_public_endpoint" {
  assert {
    condition = (
      !var.eks_endpoint_public_access ||
      length(var.eks_public_access_cidrs) > 0
    )

    error_message = "Public EKS endpoint access requires at least one permitted CIDR."
  }
}