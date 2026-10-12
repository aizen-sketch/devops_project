variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs to place NAT Gateways in"
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "Set to true to deploy a single NAT Gateway (recommended for dev/staging cost savings), or false for 1 per AZ (production HA)"
  type        = bool
  default     = false
}
