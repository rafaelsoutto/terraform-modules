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

variable "allowed_resources" {
  description = "List of allowed resources for the Lambda function"
  type        = list(string)
  default     = []
}

variable "allowed_actions" {
  description = "List of allowed actions for the Lambda function"
  type        = list(string)
  default     = []
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

variable "scheduled_trigged" {
  description = "Whether the Lambda should be triggered by a schedule"
  type        = bool
  default     = false
}

variable "schedule_expression" {
  description = "Schedule expression for the Lambda trigger (e.g., rate(5 minutes))"
  type        = string
  default     = null
}

variable "enable_xray_tracing" {
  description = "Enable AWS X-Ray tracing for the Lambda function"
  type        = bool
  default     = true
}

variable "enable_dead_letter_queue" {
  description = "Enable Dead Letter Queue for failed Lambda executions"
  type        = bool
  default     = true
}

variable "dlq_arn" {
  description = "ARN of the SQS queue to use as DLQ. Required if enable_dead_letter_queue is true."
  type        = string
  default     = null
}

variable "kms_key_arn" {
  description = "KMS key ARN for environment variable encryption. If null, AWS managed key is used."
  type        = string
  default     = null
}

variable "reserved_concurrent_executions" {
  description = "Amount of concurrency available for this function. -1 (default) removes the limit."
  type        = number
  default     = -1
}

variable "enable_code_signing" {
  description = "Enable code signing for the Lambda function"
  type        = bool
  default     = false
}

variable "code_signing_config_arn" {
  description = "ARN of the code signing configuration. Required if enable_code_signing is true."
  type        = string
  default     = null
}

variable "network" {
  description = "Network context from the networking module. When set, Lambda runs inside the VPC."
  type = object({
    vpc_id             = string
    vpc_cidr           = string
    public_subnet_ids  = list(string)
    private_subnet_ids = list(string)
  })
  default = null
}

variable "vpc_security_group_ids" {
  description = "Security group IDs for the Lambda VPC config. Required when network is set."
  type        = list(string)
  default     = []
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