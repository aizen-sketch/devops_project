output "frontend_bucket_id" {
  description = "The ID/Name of the frontend S3 bucket"
  value       = aws_s3_bucket.frontend.id
}

output "frontend_bucket_arn" {
  description = "The ARN of the frontend S3 bucket"
  value       = aws_s3_bucket.frontend.arn
}

output "frontend_bucket_regional_domain_name" {
  description = "Regional domain name of the frontend S3 bucket for CloudFront origin"
  value       = aws_s3_bucket.frontend.bucket_regional_domain_name
}

output "logs_bucket_id" {
  description = "The ID/Name of the logs S3 bucket"
  value       = aws_s3_bucket.logs.id
}

output "logs_bucket_arn" {
  description = "The ARN of the logs S3 bucket"
  value       = aws_s3_bucket.logs.arn
}
