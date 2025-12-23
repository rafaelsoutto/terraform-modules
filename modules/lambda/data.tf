data "aws_region" "current" {}

data "aws_vpc" "selected" {
  count = var.vpc_name != "" ? 1 : 0
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "selected" {
  count = var.vpc_name != "" ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected[0].id]
  }

  filter {
    name   = "tag:SubnetType"
    values = [var.subnet_deployment_type]
  }
}