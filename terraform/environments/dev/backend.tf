terraform {
  backend "s3" {
    bucket         = "ecommerce-terraform-state-2025"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ecommerce-terraform-locks"
    encrypt        = true
  }
}
