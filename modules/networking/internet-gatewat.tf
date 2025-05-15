resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "${var.vpc_name}-internet-gateway"
  }
}

