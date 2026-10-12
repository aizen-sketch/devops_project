# Random Master Password for RDS
resource "random_password" "master_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.project_name}/${var.environment}/rds/credentials"
  description             = "Master credentials for RDS database instance"
  kms_key_id              = var.kms_key_id != "" ? var.kms_key_id : null
  recovery_window_in_days = 0 # Force deletion for dev/re-apply if needed

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-secret"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    engine   = "postgres"
    username = var.db_username
    password = random_password.master_password.result
    dbname   = var.db_name
  })
}
