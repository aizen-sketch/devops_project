output "secret_id" {
  description = "The ID of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.db_credentials.id
}

output "secret_arn" {
  description = "The ARN of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "secret_name" {
  description = "The friendly name of the secret"
  value       = aws_secretsmanager_secret.db_credentials.name
}

output "db_password" {
  description = "The generated database master password"
  value       = random_password.master_password.result
  sensitive   = true
}

output "db_username" {
  description = "The master username"
  value       = var.db_username
}

output "db_name" {
  description = "The database name"
  value       = var.db_name
}
