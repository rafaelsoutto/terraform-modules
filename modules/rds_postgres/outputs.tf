output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.postgres.endpoint
}

output "db_password_secret_arn" {
  description = "The ARN of the secret storing the database password"
  value       = aws_secretsmanager_secret.db_password.arn
}
