variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where endpoints will be created"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs where Interface VPC Endpoints will be deployed (private app subnets)"
  type        = list(string)
}

variable "route_table_ids" {
  description = "Route Table IDs to associate with Gateway VPC Endpoints (S3)"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security Group IDs to attach to Interface VPC Endpoints"
  type        = list(string)
}

variable "enable_vpc_endpoints" {
  description = "Toggle to enable or disable VPC endpoints (save costs in dev, enable for prod/security compliance)"
  type        = bool
  default     = true
}
