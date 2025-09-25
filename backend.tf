terraform {
  backend "s3" {
    bucket         = "innovatemart-terraform-state-12f7148b"
    key            = "innovatemart/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "innovatemart-terraform-locks"
    encrypt        = true
  }
}
