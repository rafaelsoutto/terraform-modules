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
  description = "Map of listener rules with target group configs"
  type = map(object({
    priority          = number
    path_patterns     = list(string)
    target_port       = number
    health_check_path = string
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