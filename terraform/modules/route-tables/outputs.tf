output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_app_route_table_ids" {
  description = "List of IDs of private application route tables"
  value       = aws_route_table.private_app[*].id
}

output "private_db_route_table_id" {
  description = "The ID of the isolated private database route table"
  value       = aws_route_table.private_db.id
}
