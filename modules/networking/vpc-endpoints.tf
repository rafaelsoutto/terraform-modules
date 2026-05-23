data "aws_region" "current" {}

resource "aws_security_group" "vpc_endpoints" {
  count = local.any_interface_endpoint ? 1 : 0

  name_prefix = "${var.vpc_name}-vpc-endpoints-"
  description = "Allow HTTPS from within the VPC to interface endpoints"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow HTTPS from VPC"
  }

  tags = {
    Name = "${var.vpc_name}-vpc-endpoints-sg"
  }
}

resource "aws_vpc_endpoint" "s3" {
  count = var.enable_s3_endpoint ? 1 : 0

  vpc_id            = aws_vpc.custom_vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = {
    Name = "${var.vpc_name}-s3-endpoint"
  }
}

resource "aws_vpc_endpoint" "secretsmanager" {
  count = var.enable_secretsmanager_endpoint ? 1 : 0

  vpc_id              = aws_vpc.custom_vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.custom_private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = {
    Name = "${var.vpc_name}-secretsmanager-endpoint"
  }
}

resource "aws_vpc_endpoint" "cloudwatch_logs" {
  count = var.enable_cloudwatch_endpoint ? 1 : 0

  vpc_id              = aws_vpc.custom_vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.custom_private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = {
    Name = "${var.vpc_name}-cloudwatch-logs-endpoint"
  }
}

resource "aws_vpc_endpoint" "cloudwatch_monitoring" {
  count = var.enable_cloudwatch_endpoint ? 1 : 0

  vpc_id              = aws_vpc.custom_vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.monitoring"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.custom_private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = {
    Name = "${var.vpc_name}-cloudwatch-monitoring-endpoint"
  }
}

resource "aws_vpc_endpoint" "cloudwatch_events" {
  count = var.enable_cloudwatch_endpoint ? 1 : 0

  vpc_id              = aws_vpc.custom_vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.events"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.custom_private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = {
    Name = "${var.vpc_name}-cloudwatch-events-endpoint"
  }
}
