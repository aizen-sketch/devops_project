variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "private_db_subnet_ids" {
  description = "List of private database subnet IDs"
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "Security Group ID for RDS instance"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "taskmanagement"
}

variable "db_username" {
  description = "Master username for database"
  type        = string
}

variable "db_password" {
  description = "Master password for database"
  type        = string
  sensitive   = true
}

variable "allocated_storage" {
  description = "Allocated storage in gigabytes"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage limit for autoscaling in gigabytes (20 for Free Tier)"
  type        = number
  default     = 20
}

variable "instance_class" {
  description = "RDS instance class (db.t4g.micro is Free Tier eligible)"
  type        = string
  default     = "db.t4g.micro"
}

variable "engine" {
  description = "Database engine"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "16.3"
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ (true for prod, false for dev cost-savings)"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "The days to retain backups for (1 day maximum for AWS Free Tier accounts)"
  type        = number
  default     = 1
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before deleting (true for dev teardown)"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled"
  type        = bool
  default     = false
}
