resource "aws_vpc" "custom_vpc" {
  cidr_block         = var.vpc_cidr
  instance_tenancy   = var.instance_tenancy
  enable_dns_support = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_network_address_usage_metrics = var.enable_network_address_usage_metrics
  assign_generated_ipv6_cidr_block = var.assign_generated_ipv6_cidr_block

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.custom_vpc.id

}

resource "aws_iam_role" "vpc_flow_logs" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_role_policy" "cloudwatch_logs" {
  count  = var.enable_flow_logs && var.flow_log_destination_type == "cloudwatch" ? 1 : 0
  name   = "vpc-flow-logs-cloudwatch-policy"
  role   = aws_iam_role.vpc_flow_logs[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy" "s3_logs" {
  count  = var.enable_flow_logs && var.flow_log_destination_type == "s3" ? 1 : 0
  name   = "vpc-flow-logs-s3-policy"
  role   = aws_iam_role.vpc_flow_logs[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ]
        Resource = [
          var.flow_log_s3_bucket_arn,
          "${var.flow_log_s3_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count             = var.enable_flow_logs && var.flow_log_destination_type == "cloudwatch" ? 1 : 0
  name              = "vpc-flow-logs"
  retention_in_days = var.flow_log_retention_days
}

resource "aws_flow_log" "vpc" {
  count           = var.enable_flow_logs ? 1 : 0
  traffic_type    = var.flow_logs_traffic_type
  vpc_id          = aws_vpc.custom_vpc.id
  
  iam_role_arn    = var.flow_log_destination_type == "cloudwatch" ? aws_iam_role.vpc_flow_logs[0].arn : null
  log_destination = var.flow_log_destination_type == "cloudwatch" ? aws_cloudwatch_log_group.vpc_flow_logs[0].arn : var.flow_log_s3_bucket_arn
  log_destination_type = var.flow_log_destination_type == "cloudwatch" ? "cloud-watch-logs" : "s3"
}