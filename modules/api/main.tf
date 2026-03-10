resource "aws_apigatewayv2_api" "telemetry_api" {
  name          = "telemetry-api"
  protocol_type = "HTTP"
}


resource "aws_apigatewayv2_integration" "telemetry_api" {
  api_id              = aws_apigatewayv2_api.telemetry_api.id
  description         = "EventBridge telemetry_api"
  integration_type    = "AWS_PROXY"
  integration_subtype = "EventBridge-PutEvents"
  credentials_arn     = aws_iam_role.api_gateway_role.arn
  request_parameters = {
    "Source"       = "yemoja.telemetry"
    "DetailType"   = "AUV Telemetry Event"
    "Detail"       = "$request.body"
    "EventBusName" = var.event_bus_name
  }


}

resource "aws_apigatewayv2_route" "telemetry_api_route" {
  api_id    = aws_apigatewayv2_api.telemetry_api.id
  route_key = "POST /telemetry"
  target    = "integrations/${aws_apigatewayv2_integration.telemetry_api.id}"
}


resource "aws_apigatewayv2_stage" "api_deploy" {
  api_id      = aws_apigatewayv2_api.telemetry_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_iam_role" "api_gateway_role" {
  name               = "${var.project_name}-${var.environment}-apigw-eventbridge-role"
  assume_role_policy = data.aws_iam_policy_document.apigw_assume_role.json
}

data "aws_iam_policy_document" "apigw_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "api_policy" {
  name        = "${var.project_name}-${var.environment}-test-policy"
  path        = "/"
  description = "policy"
  policy      = data.aws_iam_policy_document.event_policy.json
}


data "aws_iam_policy_document" "event_policy" {
  statement {
    effect = "Allow"
    sid    = "AllowApiGatewayPutEvents"

    actions   = ["events:PutEvents"]
    resources = [var.event_bus_arn]
  }
}

resource "aws_iam_role_policy_attachment" "apigw_eventbridge" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = aws_iam_policy.api_policy.arn
}
