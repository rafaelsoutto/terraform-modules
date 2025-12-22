variable "name_prefix" {
  type        = string
  description = "Prefix for naming resources"
}

variable "vpc_name" {
  type        = string
  description = "VPC name for the ALB and target groups"
}

variable "internal" {
  type        = bool
  default     = false
  description = "Whether the ALB is internal or internet-facing"
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

variable "routing_rules" {
  description = "Map of listener rules to create"
  type = map(object({
    target_group_port = number
    target_group_protocol = string
    health_check_path = string
    health_check_port = number
    target_group_target_type = string
    listener_port  = number
    listener_protocol = string
    listener_certificate_arn = string
    listener_rule_path_patterns = list(string)
    listener_rule_priority = number
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