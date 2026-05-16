output "queue_url" {
  description = "URL of the SQS queue"
  value       = aws_sqs_queue.this.url
}

output "queue_arn" {
  description = "ARN of the SQS queue"
  value       = aws_sqs_queue.this.arn
}

output "queue_name" {
  description = "Name of the SQS queue (includes .fifo suffix for FIFO queues)"
  value       = aws_sqs_queue.this.name
}

output "dlq_arn" {
  description = "ARN of the dead-letter queue (null when enable_dlq is false)"
  value       = var.enable_dlq ? aws_sqs_queue.dlq[0].arn : null
}

output "dlq_url" {
  description = "URL of the dead-letter queue (null when enable_dlq is false)"
  value       = var.enable_dlq ? aws_sqs_queue.dlq[0].url : null
}
