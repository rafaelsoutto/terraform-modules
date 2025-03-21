variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "mydatabase"
}

variable "db_username" {
  description = "The database admin username"
  type        = string
  default     = "postgres"
}

variable "allocated_storage" {
  description = "The amount of allocated storage (GB)"
  type        = number
  default     = 20
}

variable "engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "17.1"
}

variable "instance_class" {
  description = "Instance class for RDS"
  type        = string
  default     = "db.t4g.micro"  # Free-tier eligible
}

variable "parameter_group_name" {
  description = "RDS parameter group name"
  type        = string
  default     = "default.postgres17"
}

variable "publicly_accessible" {
  description = "Should the database be publicly accessible?"
  type        = bool
  default     = false
}

variable "storage_encrypted" {
  description = "Enable storage encryption?"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "The VPC ID where the RDS instance will be deployed"
  type        = string
}

variable "allowed_ips" {
  description = "List of IPs allowed to connect to RDS (in CIDR format)"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Default: Open to all (not recommended)
}

variable "backup_retention_period" {
  description = "The number of days to retain backups for"
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Enable deletion protection for the RDS instance"
  type        = bool
  default     = true
}

variable "subnet_ids" {
  description = "List of subnet IDs where the RDS instance should be deployed"
  type        = list(string)
}