
terraform {
  backend "s3" {
    bucket         = "tfstate-management-XXX-us-east-1" # Replace XXX with your account ID
    key            = "yemoja/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
