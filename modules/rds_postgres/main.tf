locals {
  allowed_ips = length(var.allowed_ips) > 0 ? var.allowed_ips : [var.network.vpc_cidr]
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.db_name}-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = var.network.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = local.allowed_ips
    description = "Allow PostgreSQL access from specified IPs"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS for AWS services"
  }

  tags = {
    Name = "${var.db_name}-rds-sg"
  }
}

resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${var.db_name}-rds-password"
  description             = "Database password for ${var.db_name}"
  kms_key_id              = var.secrets_kms_key_id
  recovery_window_in_days = 14

  tags = {
    Name = "${var.db_name}-rds-password"
  }
}

resource "aws_secretsmanager_secret_rotation" "db_password_rotation" {
  count              = var.enable_secret_rotation ? 1 : 0
  secret_id          = aws_secretsmanager_secret.db_password.id
  rotation_rules {
    automatically_after_days = var.secret_rotation_days
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_-"
}

resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.password.result
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "${var.db_name}-subnet-group"
  description = "Subnet group for RDS ${var.db_name}"
  subnet_ids  = var.network.private_subnet_ids

  tags = {
    Name = "${var.db_name}-subnet-group"
  }
}

resource "aws_db_instance" "postgres" {
  allocated_storage            = var.allocated_storage
  engine                       = "postgres"
  engine_version               = var.engine_version
  instance_class               = var.instance_class
  db_name                      = var.db_name
  username                     = var.db_username
  password                     = aws_secretsmanager_secret_version.db_password_version.secret_string
  parameter_group_name         = var.parameter_group_name
  skip_final_snapshot          = false
  identifier                   = var.db_name
  final_snapshot_identifier    = "${var.db_name}-final-snapshot"
  publicly_accessible          = var.publicly_accessible
  storage_encrypted            = var.storage_encrypted
  kms_key_id                   = var.storage_encrypted && var.kms_key_id != null ? var.kms_key_id : null
  deletion_protection          = var.deletion_protection
  backup_retention_period      = var.backup_retention_period
  copy_tags_to_snapshot        = var.copy_tags_to_snapshot
  multi_az                     = var.multi_az
  iam_database_authentication_enabled = var.enable_iam_database_authentication
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  performance_insights_enabled = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_enabled && var.performance_insights_kms_key_id != null ? var.performance_insights_kms_key_id : null
  monitoring_interval          = var.monitoring_interval
  monitoring_role_arn          = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring_role[0].arn : null
  vpc_security_group_ids       = [aws_security_group.rds_sg.id]
  db_subnet_group_name         = aws_db_subnet_group.rds_subnet_group.name

  enabled_cloudwatch_logs_exports = var.enable_cloudwatch_logs ? ["postgresql"] : []

  depends_on = [
    aws_secretsmanager_secret_version.db_password_version
  ]

  tags = {
    Name = "${var.db_name}"
  }
}

# IAM role for RDS monitoring (when monitoring_interval > 0)
resource "aws_iam_role" "rds_monitoring_role" {
  count = var.monitoring_interval > 0 ? 1 : 0
  name  = "${var.db_name}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.db_name}-rds-monitoring-role"
  }
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_policy" {
  count      = var.monitoring_interval > 0 ? 1 : 0
  role       = aws_iam_role.rds_monitoring_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

