


data "archive_file" "lambda" {
  type        = var.type
  source_dir  = var.source_file
  output_path = var.output_path
}

resource "aws_lambda_function" "telemetry_lambda" {
  function_name = var.function_name
  role          = aws_iam_role.iam_for_lambda.arn

  # code config
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  handler          = var.handler
  runtime          = var.runtime
  timeout          = var.timeout
  memory_size      = var.mem_size

  environment {
    variables = var.env_variables
  }

}


resource "aws_lambda_event_source_mapping" "sqs-source-mapping" {
  event_source_arn = var.event_source_arn
  function_name    = aws_lambda_function.telemetry_lambda.function_name

  tags = {
    Name = "sqs-source-mapping"
  }
}

# policy to allow lambda to assume role
resource "aws_iam_role" "iam_for_lambda" {
  name               = "${var.function_name}-iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


# policy with permissions for sqs and cloudwatch
data "aws_iam_policy_document" "base_policy" {
  statement {
    sid    = "SQSAccess"
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [var.event_source_arn]
  }

  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

}

resource "aws_iam_policy" "telemetry_lambda_base_policy" {
  name        = "${var.function_name}-base-policy"
  description = "base_policy"
  policy      = data.aws_iam_policy_document.base_policy.json
}

resource "aws_iam_role_policy_attachment" "base_attach" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.telemetry_lambda_base_policy.arn
}


# policy with permissions for sqs and cloudwatch
data "aws_iam_policy_document" "custom_policy" {
  count = length(var.custom_policy_actions) > 0 ? 1 : 0
  statement {
    effect    = "Allow"
    actions   = var.custom_policy_actions
    resources = var.custom_policy_resources
  }
}

resource "aws_iam_policy" "telemetry_lambda_custom_policy" {
  count       = length(var.custom_policy_actions) > 0 ? 1 : 0
  name        = "${var.function_name}-custom-policy"
  description = "telemetry-lambda-custom-policy"
  policy      = data.aws_iam_policy_document.custom_policy[0].json
}

resource "aws_iam_role_policy_attachment" "custom_attach" {
  count      = length(var.custom_policy_actions) > 0 ? 1 : 0
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.telemetry_lambda_custom_policy[0].arn
}
