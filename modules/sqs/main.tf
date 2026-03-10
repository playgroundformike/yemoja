# /sqs/main.tf

resource "aws_sqs_queue" "main_terraform_queue" {

  for_each = toset(["ALERTING", "ARCHIVAL", "DASHBOARD"])

  name                      = "${var.project_name}-${var.environment}-${each.key}-sqs"
  delay_seconds             = var.delay_seconds
  max_message_size          = var.max_message_size
  message_retention_seconds = var.message_retention_seconds
  receive_wait_time_seconds = var.receive_wait_time_seconds
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.terraform_queue_deadletter[each.key].arn
    maxReceiveCount     = 4
  })

  visibility_timeout_seconds = var.visibility_timeout_seconds

  tags = {
    purpose = "${each.key}-sqs"
  }
}


#  DLQ
resource "aws_sqs_queue" "terraform_queue_deadletter" {
  for_each = toset(["ALERTING", "ARCHIVAL", "DASHBOARD"])
  name     = "${var.project_name}-${var.environment}-${each.key}-sqs-dlq"
}

resource "aws_sqs_queue_redrive_allow_policy" "terraform_queue_redrive_allow_policy" {
  for_each  = toset(["ALERTING", "ARCHIVAL", "DASHBOARD"])
  queue_url = aws_sqs_queue.terraform_queue_deadletter[each.key].id
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.main_terraform_queue[each.key].arn]
  })
}

