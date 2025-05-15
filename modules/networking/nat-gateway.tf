resource "aws_nat_gateway" "custom_nat" {
  count             = var.nat_connectivity_type == "public" ? 1 : 0
  connectivity_type = var.nat_connectivity_type
  allocation_id     = aws_eip.nat_elastic_ip[0].id
  subnet_id         = aws_subnet.custom_public[0].id

  tags = {
    Name = "${var.vpc_name}-nat-gateway"
  }

  depends_on = [aws_eip.nat_elastic_ip]
}

resource "aws_eip" "nat_elastic_ip" {
  count = var.nat_connectivity_type == "public" ? 1 : 0
  domain = "vpc"

  tags = {
    Name = "${var.vpc_name}-EIP"
  }

  depends_on = [aws_internet_gateway.gw]
}
