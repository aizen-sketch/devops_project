output "s3_endpoint_id" {
  description = "ID of the S3 Gateway VPC Endpoint"
  value       = try(aws_vpc_endpoint.s3[0].id, null)
}

output "interface_endpoint_ids" {
  description = "Map of Interface VPC Endpoint IDs"
  value       = { for k, v in aws_vpc_endpoint.interface : k => v.id }
}
