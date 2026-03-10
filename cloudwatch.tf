resource "aws_cloudwatch_dashboard" "fleet_telemetry" {
  dashboard_name = "${var.project_name}-${var.environment}-fleet-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "API Gateway"
          region = var.aws_region
          metrics = [
            ["AWS/ApiGateway", "Count", "ApiId", module.api_gateway.telemetry_api_id],
            ["AWS/ApiGateway", "4xx", "ApiId", module.api_gateway.telemetry_api_id],
            ["AWS/ApiGateway", "5xx", "ApiId", module.api_gateway.telemetry_api_id],
            ["AWS/ApiGateway", "Latency", "ApiId", module.api_gateway.telemetry_api_id, { "stat" : "Average" }]
          ]
          period = 300
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "EventBridge - Events"
          region = var.aws_region
          metrics = [
            ["AWS/Events", "MatchedEvents", "EventBusName", "${var.project_name}-${var.environment}-telemetry-eventbus"],
            ["AWS/Events", "Events", "EventBusName", "${var.project_name}-${var.environment}-telemetry-eventbus"],
            ["AWS/Events", "FailedInvocations", "EventBusName", "${var.project_name}-${var.environment}-telemetry-eventbus"],
          ]
          period = 300
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "Alerting SQS widget"
          region = var.aws_region
          metrics = [
            ["AWS/SQS", "NumberOfMessagesSent", "QueueName", module.sqs.queue_names["ALERTING"]],
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", module.sqs.queue_names["ALERTING"]],
            ["AWS/SQS", "ApproximateAgeOfOldestMessage", "QueueName", module.sqs.queue_names["ALERTING"]],
          ]
          period = 300
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "ARCHIVAL SQS widget"
          region = var.aws_region
          metrics = [
            ["AWS/SQS", "NumberOfMessagesSent", "QueueName", module.sqs.queue_names["ARCHIVAL"]],
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", module.sqs.queue_names["ARCHIVAL"]],
            ["AWS/SQS", "ApproximateAgeOfOldestMessage", "QueueName", module.sqs.queue_names["ARCHIVAL"]],
          ]
          period = 300
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          title  = "DASHBOARD SQS widget"
          region = var.aws_region
          metrics = [
            ["AWS/SQS", "NumberOfMessagesSent", "QueueName", module.sqs.queue_names["DASHBOARD"]],
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", module.sqs.queue_names["DASHBOARD"]],
            ["AWS/SQS", "ApproximateAgeOfOldestMessage", "QueueName", module.sqs.queue_names["DASHBOARD"]],
          ]
          period = 300
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          title  = "DLQ - Message Depth (should be 0)"
          region = var.aws_region
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", module.sqs.dlq_names["ALERTING"]],
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", module.sqs.dlq_names["ARCHIVAL"]],
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", module.sqs.dlq_names["DASHBOARD"]]
          ]
          period = 300
          stat   = "Maximum"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 18
        width  = 12
        height = 6
        properties = {
          title  = "Lambda Alert"
          region = var.aws_region
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", module.lambda_alert.lambda_function_name],
            ["AWS/Lambda", "Errors", "FunctionName", module.lambda_alert.lambda_function_name],
            ["AWS/Lambda", "Duration", "FunctionName", module.lambda_alert.lambda_function_name, { "stat" : "Average" }],
            ["AWS/Lambda", "Throttles", "FunctionName", module.lambda_alert.lambda_function_name],
            ["AWS/Lambda", "ConcurrentExecutions", "FunctionName", module.lambda_alert.lambda_function_name],
          ]
          period = 300
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 18
        width  = 12
        height = 6
        properties = {
          title  = "Lambda Dashboard"
          region = var.aws_region
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", module.lambda_dashboard.lambda_function_name],
            ["AWS/Lambda", "Errors", "FunctionName", module.lambda_dashboard.lambda_function_name],
            ["AWS/Lambda", "Duration", "FunctionName", module.lambda_dashboard.lambda_function_name, { "stat" : "Average" }],
            ["AWS/Lambda", "Throttles", "FunctionName", module.lambda_dashboard.lambda_function_name],
            ["AWS/Lambda", "ConcurrentExecutions", "FunctionName", module.lambda_dashboard.lambda_function_name],
          ]
          period = 300
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 24
        width  = 12
        height = 6
        properties = {
          title  = "Lambda Archive"
          region = var.aws_region
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", module.lambda_archive.lambda_function_name],
            ["AWS/Lambda", "Errors", "FunctionName", module.lambda_archive.lambda_function_name],
            ["AWS/Lambda", "Duration", "FunctionName", module.lambda_archive.lambda_function_name, { "stat" : "Average" }],
            ["AWS/Lambda", "Throttles", "FunctionName", module.lambda_archive.lambda_function_name],
            ["AWS/Lambda", "ConcurrentExecutions", "FunctionName", module.lambda_archive.lambda_function_name],
          ]
          period = 300
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 24
        width  = 12
        height = 6
        properties = {
          title  = "DynamoDB + S3"
          region = var.aws_region
          metrics = [
            ["AWS/DynamoDB", "SuccessfulRequestLatency", "TableName", module.dynamodb_telemetry.table_name],
            ["AWS/DynamoDB", "ThrottledRequests", "TableName", module.dynamodb_telemetry.table_name]
          ]
          period = 300
          stat   = "Sum"
        }
      },

    ]
  })
}
