resource "aws_security_group" "lambda_sg" {
  count       = var.vpc_name != "" ? 1 : 0
  name        = "${var.function_name}-sg"
  description = "Security group for Lambda function ${var.function_name}"
  vpc_id      = data.aws_vpc.selected[0].id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.selected[0].cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.function_name}-sg"
  }
}
