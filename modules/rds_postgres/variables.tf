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
  description = "Enable storage encryption at rest (KMS encryption)"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for RDS encryption. If null, AWS managed key is used."
  type        = string
  default     = null
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

variable "allowed_ips" {
  description = "CIDRs allowed to connect to RDS. Defaults to VPC CIDR when empty."
  type        = list(string)
  default     = []
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

variable "performance_insights_enabled" {
  description = "Enable performance insights for the RDS instance"
  type        = bool
  default     = true
}

variable "performance_insights_kms_key_id" {
  description = "KMS key ID for Performance Insights encryption. If null, AWS managed key is used."
  type        = string
  default     = null
}

variable "monitoring_interval" {
  description = "The interval (in seconds) for enhanced monitoring. 0 to disable."
  type        = number
  default     = 60
}

variable "enable_iam_database_authentication" {
  description = "Enable IAM database authentication"
  type        = bool
  default     = true
}

variable "multi_az" {
  description = "Enable Multi-AZ for the RDS instance"
  type        = bool
  default     = true
}

variable "copy_tags_to_snapshot" {
  description = "Copy tags to snapshots"
  type        = bool
  default     = true
}

variable "enable_cloudwatch_logs" {
  description = "Enable exporting PostgreSQL logs to CloudWatch"
  type        = bool
  default     = true
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
}

variable "secrets_kms_key_id" {
  description = "KMS key ID for Secrets Manager encryption. If null, AWS managed key is used."
  type        = string
  default     = null
}

variable "enable_secret_rotation" {
  description = "Enable automatic secret rotation"
  type        = bool
  default     = true
}

variable "secret_rotation_days" {
  description = "Number of days between automatic secret rotations"
  type        = number
  default     = 30
}