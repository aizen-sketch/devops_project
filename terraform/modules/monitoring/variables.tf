variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the ALB for CloudWatch metrics"
  type        = string
  default     = ""
}

variable "db_instance_id" {
  description = "RDS DB instance identifier for CloudWatch metrics"
  type        = string
  default     = ""
}

variable "enable_rds_alarm" {
  description = "Whether to create CloudWatch metric alarm for RDS CPU utilization"
  type        = bool
  default     = true
}

variable "enable_alb_alarm" {
  description = "Whether to create CloudWatch metric alarm for ALB 5XX errors"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "create_eks_log_group" {
  description = "Whether to create CloudWatch log group for EKS control plane (default false to prevent ResourceAlreadyExistsException and reduce logging cost)"
  type        = bool
  default     = false
}
