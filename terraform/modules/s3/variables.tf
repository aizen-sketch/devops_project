variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "force_destroy" {
  description = "Whether to allow bucket deletion even if non-empty (useful for dev/staging teardown)"
  type        = bool
  default     = true
}
