resource "aws_vpc" "this" {
  for_each   = var.vpc_parameters
  cidr_block = each.value.cidr_block
}

resource "aws_subnet" "this" {
  for_each          = var.subnet_parameters
  vpc_id            = aws_vpc.this[each.value.vpc_name].id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
}

resource "aws_internet_gateway" "this" {
  for_each = var.internet_gateway_parameters
  vpc_id   = aws_vpc.this[each.value.vpc_name].id
}

resource "aws_route_table" "this" {
  for_each = var.route_table_parameters
  vpc_id   = aws_vpc.this[each.value.vpc_name].id

  dynamic "route" {
    for_each = each.value.routes
    content {
      cidr_block = route.value.cidr_block
      gateway_id = route.value.gateway_id
    }
  }
}

resource "aws_route_table_association" "this" {
  for_each       = var.route_table_association_parameters
  subnet_id      = aws_subnet.this[each.value.subnet_name].id
  route_table_id = aws_route_table.this[each.value.rt_name].id
}
