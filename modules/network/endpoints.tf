resource "aws_vpc_endpoint" "s3" {
  count = var.enable_s3_gateway_endpoint ? 1 : 0

  vpc_id = aws_vpc.this.id

  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    for route_table in aws_route_table.private :
    route_table.id
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.resource_name}-s3"
    }
  )
}

resource "aws_security_group" "interface_endpoints" {
  count = var.enable_interface_endpoints ? 1 : 0

  name        = "${local.resource_name}-interface-endpoints"
  description = "Controls HTTPS access to private AWS service endpoints."
  vpc_id      = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.resource_name}-interface-endpoints"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "interface_endpoints_https" {
  for_each = var.enable_interface_endpoints ? local.private_subnets : {}

  security_group_id = aws_security_group.interface_endpoints[0].id

  description = "Allow HTTPS from private subnet ${each.value.availability_zone}."

  cidr_ipv4   = each.value.cidr_block
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_endpoint" "interface" {
  for_each = var.enable_interface_endpoints ? local.interface_endpoint_services : {}

  vpc_id = aws_vpc.this.id

  service_name      = each.value
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true

  subnet_ids = [
    for subnet in aws_subnet.private :
    subnet.id
  ]

  security_group_ids = [
    aws_security_group.interface_endpoints[0].id
  ]

  tags = merge(
    local.common_tags,
    {
      Name    = "${local.resource_name}-${replace(each.key, "_", "-")}"
      Service = each.key
    }
  )
}