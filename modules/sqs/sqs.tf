locals {
  is_fifo     = var.queue_type == "FIFO"
  fifo_suffix = local.is_fifo ? ".fifo" : ""
  queue_name  = endswith(var.queue_name, ".fifo") ? var.queue_name : "${var.queue_name}${local.fifo_suffix}"
  dlq_name    = endswith(var.queue_name, ".fifo") ? "${trimsuffix(var.queue_name, ".fifo")}-dlq.fifo" : "${var.queue_name}-dlq${local.fifo_suffix}"
}

resource "aws_sqs_queue" "dlq" {
  count = var.enable_dlq ? 1 : 0

  name                       = local.dlq_name
  fifo_queue                 = local.is_fifo
  message_retention_seconds  = var.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout

  kms_master_key_id                 = var.enable_encryption ? (var.kms_master_key_id != null ? var.kms_master_key_id : "alias/aws/sqs") : null
  kms_data_key_reuse_period_seconds = var.enable_encryption ? var.kms_data_key_reuse_period_seconds : null
}

resource "aws_sqs_queue" "this" {
  name                        = local.queue_name
  fifo_queue                  = local.is_fifo
  content_based_deduplication = local.is_fifo ? var.content_based_deduplication : null
  delay_seconds               = var.delay_seconds
  max_message_size            = var.max_message_size
  message_retention_seconds   = var.message_retention_seconds
  receive_wait_time_seconds   = var.receive_wait_time_seconds
  visibility_timeout_seconds   = var.visibility_timeout

  kms_master_key_id                 = var.enable_encryption ? (var.kms_master_key_id != null ? var.kms_master_key_id : "alias/aws/sqs") : null
  kms_data_key_reuse_period_seconds = var.enable_encryption ? var.kms_data_key_reuse_period_seconds : null

  redrive_policy = var.enable_dlq ? jsonencode({
    dead_letter_target_arn = aws_sqs_queue.dlq[0].arn
    max_receive_count      = var.max_receive_count
  }) : null
}
