variable "queue_name" {
  description = "Name of the SQS queue. FIFO queues must end in .fifo"
  type        = string
  default     = "my-queue"
}

variable "queue_type" {
  description = "Type of the SQS queue (Standard or FIFO)"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "FIFO"], var.queue_type)
    error_message = "queue_type must be Standard or FIFO."
  }
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication (FIFO queues only)"
  type        = bool
  default     = false
}

variable "visibility_timeout" {
  description = "Visibility timeout in seconds"
  type        = number
  default     = 30
}

variable "delay_seconds" {
  description = "Delay before messages become available in seconds"
  type        = number
  default     = 0
}

variable "max_message_size" {
  description = "Maximum message size in bytes"
  type        = number
  default     = 262144 # 256 KB
}

variable "message_retention_seconds" {
  description = "How long messages are retained in seconds"
  type        = number
  default     = 345600 # 4 days
}

variable "receive_wait_time_seconds" {
  description = "Long-polling wait time in seconds"
  type        = number
  default     = 0
}

variable "enable_dlq" {
  description = "Create a dead-letter queue for messages that fail processing"
  type        = bool
  default     = true
}

variable "max_receive_count" {
  description = "Number of times a message is received before being moved to the DLQ"
  type        = number
  default     = 3
}

variable "enable_encryption" {
  description = "Enable encryption for the SQS queue"
  type        = bool
  default     = true
}

variable "kms_master_key_id" {
  description = "KMS key ID for queue encryption. If null, AWS managed key (alias/aws/sqs) is used."
  type        = string
  default     = null
}

variable "kms_data_key_reuse_period_seconds" {
  description = "Length of time (in seconds) for which SQS can reuse a KMS data key"
  type        = number
  default     = 300
}
