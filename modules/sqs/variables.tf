variable "queue_name" {
  description = "Name of the SQS queue"
  type        = string
  default     = "my-queue"
}

variable "queue_type" {
  description = "Type of the SQS queue (Standard or FIFO)"
  type        = string
  default     = "Standard"
}

variable "visibility_timeout" {
  description = "Visibility timeout for the SQS queue in seconds"
  type        = number
  default     = 30
}

variable "delay_seconds" {
  description = "Delay seconds for the SQS queue"
  type        = number
  default     = 0
}

variable "max_message_size" {
  description = "Maximum message size for the SQS queue in bytes"
  type        = number
  default     = 262144  # 256 KB
}

variable "message_retention_seconds" {
  description = "Message retention period for the SQS queue in seconds"
  type        = number
  default     = 345600  # 4 days
}

variable "receive_wait_time_seconds" {
  description = "Receive wait time for the SQS queue in seconds"
  type        = number
  default     = 0
}
