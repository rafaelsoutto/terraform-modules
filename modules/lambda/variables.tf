variable "force_redeploy" {
  description = "Value that when changed will force Lambda redeployment"
  type        = string
  default     = "initial"
}

variable "ephemeral_storage_size" {
  description = "Ephemeral storage size in MB"
  type        = number
  default     = 512
}

variable "lambda_layers" {
  description = "List of Lambda layers to attach"
  type        = list(string)
  default     = []
}

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "test"
}

variable "handler" {
  description = "Lambda function handler"
  type        = string
  default     = "handler.lambda_handler"
}

variable "runtime" {
  description = "Lambda runtime environment"
  type        = string
  default     = "python3.12"
}

variable "source_path" {
  description = "Path to the function source code"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for the Lambda"
  type        = map(string)
  default     = {}
}

variable "timeout" {
  description = "Lambda execution timeout in seconds"
  type        = number
  default     = 3
}

variable "memory_size" {
  description = "Memory allocation in MB"
  type        = number
  default     = 128
}

variable "vpc_config" {
  description = "VPC configuration for Lambda"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "additional_policy_statements" {
  description = "Additional IAM policy statements for the Lambda role"
  type        = list(any)
  default     = []
}

variable "is_sqs_triggered" {
  description = "Whether the Lambda should be triggered by an SQS queue"
  type        = bool
  default     = false
}

variable "sqs_queue_arn" {
  description = "ARN of the SQS queue to trigger the Lambda"
  type        = string
  default     = null
}

variable "sqs_batch_size" {
  description = "Number of records to process in each batch"
  type        = number
  default     = 10
}

variable "sqs_max_concurrency" {
  description = "Maximum number of concurrent instances of the Lambda"
  type        = number
  default     = 5
}