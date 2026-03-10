# modules/eventbridge

resource "aws_cloudwatch_event_bus" "telemetry_event_bus" {
  name        = "${var.project_name}-${var.environment}-telemetry-eventbus"
  description = "Event bus for example telemetry events"
}


resource "aws_cloudwatch_event_rule" "telemetry_event_bus_rule" {
  name           = "telemetry-event-rule"
  event_bus_name = aws_cloudwatch_event_bus.telemetry_event_bus.name
  description    = "Capture Telemetry data"
  event_pattern = jsonencode({
    source      = ["yemoja.telemetry"]
    detail-type = ["AUV Telemetry Event"]
  })
}

# send to sns
resource "aws_cloudwatch_event_target" "sns" {
  event_bus_name = aws_cloudwatch_event_bus.telemetry_event_bus.name
  rule           = aws_cloudwatch_event_rule.telemetry_event_bus_rule.name
  target_id      = "SendToSNS"
  arn            = var.sns_topic_arn
}


# sns resource policy
resource "aws_sns_topic_policy" "telemetry_data_sns_topic_policy" {
  arn    = var.sns_topic_arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Publish",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [
      var.sns_topic_arn,
    ]

    sid = "__default_statement_ID"
  }
}
