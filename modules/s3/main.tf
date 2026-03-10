# modules/s3

resource "aws_s3_bucket" "telemetry_data_bucket" {
  bucket = var.bucket_name

}


resource "aws_s3_bucket_versioning" "telemetry_data_bucket_versioning" {
  bucket = aws_s3_bucket.telemetry_data_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "telemetry_data_bucket_public_access" {
  bucket = aws_s3_bucket.telemetry_data_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
