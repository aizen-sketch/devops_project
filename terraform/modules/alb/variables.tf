variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where ALB is deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security Group ID for the ALB"
  type        = string
}

variable "enable_https" {
  description = "Whether to enable HTTPS listener (requires acm_certificate_arn)"
  type        = bool
  default     = false
}

variable "acm_certificate_arn" {
  description = "Optional ACM Certificate ARN for HTTPS listener"
  type        = string
  default     = ""
}

variable "enable_access_logs" {
  description = "Whether to send ALB access logs to S3"
  type        = bool
  default     = false
}

variable "logs_bucket_id" {
  description = "Optional S3 bucket ID for ALB access logs"
  type        = string
  default     = ""
}

variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API"
  type        = bool
  default     = false
}
