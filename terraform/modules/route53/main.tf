# Frontend Alias Record -> CloudFront
resource "aws_route53_record" "frontend" {
  count   = var.create_dns_records && var.frontend_subdomain != "" ? 1 : 0
  zone_id = var.hosted_zone_id
  name    = var.frontend_subdomain
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

# API Alias Record -> Application Load Balancer
resource "aws_route53_record" "api" {
  count   = var.create_dns_records && var.api_subdomain != "" ? 1 : 0
  zone_id = var.hosted_zone_id
  name    = var.api_subdomain
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
