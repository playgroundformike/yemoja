# alarms.tf
resource "aws_cloudwatch_metric_alarm" "dlq_depth" {
  for_each = module.sqs.dlq_names

  alarm_name          = "${var.project_name}-${var.environment}-${each.key}-dlq-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Messages in ${each.key} DLQ - processing failures detected"
  alarm_actions       = [aws_sns_topic.dlq_alarms.arn]

  dimensions = {
    QueueName = each.value
  }

}

# sns alarms

resource "aws_sns_topic" "dlq_alarms" {
  name = "${var.project_name}-${var.environment}-dlq-alarms"
}

resource "aws_sns_topic_subscription" "email" {

  for_each  = toset(var.alert_emails)
  topic_arn = aws_sns_topic.dlq_alarms.arn
  protocol  = "email"
  endpoint  = each.value

}
