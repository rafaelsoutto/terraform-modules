resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = var.launch_type

  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs_service.id]
    assign_public_ip = var.assign_public_ip
  }

 dynamic "load_balancer" {
    for_each = var.is_loadbalancer_fronted ? [
      for container in var.containers : {
        container_name = container.name
        container_port = container.port_mappings[0].container_port
      }
      if length(container.port_mappings) > 0
    ] : []

    content {
      target_group_arn = aws_lb_target_group.this[load_balancer.key].arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  depends_on = [aws_ecs_task_definition.this]
}


# Security Group for ECS Service
resource "aws_security_group" "ecs_service" {
  name        = "${var.service_name}-ecs-service-sg"
  description = "Allow inbound access from LB and VPC CIDR"
  vpc_id      = var.vpc_id

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.service_name}-ecs-service-sg"
  }
}

# Security Group Rule - Allow from VPC CIDR
resource "aws_security_group_rule" "allow_vpc_cidr" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.ecs_service.id
}

# Security Group Rule - Allow from Load Balancer
resource "aws_security_group_rule" "allow_lb" {
  count = var.is_loadbalancer_fronted ? 1 : 0
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = var.lb_sg_id
  security_group_id        = aws_security_group.ecs_service.id
}