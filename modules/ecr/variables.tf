variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "my-ecr-repo"
}

variable "image_tag_mutability" {
  description = "Image tag mutability for the ECR repository"
  type        = string
  default     = "MUTABLE"
}

variable "tags" {
  description = "Tags to apply to the ECR repository"
  type        = map(string)
  default     = {}
}

variable "is_private" {
  description = "Whether the ECR repository is private"
  type        = bool
  default     = true
}