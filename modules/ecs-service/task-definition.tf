data "aws_region" "current" {}


resource "aws_ecs_task_definition" "this" {
  family                   = var.task_definition_family
  requires_compatibilities = var.requires_compatibilities
  network_mode             = var.network_mode
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_etask_role.arn

  runtime_platform {
    operating_system_family = var.operating_system_family
    cpu_architecture        = var.cpu_architecture
  }


container_definitions = jsonencode([
  for container in var.containers : {
    name        = container.name
    image       = container.image
    cpu         = container.cpu
    memory      = container.memory
    essential   = container.essential
    portMappings = [
      for port in container.port_mappings : {
        containerPort = port.container_port
        hostPort      = port.host_port
        protocol      = port.protocol
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"          = "${var.task_definition_family}-${container.name}-logs"
        "awslogs-region"         = data.aws_region.current.name
        "awslogs-stream-prefix"  = container.name
        "awslogs-create-group"   = "true"
        "mode"                   = "non-blocking"
        "max-buffer-size"       = "1m"
      }
    }
    healthCheck = container.health_check != null ? {
      command     = container.health_check.command
      interval    = container.health_check.interval
      timeout     = container.health_check.timeout
      retries     = container.health_check.retries
      startPeriod = container.health_check.startPeriod
    } : null
  }
])

  lifecycle {
    ignore_changes = [container_definitions]
  }

}