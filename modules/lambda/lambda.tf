data "archive_file" "lambda_source" {
  type        = "zip"
  source_dir  = var.source_path
  output_path = "${path.module}/function.zip"
}

resource "aws_lambda_function" "this" {
  filename      = "${path.module}/function.zip"
  function_name = var.function_name
  role          = aws_iam_role.lambda_exec.arn
  handler       = var.handler
  runtime       = var.runtime
  timeout       = var.timeout
  memory_size   = var.memory_size
  layers        = var.lambda_layers


  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  ephemeral_storage {
    size = var.ephemeral_storage_size
  }

  environment {
    variables = var.environment_variables
  }

  source_code_hash = filebase64sha256(data.archive_file.lambda_source.output_path)

  lifecycle {
    ignore_changes = [
      source_code_hash,
      last_modified
    ]
  }
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  count = var.is_sqs_triggered ? 1 : 0

  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.this.arn
  batch_size       = var.sqs_batch_size

  scaling_config {
    maximum_concurrency = var.sqs_max_concurrency
  }

  depends_on = [aws_lambda_function.this]
}


resource "aws_cloudwatch_event_rule" "scheduled_event" {
  count = var.scheduled_trigged && var.schedule_expression != null ? 1 : 0

  name                = "${var.function_name}-scheduled-event"
  description         = "Scheduled event for ${var.function_name}"
  schedule_expression = var.schedule_expression

  tags = {
    Name = "${var.function_name}-scheduled-event"
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_events" {
  count = var.scheduled_trigged && var.schedule_expression != null ? 1 : 0

  statement_id  = "AllowExecutionFromCloudWatchEvents-${var.function_name}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scheduled_event[count.index].arn

  depends_on = [aws_lambda_function.this]
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  count = var.scheduled_trigged && var.schedule_expression != null ? 1 : 0

  rule      = aws_cloudwatch_event_rule.scheduled_event[count.index].name
  target_id = "${var.function_name}-target"
  arn       = aws_lambda_function.this.arn
}