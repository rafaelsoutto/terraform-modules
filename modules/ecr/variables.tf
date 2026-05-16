variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "my-ecr-repo"
}

variable "image_tag_mutability" {
  description = "Image tag mutability for the ECR repository"
  type        = string
  default     = "IMMUTABLE"
}

variable "enable_scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for repository encryption. If null, AWS managed key is used."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the ECR repository"
  type        = map(string)
  default     = {}
}

variable "untagged_image_expiry_days" {
  description = "Days after which untagged images are removed"
  type        = number
  default     = 14
}

variable "tagged_image_count" {
  description = "Maximum number of images to retain (oldest removed first)"
  type        = number
  default     = 30
}