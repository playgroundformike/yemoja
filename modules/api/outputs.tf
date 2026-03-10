output "telemetry_api_arn" {
  description = "ARN of api gateway"
  value       = aws_apigatewayv2_api.telemetry_api.arn
}

output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = aws_apigatewayv2_api.telemetry_api.api_endpoint
}


output "telemetry_api_id" {
  value = aws_apigatewayv2_api.telemetry_api.id
}
