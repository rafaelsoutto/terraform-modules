variable "name_prefix" {
  type        = string
  description = "Prefix for naming resources"
}

variable "network" {
  description = "Network context from the networking module"
  type = object({
    vpc_id             = string
    vpc_cidr           = string
    public_subnet_ids  = list(string)
    private_subnet_ids = list(string)
  })
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
  default     = null
}

variable "health_check_port" {
  type        = number
  description = "Port for health checks, defaults to target port if not specified"
  default     = null
}

variable "target_group_arn" {
  type        = string
  description = "ARN of the ALB listener to attach target groups to"
  default     = null
}

variable "enable_deletion_protection" {
  type        = bool
  description = "Enable deletion protection for the ALB"
  default     = true
}

variable "enable_access_logs" {
  type        = bool
  description = "Enable access logging for the ALB"
  default     = true
}

variable "access_logs_s3_bucket" {
  type        = string
  description = "S3 bucket for ALB access logs. Required if enable_access_logs is true."
  default     = null
}

variable "access_logs_s3_prefix" {
  type        = string
  description = "Prefix for ALB access logs in S3"
  default     = "alb-logs"
}

variable "ssl_policy" {
  type        = string
  description = "SSL policy for HTTPS listeners. Should enforce TLS 1.2+"
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "enable_http_to_https_redirect" {
  type        = bool
  description = "Enable automatic redirect from HTTP to HTTPS"
  default     = true
}

variable "waf_arn" {
  type        = string
  description = "ARN of WAFv2 WebACL to attach to the ALB"
  default     = null
}

variable "is_internal" {
  type        = bool
  description = "Whether the ALB is internal or internet-facing"
  default     = true
}

variable "loadbalancer_type" {
  type        = string
  description = "Type of load balancer (application or network)"
  default     = "application"
}