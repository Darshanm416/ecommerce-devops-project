terraform {
  backend "s3" {
    bucket         = "ecommerce-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ecommerce-terraform-lock"
    encrypt        = true
  }
}
