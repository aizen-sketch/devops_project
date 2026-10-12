variable "repository_names" {
  description = "List of ECR repository names to create"
  type        = list(string)
  default = [
    "taskapp-user-service",
    "taskapp-task-service",
    "taskapp-notification-service",
    "taskapp-frontend"
  ]
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed"
  type        = bool
  default     = true
}

variable "max_image_count" {
  description = "Number of images to retain before expiration via lifecycle policy"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to attach to the repositories"
  type        = map(string)
  default     = {}
}
