
output "dynamodb_table_arn" {
  description = "dynamodb table fleet status arn"
  value       = aws_dynamodb_table.fleet_status.arn
}

output "table_name" {
  description = "name of table"
  value       = aws_dynamodb_table.fleet_status.name
}
