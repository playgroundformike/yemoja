output "eventbus_arn" {
  description = "arn of cloudwatch eventbus"
  value       = aws_cloudwatch_event_bus.telemetry_event_bus.arn
}
output "eventbus_name" {
  description = "name of cloudwatch eventbus"
  value       = aws_cloudwatch_event_bus.telemetry_event_bus.name
}
output "eventbus_target_arn" {
  description = "Arn of eventbus target to sns resource"
  value       = aws_cloudwatch_event_target.sns.arn
}

output "eventbus_rule_arn" {
  description = "resource arn for eventbus telemetry rule"
  value       = aws_cloudwatch_event_rule.telemetry_event_bus_rule.arn
}

