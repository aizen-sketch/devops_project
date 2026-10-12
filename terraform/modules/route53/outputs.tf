output "frontend_fqdn" {
  description = "FQDN of the frontend Route 53 record"
  value       = try(aws_route53_record.frontend[0].fqdn, "")
}

output "api_fqdn" {
  description = "FQDN of the backend API Route 53 record"
  value       = try(aws_route53_record.api[0].fqdn, "")
}
