
terraform {
  backend "s3" {
    bucket         = "tfstate-management-582071018932-us-east-1"
    key            = "yemoja/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}