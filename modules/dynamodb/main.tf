resource "aws_dynamodb_table" "fleet_status" {
  name         = "${var.project_name}-${var.environment}-fleet-status"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "vehicle_id"
  range_key    = "timestamp"

  attribute {
    name = "vehicle_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }
}
