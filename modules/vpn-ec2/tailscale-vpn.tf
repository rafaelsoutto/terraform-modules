resource "aws_security_group" "tailscale_sg" {
  name        = "${var.name}-sg"
  description = "Security group for Tailscale VPN"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = length(var.allowed_ssh_cidrs) > 0 ? [1] : []
    content {
      description = "Allow SSH from specified CIDRs"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.allowed_ssh_cidrs
    }
  }

  egress {
    description = "Allow All Traffic for Tailscale"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-sg"
  }
}

resource "aws_instance" "tailscale" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.tailscale_sg.id]
  associate_public_ip_address = var.associate_public_ip
  key_name                    = var.key_name
  user_data                   = var.user_data
  iam_instance_profile        = var.iam_instance_profile_name
  monitoring                  = var.enable_monitoring
  ebs_optimized               = var.ebs_optimized

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    encrypted             = var.root_volume_encrypted
    delete_on_termination = true
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}
