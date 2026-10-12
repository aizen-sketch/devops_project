output "distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.frontend.id
}

output "distribution_arn" {
  description = "The ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.frontend.arn
}

output "distribution_domain_name" {
  description = "The domain name corresponding to the distribution (e.g. d111111abcdef8.cloudfront.net)"
  value       = aws_cloudfront_distribution.frontend.domain_name
}

output "distribution_hosted_zone_id" {
  description = "CloudFront Route 53 Zone ID (always Z2FDTNDATAQYW2)"
  value       = aws_cloudfront_distribution.frontend.hosted_zone_id
}
