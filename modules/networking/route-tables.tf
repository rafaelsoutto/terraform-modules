# PUBLIC SUBNETS ---------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = var.subnet_pairs

  subnet_id      = aws_subnet.custom_public[count.index].id
  route_table_id = aws_route_table.public.id
}


# PRIVATE SUBNETS ---------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  count = var.subnet_pairs

  subnet_id      = aws_subnet.custom_private[count.index].id
  route_table_id = aws_route_table.private.id
}
