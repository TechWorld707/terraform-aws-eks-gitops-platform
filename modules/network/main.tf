data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

locals {
  resource_name = "${var.name}-${var.environment}"

  common_tags = merge(
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.name
      Module      = "network"
    },
    var.tags
  )

  public_subnets = {
    for index, cidr in var.public_subnet_cidrs :
    var.availability_zones[index] => {
      availability_zone = var.availability_zones[index]
      cidr_block        = cidr
      index             = index
    }
  }

  private_subnets = {
    for index, cidr in var.private_subnet_cidrs :
    var.availability_zones[index] => {
      availability_zone = var.availability_zones[index]
      cidr_block        = cidr
      index             = index
    }
  }

  nat_gateway_subnets = {
    for availability_zone, subnet in local.public_subnets :
    availability_zone => subnet
    if !var.single_nat_gateway || subnet.index == 0
  }

  interface_endpoint_services = {
    ecr_api = "com.amazonaws.${data.aws_region.current.region}.ecr.api"
    ecr_dkr = "com.amazonaws.${data.aws_region.current.region}.ecr.dkr"
    logs    = "com.amazonaws.${data.aws_region.current.region}.logs"
    sts     = "com.amazonaws.${data.aws_region.current.region}.sts"
  }
}

check "matching_subnet_and_availability_zone_counts" {
  assert {
    condition = (
      length(var.public_subnet_cidrs) == length(var.availability_zones) &&
      length(var.private_subnet_cidrs) == length(var.availability_zones)
    )

    error_message = "Public subnet CIDRs, private subnet CIDRs and Availability Zones must have matching counts."
  }
}

check "unique_availability_zones" {
  assert {
    condition = (
      length(distinct(var.availability_zones)) ==
      length(var.availability_zones)
    )

    error_message = "availability_zones must not contain duplicates."
  }
}

check "unique_subnet_cidrs" {
  assert {
    condition = (
      length(
        distinct(
          concat(
            var.public_subnet_cidrs,
            var.private_subnet_cidrs
          )
        )
      ) ==
      length(var.public_subnet_cidrs) +
      length(var.private_subnet_cidrs)
    )

    error_message = "Public and private subnet CIDR blocks must be unique."
  }
}