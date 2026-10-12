variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where route tables will be created"
  type        = string
}

variable "internet_gateway_id" {
  description = "Internet Gateway ID for public routes"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs to associate with public route table"
  type        = list(string)
}

variable "nat_gateway_ids" {
  description = "List of NAT Gateway IDs for private application outbound traffic"
  type        = list(string)
}

variable "private_app_subnet_ids" {
  description = "List of private application subnet IDs to associate with private route tables"
  type        = list(string)
}

variable "private_db_subnet_ids" {
  description = "List of private database subnet IDs to associate with isolated DB route table"
  type        = list(string)
}
