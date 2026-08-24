mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
      arn        = "arn:aws:iam::123456789012:user/terraform-test"
      user_id    = "AIDATEST"
    }
  }

  mock_data "aws_partition" {
    defaults = {
      partition  = "aws"
      dns_suffix = "amazonaws.com"
    }
  }

  mock_data "aws_region" {
    defaults = {
      region = "us-east-1"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

run "development_cost_optimized_network" {
  command = plan

  variables {
    name        = "three-tier-eks"
    environment = "dev"

    vpc_cidr = "10.20.0.0/16"

    availability_zones = [
      "us-east-1a",
      "us-east-1b",
      "us-east-1c"
    ]

    public_subnet_cidrs = [
      "10.20.0.0/24",
      "10.20.1.0/24",
      "10.20.2.0/24"
    ]

    private_subnet_cidrs = [
      "10.20.10.0/24",
      "10.20.11.0/24",
      "10.20.12.0/24"
    ]

    single_nat_gateway         = true
    enable_s3_gateway_endpoint = true
    enable_interface_endpoints = false
  }

  assert {
    condition     = aws_cloudwatch_log_group.vpc_flow_logs.retention_in_days >= 365
    error_message = "VPC Flow Logs must be retained for at least one year."
  }

  assert {
    condition     = length(aws_default_security_group.this.ingress) == 0
    error_message = "The default VPC security group must not contain ingress rules."
  }

  assert {
    condition     = length(aws_default_security_group.this.egress) == 0
    error_message = "The default VPC security group must not contain egress rules."
  }

  assert {
    condition     = aws_vpc.this.cidr_block == "10.20.0.0/16"
    error_message = "The development VPC must use the supplied CIDR block."
  }

  assert {
    condition     = aws_vpc.this.enable_dns_support
    error_message = "VPC DNS support must be enabled."
  }

  assert {
    condition     = aws_vpc.this.enable_dns_hostnames
    error_message = "VPC DNS hostnames must be enabled."
  }

  assert {
    condition     = length(aws_subnet.public) == 3
    error_message = "Development must create three public subnets."
  }

  assert {
    condition     = length(aws_subnet.private) == 3
    error_message = "Development must create three private subnets."
  }

  assert {
    condition = alltrue([
      for subnet in aws_subnet.public :
      subnet.map_public_ip_on_launch == false
    ])

    error_message = "Public subnets must not automatically assign public IP addresses."
  }

  assert {
    condition = alltrue([
      for subnet in aws_subnet.private :
      subnet.map_public_ip_on_launch == false
    ])

    error_message = "Private subnets must not automatically assign public IP addresses."
  }

  assert {
    condition     = length(aws_nat_gateway.this) == 1
    error_message = "Cost-optimized development must create one NAT gateway."
  }

  assert {
    condition     = aws_flow_log.this.traffic_type == "ALL"
    error_message = "VPC Flow Logs must capture accepted and rejected traffic."
  }

  assert {
    condition     = aws_flow_log.this.max_aggregation_interval == 60
    error_message = "VPC Flow Logs must use the one-minute aggregation interval."
  }

  assert {
    condition     = aws_kms_key.flow_logs.enable_key_rotation
    error_message = "The Flow Logs KMS key must have rotation enabled."
  }

  assert {
    condition     = length(aws_vpc_endpoint.s3) == 1
    error_message = "The development network must create the S3 gateway endpoint."
  }

  assert {
    condition     = length(aws_vpc_endpoint.interface) == 0
    error_message = "Chargeable interface endpoints must be disabled in the cost-optimized development test."
  }
}

run "production_resilient_network" {
  command = plan

  variables {
    name        = "three-tier-eks"
    environment = "production"

    vpc_cidr = "10.30.0.0/16"

    availability_zones = [
      "us-east-1a",
      "us-east-1b",
      "us-east-1c"
    ]

    public_subnet_cidrs = [
      "10.30.0.0/24",
      "10.30.1.0/24",
      "10.30.2.0/24"
    ]

    private_subnet_cidrs = [
      "10.30.10.0/24",
      "10.30.11.0/24",
      "10.30.12.0/24"
    ]

    single_nat_gateway         = false
    enable_s3_gateway_endpoint = true
    enable_interface_endpoints = true
  }

  assert {
    condition     = length(aws_nat_gateway.this) == 3
    error_message = "Production must create one NAT gateway per Availability Zone."
  }

  assert {
    condition     = length(aws_route_table.private) == 3
    error_message = "Production must create one private route table per Availability Zone."
  }

  assert {
    condition     = length(aws_vpc_endpoint.interface) == 4
    error_message = "Production must create all four configured interface endpoints."
  }

  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.interface_endpoints_https) == 3
    error_message = "Endpoint HTTPS ingress must be restricted to the three private subnet CIDR blocks."
  }
}