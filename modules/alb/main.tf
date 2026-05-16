resource "aws_security_group" "alb_sg" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.network.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidrs
    description = "Allow HTTPS traffic"
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP outbound"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS outbound"
  }

  tags = var.tags
}

resource "aws_lb" "alb" {
  name               = "${var.name_prefix}-alb"
  internal           = var.is_internal
  load_balancer_type = var.loadbalancer_type
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.network.public_subnet_ids

  enable_deletion_protection       = var.enable_deletion_protection
  enable_http2                     = true
  enable_cross_zone_load_balancing = true
  drop_invalid_header_fields       = true

  dynamic "access_logs" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      bucket  = var.access_logs_s3_bucket
      prefix  = var.access_logs_s3_prefix
      enabled = true
    }
  }

  tags = var.tags
}

resource "aws_wafv2_web_acl_association" "alb_waf" {
  count        = var.waf_arn != null ? 1 : 0
  resource_arn = aws_lb.alb.arn
  web_acl_arn  = var.waf_arn
}

resource "aws_lb_target_group" "tg" {
  for_each = var.listener_rules

  name     = "${var.name_prefix}-${each.key}-tg"
  port     = var.health_check_port != null ? var.health_check_port : each.value.target_port
  protocol = "HTTP"
  vpc_id   = var.network.vpc_id

  target_type = var.target_type

  health_check {
    path                = each.value.health_check_path
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 4
    matcher             = "200-299"
  }

  tags = var.tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = var.certificate_arn != null && var.enable_http_to_https_redirect ? "redirect" : "fixed-response"

    dynamic "redirect" {
      for_each = var.certificate_arn != null && var.enable_http_to_https_redirect ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    dynamic "fixed_response" {
      for_each = var.certificate_arn == null || !var.enable_http_to_https_redirect ? [1] : []
      content {
        content_type = "text/plain"
        message_body = "Not found"
        status_code  = "404"
      }
    }
  }
}

resource "aws_lb_listener" "https" {
  count             = var.certificate_arn != null ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"

  certificate_arn = var.certificate_arn
  ssl_policy      = var.ssl_policy

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }

  depends_on = [
    aws_lb_listener.http
  ]
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

resource "aws_lb_listener_rule" "https_rules" {
  for_each = var.certificate_arn != null ? var.listener_rules : {}

  listener_arn = aws_lb_listener.https[0].arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = var.target_group_arn != null ? var.target_group_arn : aws_lb_target_group.tg[each.key].arn
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