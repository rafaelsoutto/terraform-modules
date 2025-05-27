resource "aws_security_group" "rds_sg" {
  name        = "${var.db_name}-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.allowed_ips
    description = "Allow PostgreSQL access from specified IPs"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.db_name}-rds-sg"
  }
}

resource "aws_secretsmanager_secret" "db_password" {
  name        = "${var.db_name}-rds-password"
  description = "Database password for ${var.db_name}"

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
  subnet_ids  = var.subnet_ids

  tags = {
    Name = "${var.db_name}-subnet-group"
  }
}

resource "aws_db_instance" "postgres" {
  allocated_storage       = var.allocated_storage
  engine                  = "postgres"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  performance_insights_enabled = var.performance_insights_enabled
  monitoring_interval     = var.monitoring_interval
  db_name                 = var.db_name
  username                = var.db_username
  password                = aws_secretsmanager_secret_version.db_password_version.secret_string
  parameter_group_name    = var.parameter_group_name
  skip_final_snapshot     = false
  identifier              = var.db_name
  final_snapshot_identifier = "${var.db_name}-final-snapshot"
  publicly_accessible     = var.publicly_accessible
  storage_encrypted       = var.storage_encrypted
  deletion_protection     = var.deletion_protection
  backup_retention_period = var.backup_retention_period
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name

}

