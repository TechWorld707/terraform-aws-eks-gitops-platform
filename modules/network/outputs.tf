output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "ARN of the VPC."
  value       = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "IPv4 CIDR block assigned to the VPC."
  value       = aws_vpc.this.cidr_block
}

output "availability_zones" {
  description = "Availability Zones used by the network."
  value       = var.availability_zones
}

output "public_subnet_ids" {
  description = "Public subnet IDs ordered by the configured Availability Zones."
  value = [
    for availability_zone in var.availability_zones :
    aws_subnet.public[availability_zone].id
  ]
}

output "private_subnet_ids" {
  description = "Private EKS workload subnet IDs ordered by the configured Availability Zones."
  value = [
    for availability_zone in var.availability_zones :
    aws_subnet.private[availability_zone].id
  ]
}

output "public_subnet_cidr_blocks" {
  description = "Public subnet CIDR blocks ordered by the configured Availability Zones."
  value = [
    for availability_zone in var.availability_zones :
    aws_subnet.public[availability_zone].cidr_block
  ]
}

output "private_subnet_cidr_blocks" {
  description = "Private subnet CIDR blocks ordered by the configured Availability Zones."
  value = [
    for availability_zone in var.availability_zones :
    aws_subnet.private[availability_zone].cidr_block
  ]
}

output "public_route_table_id" {
  description = "ID of the shared public route table."
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "Private route-table IDs ordered by the configured Availability Zones."
  value = [
    for availability_zone in var.availability_zones :
    aws_route_table.private[availability_zone].id
  ]
}

output "internet_gateway_id" {
  description = "ID of the VPC internet gateway."
  value       = aws_internet_gateway.this.id
}

output "nat_gateway_ids" {
  description = "Map of Availability Zone to NAT gateway ID."
  value = {
    for availability_zone, nat_gateway in aws_nat_gateway.this :
    availability_zone => nat_gateway.id
  }
}

output "nat_gateway_public_ips" {
  description = "Map of Availability Zone to NAT gateway public IP address."
  value = {
    for availability_zone, elastic_ip in aws_eip.nat :
    availability_zone => elastic_ip.public_ip
  }
}

output "flow_log_id" {
  description = "ID of the VPC Flow Log."
  value       = aws_flow_log.this.id
}

output "flow_log_group_name" {
  description = "CloudWatch Logs group receiving VPC Flow Logs."
  value       = aws_cloudwatch_log_group.vpc_flow_logs.name
}

output "flow_log_kms_key_arn" {
  description = "ARN of the KMS key encrypting VPC Flow Logs."
  value       = aws_kms_key.flow_logs.arn
}

output "s3_gateway_endpoint_id" {
  description = "ID of the S3 gateway endpoint when enabled."
  value = try(
    aws_vpc_endpoint.s3[0].id,
    null
  )
}

output "interface_endpoint_ids" {
  description = "Map of AWS service name to interface endpoint ID."
  value = {
    for service, endpoint in aws_vpc_endpoint.interface :
    service => endpoint.id
  }
}

output "interface_endpoint_security_group_id" {
  description = "ID of the interface endpoint security group when enabled."
  value = try(
    aws_security_group.interface_endpoints[0].id,
    null
  )
}

output "default_security_group_id" {
  description = "ID of the default VPC security group, managed with no ingress or egress rules."
  value       = aws_default_security_group.this.id
}