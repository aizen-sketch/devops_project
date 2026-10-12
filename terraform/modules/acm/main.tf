resource "aws_acm_certificate" "cert" {
  count                     = var.create_certificate ? 1 : 0
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-acm-cert"
    Environment = var.environment
    Project     = var.project_name
  }
}
