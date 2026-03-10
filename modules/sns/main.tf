
# sns/main.tf


# EventBridge to Topic
resource "aws_sns_topic" "telemetry_data_sns_topic" {
  name = "${var.project_name}-${var.environment}-telemetry-fanout"
}




# Subscription to multiple SQS Queues
resource "aws_sns_topic_subscription" "telemetry_data_sns_subscription" {
  for_each  = var.queue_arns
  topic_arn = aws_sns_topic.telemetry_data_sns_topic.arn
  protocol  = "sqs"
  endpoint  = each.value
}

resource "aws_sqs_queue_policy" "main_terraform_queue_policy" {
  for_each  = var.queue_urls
  queue_url = each.value
  policy    = data.aws_iam_policy_document.main_terraform_queue_doc[each.key].json
}

data "aws_iam_policy_document" "main_terraform_queue_doc" {
  for_each = var.queue_arns
  statement {
    sid    = "Resource Policy to allow SNS to access SQS queue"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.telemetry_data_sns_topic.arn]
    }

    actions   = ["sqs:SendMessage"]
    resources = [each.value]
  }
}

