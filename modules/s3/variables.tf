# variables.tf
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
  default     = false
}

variable "enable_server_side_encryption" {
  description = "Enable server-side encryption for the S3 bucket"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to apply to the S3 bucket"
  type        = map(string)
  default     = {}
}