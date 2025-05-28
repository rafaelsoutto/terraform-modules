resource "aws_security_group" "alb_sg" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidrs
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_lb" "alb" {
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnets

  enable_deletion_protection = false

  tags = var.tags
}

resource "aws_lb_target_group" "tg" {
  for_each = var.listener_rules

  name     = "${var.name_prefix}-${each.key}-tg"
  port     = var.health_check_port != null ? var.health_check_port : each.value.target_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_type = var.target_type

  health_check {
    path                = each.value.health_check_path
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
  }

  tags = var.tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener" "https" {
  count = var.certificate_arn != null ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"

  certificate_arn = var.certificate_arn

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "rules" {
  for_each = var.listener_rules

  listener_arn = aws_lb_listener.http.arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[each.key].arn
  }

  # Always include path_pattern from the listener_rules
  condition {
    path_pattern {
      values = each.value.path_patterns
    }
  }

  # Include additional conditions if they exist
  dynamic "condition" {
    for_each = try(each.value.additional_conditions, [])
    
    content {
      dynamic "source_ip" {
        for_each = condition.value.field == "source_ip" ? [1] : []
        content {
          values = condition.value.values
        }
      }
      
      dynamic "host_header" {
        for_each = condition.value.field == "host_header" ? [1] : []
        content {
          values = condition.value.values
        }
      }
    }
  }
}

resource "aws_lb_listener_rule" "https_rules" {
  for_each = var.certificate_arn != null ? var.listener_rules : {}

  listener_arn = aws_lb_listener.https[0].arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[each.key].arn
  }

  # Always include path_pattern from the listener_rules
  condition {
    path_pattern {
      values = each.value.path_patterns
    }
  }

  # Include additional conditions if they exist
  dynamic "condition" {
    for_each = try(each.value.additional_conditions, [])
    
    content {
      dynamic "source_ip" {
        for_each = condition.value.field == "source_ip" ? [1] : []
        content {
          values = condition.value.values
        }
      }
      
      dynamic "host_header" {
        for_each = condition.value.field == "host_header" ? [1] : []
        content {
          values = condition.value.values
        }
      }
    }
  }
}