resource "aws_iam_role" "lambda_exec" {
  name = "${var.function_name}-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_additional_permissions" {
  count = length(var.allowed_actions) > 0 ? 1 : 0

  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_permissions[0].arn
}

resource "aws_iam_policy" "lambda_permissions" {
  count = length(var.allowed_actions) > 0 ? 1 : 0

  name        = "${var.function_name}-permissions"
  description = "Permissions for ${var.function_name} to interact with AWS Resources"

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

resource "aws_iam_role_policy_attachment" "lambda_permissions" {
  count = var.is_sqs_triggered ? 1 : 0

  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_permissions[0].arn
}

