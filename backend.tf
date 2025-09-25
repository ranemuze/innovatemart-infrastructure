# Terraform Backend Configuration
terraform {
  backend "s3" {
    # These values will be provided via backend-config during terraform init
    # bucket = "innovatemart-terraform-state"
    # key    = "innovatemart/terraform.tfstate"
    # region = "eu-west-1"
    
    # Enable state locking and consistency checking
    dynamodb_table = "innovatemart-terraform-locks"
    encrypt        = true
    
    # Workspace configuration
    workspace_key_prefix = "env"
  }
}