resource "aws_security_group" "alb_sg" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = data.aws_vpc.selected.id

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
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.internal ? data.aws_subnets.private_subnets.ids : data.aws_subnets.public_subnets.ids

  enable_deletion_protection = false

  tags = var.tags
}

resource "aws_lb_target_group" "tg" {
  for_each    = var.routing_rules
  vpc_id      = data.aws_vpc.selected.id

  name        = "${var.name_prefix}-${each.key}-tg"
  
  port        = each.value.target_group_port
  protocol    = each.value.target_group_protocol
  target_type = each.value.target_group_target_type

  health_check {
    path                = each.value.health_check_path
    port                = each.value.health_check_port
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 5
    matcher             = "200-299"
  }

  tags = var.tags
}

resource "aws_lb_listener" "alb_listeners" {
  for_each = var.routing_rules
  load_balancer_arn   = aws_lb.alb.arn
  port                = each.value.listener_port
  protocol            = each.value.listener_protocol
  ssl_policy          = each.value.listener_protocol == "HTTPS" ? "ELBSecurityPolicy-2016-08" : null
  certificate_arn     = each.value.listener_protocol == "HTTPS" ? each.value.listener_certificate_arn : null

  default_action {
    # 404 not found
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "rules" {
  for_each = var.routing_rules

  listener_arn = aws_lb_listener.alb_listeners[each.key].arn
  priority     = each.value.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[each.key].arn
  }

  # Always include path_pattern from the listener_rules
  condition {
    path_pattern {
      values = each.value.listener_rule_path_patterns
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
      dynamic "http_header" {
        for_each = condition.value.field == "http_header" ? [1] : []
        content {
          http_header_name = condition.value.http_header_name
          values           = condition.value.values
        }
      }
    }
  }
}