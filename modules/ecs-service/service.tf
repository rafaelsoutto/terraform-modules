resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = var.launch_type

  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent

  network_configuration {
    subnets          = var.network.private_subnet_ids
    security_groups  = [aws_security_group.ecs_service.id]
    assign_public_ip = var.assign_public_ip
  }

  dynamic "load_balancer" {
    for_each = var.is_loadbalancer_fronted ? [1] : []
    content {
      target_group_arn = var.lb_target_group_arn
      container_name   = var.containers[0].name
      container_port   = var.container_port
    }
  }

  depends_on = [aws_ecs_task_definition.this]

  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_security_group" "ecs_service" {
  name        = "${var.service_name}-ecs-service-sg"
  description = "Allow inbound access from LB and VPC CIDR"
  vpc_id      = var.network.vpc_id

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

  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow DNS outbound"
  }

  tags = {
    Name = "${var.service_name}-ecs-service-sg"
  }
}

resource "aws_security_group_rule" "allow_vpc_cidr" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [var.network.vpc_cidr]
  security_group_id = aws_security_group.ecs_service.id
  description       = "Allow all TCP from VPC CIDR"
}

resource "aws_security_group_rule" "allow_lb" {
  count                    = var.is_loadbalancer_fronted ? 1 : 0
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = var.lb_sg_id
  security_group_id        = aws_security_group.ecs_service.id
  description              = "Allow all TCP from Load Balancer"
}
