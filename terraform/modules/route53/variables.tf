variable "create_dns_records" {
  description = "Whether to create Route 53 DNS records (requires existing hosted zone)"
  type        = bool
  default     = false
}

variable "hosted_zone_id" {
  description = "Route 53 Hosted Zone ID"
  type        = string
  default     = ""
}

variable "frontend_subdomain" {
  description = "Subdomain for the frontend (e.g. app.example.com)"
  type        = string
  default     = ""
}

variable "api_subdomain" {
  description = "Subdomain for the backend API (e.g. api.example.com)"
  type        = string
  default     = ""
}

variable "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  type        = string
  default     = ""
}

variable "cloudfront_zone_id" {
  description = "CloudFront hosted zone ID (always Z2FDTNDATAQYW2)"
  type        = string
  default     = "Z2FDTNDATAQYW2"
}

variable "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  type        = string
  default     = ""
}

variable "alb_zone_id" {
  description = "Application Load Balancer hosted zone ID"
  type        = string
  default     = ""
}
