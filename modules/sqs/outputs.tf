output "queue_arns" {
  description = "ARNs of the main SQS queues"
  value       = { for k, v in aws_sqs_queue.main_terraform_queue : k => v.arn }
}

output "queue_names" {
  description = "Names of the main SQS queues"
  value       = { for k, v in aws_sqs_queue.main_terraform_queue : k => v.name }
}
output "queue_dlq" {
  description = "Names of the main SQS queues"
  value       = { for k, v in aws_sqs_queue.terraform_queue_deadletter : k => v.name }
}
output "queue_urls" {
  description = "URLs of the main SQS queues"
  value       = { for k, v in aws_sqs_queue.main_terraform_queue : k => v.url }
}


output "dlq_arns" {
  description = "ARNs of the dead letter queues"
  value       = { for k, v in aws_sqs_queue.terraform_queue_deadletter : k => v.arn }
}


output "dlq_queue_urls" {
  description = "URLs of the dead letter queues"
  value       = { for k, v in aws_sqs_queue.terraform_queue_deadletter : k => v.url }
}


output "dlq_names" {
  value = { for k, v in aws_sqs_queue.terraform_queue_deadletter : k => v.name }
}
