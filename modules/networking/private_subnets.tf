
resource "aws_subnet" "custom_private" {
  count                   = var.subnet_pairs
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.custom_vpc.cidr_block, 8, (count.index + 3))
  availability_zone       = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  map_public_ip_on_launch = var.map_public_ip_on_launch
  
  tags = {
    Name = "${var.vpc_name}-private-sn-${count.index + 1}"
  }
}

