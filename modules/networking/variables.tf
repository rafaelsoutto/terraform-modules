data "aws_availability_zones" "available" {
  state = "available"
}

variable "vpc_cidr" {
  description = "value of the VPC CIDR block"
  type        = string
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "custom-vpc"
}

variable "instance_tenancy" {
  description = "Tenancy of the VPC instances"
  type        = string
  default     = "default"
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = false
}

variable "enable_network_address_usage_metrics" {
  description = "Enable network address usage metrics"
  type        = bool
  default     = false
}

variable "assign_generated_ipv6_cidr_block" {
  description = "Assign a generated IPv6 CIDR block to the VPC"
  type        = bool
  default     = false
}

variable "subnet_pairs" {
  description = "Number of subnet pairs to create (for public and private subnets)"
  type        = number
  default     = 3
}

variable "map_public_ip_on_launch" {
  description = "Map public IP on launch for public subnets"
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Whether to enable VPC flow logs"
  type        = bool
  default     = false
}

variable "flow_logs_traffic_type" {
  description = "Traffic type for flow logs (ACCEPT, REJECT, ALL)"
  type        = string
  default     = "ALL"
}

variable "flow_log_s3_bucket_arn" {
  description = "ARN of S3 bucket for flow logs (required if destination is s3)"
  type        = string
  default     = ""
}

variable "flow_log_destination_type" {
  description = "Destination type for flow logs (cloudwatch or s3)"
  type        = string
  default     = "cloudwatch"
  validation {
    condition     = contains(["cloudwatch", "s3"], var.flow_log_destination_type)
    error_message = "Flow log destination must be either 'cloudwatch' or 's3'."
  }
}

variable "flow_log_retention_days" {
  description = "Retention days for flow logs (only applicable if destination is cloudwatch)"
  type        = number
  default     = 7
}

variable "nat_connectivity_type" {
  description = "Connectivity type for NAT Gateway (public or private)"
  type        = string
  default     = "public"
  validation {
    condition     = contains(["public", "private"], var.nat_connectivity_type)
    error_message = "NAT connectivity type must be either 'public' or 'private'."
  }
}