output "lambda_function_arn" {
  value = aws_lambda_function.telemetry_lambda.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.telemetry_lambda.function_name
}

output "sqs-source-mapping" {
  value = aws_lambda_event_source_mapping.sqs-source-mapping.uuid
}
