resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id = aws_vpc.this.id

  availability_zone = each.value.availability_zone
  cidr_block        = each.value.cidr_block

  map_public_ip_on_launch = false

  tags = merge(
    local.common_tags,
    {
      Name                     = "${local.resource_name}-public-${each.value.availability_zone}"
      Tier                     = "public"
      "kubernetes.io/role/elb" = "1"
    }
  )
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id = aws_vpc.this.id

  availability_zone = each.value.availability_zone
  cidr_block        = each.value.cidr_block

  map_public_ip_on_launch = false

  tags = merge(
    local.common_tags,
    {
      Name                              = "${local.resource_name}-private-${each.value.availability_zone}"
      Tier                              = "private"
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}