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
          containerPort     = port.container_port
          hostPort          = port.host_port
          protocol         = port.protocol
        }
      ]
    }
  ])

  lifecycle {
    ignore_changes = [
      container_definitions,
    ]
  }

  
}