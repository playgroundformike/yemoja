# sns/outputs.tf

output "sns_topic_arn" {
  description = "ARNs of sns topic"
  value       = aws_sns_topic.telemetry_data_sns_topic.arn
}

output "sns_sub_arns" {
  description = "ARNs of sns subscription resources"
  value       = { for k, v in aws_sns_topic_subscription.telemetry_data_sns_subscription : k => v.arn }
}
