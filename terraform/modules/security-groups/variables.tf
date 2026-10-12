variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "db_port" {
  description = "Port used by the RDS database (5432 for Postgres, 3306 for MySQL)"
  type        = number
  default     = 5432
}
