variable "name_prefix" {
  type        = string
  description = "Prefix for naming resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the ALB and target groups"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet IDs for the ALB"
}

variable "ingress_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of CIDRs allowed to access the ALB"
}

variable "target_type" {
  type        = string
  default     = "ip" # or "instance"
  description = "Target type for the target groups"
}

variable "listener_rules" {
  description = "Map of listener rules to create"
  type = map(object({
    priority           = number
    health_check_path  = string
    target_port        = number
    path_patterns      = list(string)
    additional_conditions = optional(list(object({
      field  = string
      values = list(string)
      http_header_name = optional(string)
    })), [])
  }))
}

variable "tags" {
  type    = map(string)
  default = {}
}


variable "certificate_arn" {
  type        = string
  description = "ARN of the SSL certificate for HTTPS listeners"
  default     = ""
}

variable "health_check_port" {
  type        = number
  description = "Port for health checks, defaults to target port if not specified"
  default     = null
}

variable "target_group_arn" {
  type        = string
  description = "ARN of the ALB listener to attach target groups to"
  default     = ""
}