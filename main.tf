# main.tf
module "sqs" {
  source                    = "./modules/sqs"
  project_name              = var.project_name
  environment               = var.environment
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}

module "sns" {
  source       = "./modules/sns"
  project_name = var.project_name
  environment  = var.environment
  queue_arns   = module.sqs.queue_arns
  queue_urls   = module.sqs.queue_urls
}

module "eventbridge" {
  source        = "./modules/eventbridge"
  project_name  = var.project_name
  environment   = var.environment
  sns_topic_arn = module.sns.sns_topic_arn
}


module "lambda_alert" {
  source           = "./modules/lambda"
  project_name     = var.project_name
  environment      = var.environment
  function_name    = "${var.project_name}-${var.environment}-telemetry-alert"
  source_file      = "${path.module}/lambda/alert_handler"
  output_path      = "${path.module}/lambda/packages/alert_handler.zip"
  event_source_arn = module.sqs.queue_arns["ALERTING"]

  # custom_policy_actions   = ["sns:Publish"]
  # custom_policy_resources = [module.sns.alert_topic_arn]
}

module "lambda_dashboard" {
  source           = "./modules/lambda"
  project_name     = var.project_name
  environment      = var.environment
  function_name    = "${var.project_name}-${var.environment}-telemetry-dashboard"
  source_file      = "${path.module}/lambda/dashboard_handler"
  output_path      = "${path.module}/lambda/packages/dashboard_handler.zip"
  event_source_arn = module.sqs.queue_arns["DASHBOARD"]


  custom_policy_actions   = ["dynamodb:PutItem"]
  custom_policy_resources = [module.dynamodb_telemetry.dynamodb_table_arn]
  env_variables = {
    DYNAMODB_TABLE_NAME = module.dynamodb_telemetry.table_name
  }

}

module "lambda_archive" {
  source                  = "./modules/lambda"
  project_name            = var.project_name
  environment             = var.environment
  function_name           = "${var.project_name}-${var.environment}-telemetry-archive"
  source_file             = "${path.module}/lambda/archive_handler/"
  output_path             = "${path.module}/lambda/packages/archive_handler.zip"
  event_source_arn        = module.sqs.queue_arns["ARCHIVAL"]
  custom_policy_actions   = ["s3:PutObject"]
  custom_policy_resources = ["${module.s3_telemetry.bucket_arn}/*"]
  env_variables           = { BUCKET_NAME = module.s3_telemetry.bucket_name }
}

module "s3_telemetry" {
  source      = "./modules/s3"
  bucket_name = "${var.project_name}-${var.environment}-telemetry-archive"

}

module "dynamodb_telemetry" {
  source       = "./modules/dynamodb"
  project_name = var.project_name
  environment  = var.environment
}


module "api_gateway" {
  source         = "./modules/api"
  project_name   = var.project_name
  environment    = var.environment
  event_bus_arn  = module.eventbridge.eventbus_arn
  event_bus_name = module.eventbridge.eventbus_name
}
