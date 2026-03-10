output "bucket_arn" {
  description = "Arn of telemetry data bucket"
  value       = aws_s3_bucket.telemetry_data_bucket.arn
}

output "bucket_name" {
  description = "String name of telemetry data bucket"
  value       = aws_s3_bucket.telemetry_data_bucket.bucket
}



