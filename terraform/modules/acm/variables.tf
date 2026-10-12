variable "create_certificate" {
  description = "Whether to create the ACM certificate (set to false if not using a custom domain)"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Primary domain name for the certificate (e.g. example.com or *.example.com)"
  type        = string
  default     = ""
}

variable "subject_alternative_names" {
  description = "List of SAN domains (e.g. app.example.com, api.example.com)"
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}
