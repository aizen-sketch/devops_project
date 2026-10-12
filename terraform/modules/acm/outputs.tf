output "certificate_arn" {
  description = "The ARN of the ACM certificate"
  value       = try(aws_acm_certificate.cert[0].arn, "")
}

output "domain_validation_options" {
  description = "Domain validation options for DNS record creation"
  value       = try(aws_acm_certificate.cert[0].domain_validation_options, [])
}
