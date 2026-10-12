variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "postgresadmin"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "taskmanagement"
}

variable "kms_key_id" {
  description = "Optional KMS Key ID to encrypt the secret (defaults to aws/secretsmanager)"
  type        = string
  default     = ""
}
