resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.task_definition_family}-ecs-exec-role"
  assume_role_policy = "${jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })}"
}
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_basic" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_etask_role" {
  name               = "${var.task_definition_family}-ecs-task-role"
  assume_role_policy = "${jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })}"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_etask_role.name
  policy_arn = aws_iam_policy.ecs_permissions[0].arn
}

resource "aws_iam_policy" "ecs_permissions" {
  count = length(var.allowed_actions) > 0 ? 1 : 0

  name        = "${var.task_definition_family}-ecs-permissions"
  description = "Permissions for ${var.task_definition_family} ECS Service to interact with AWS Resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = var.allowed_actions
        Resource = var.allowed_resources
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_permissions" {
  count = length(var.allowed_actions) > 0 ? 1 : 0

  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_permissions[0].arn
}



