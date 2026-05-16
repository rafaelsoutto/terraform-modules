variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "region" {
  description = "The AWS region where the S3 bucket will be created"
  type        = string
  default     = "us-east-1"
}

variable "enable_versioning" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "enable_server_side_encryption" {
  description = "Enable server-side encryption for the S3 bucket"
  type        = bool
  default     = true
}

variable "kms_master_key_id" {
  description = "KMS key ID for S3 bucket encryption. If null, AWS managed key (aws/s3) is used."
  type        = string
  default     = null
}

variable "enable_access_logging" {
  description = "Enable access logging for the S3 bucket"
  type        = bool
  default     = true
}

variable "logging_target_bucket" {
  description = "Target bucket for access logs. Required if enable_access_logging is true."
  type        = string
  default     = null
}

variable "logging_target_prefix" {
  description = "Prefix for access logs"
  type        = string
  default     = "logs/"
}

variable "enable_lifecycle_configuration" {
  description = "Enable lifecycle configuration for the S3 bucket"
  type        = bool
  default     = false
}

variable "lifecycle_rules" {
  description = "Lifecycle rules for the S3 bucket"
  type = list(object({
    id            = string
    enabled       = bool
    prefix        = string
    expiration_days = number
  }))
  default = []
}

variable "cloudfront_distribution_arn" {
  description = "ARN of a CloudFront distribution allowed to read this bucket via OAC. When set, a bucket policy granting CloudFront access is created."
  type        = string
  default     = null
}

variable "enable_replication" {
  description = "Enable cross-region replication"
  type        = bool
  default     = false
}

variable "replication_destination_bucket" {
  description = "Destination bucket for replication. Required if enable_replication is true."
  type        = string
  default     = null
}

variable "enable_event_notifications" {
  description = "Enable event notifications for the S3 bucket"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to apply to the S3 bucket"
  type        = map(string)
  default     = {}
}