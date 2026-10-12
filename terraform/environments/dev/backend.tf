# Terraform Remote State Configuration
# In production, state should be stored in an S3 bucket with DynamoDB state locking.
# To enable remote backend, uncomment the block below and replace with your S3 bucket & DynamoDB table.

terraform {
  backend "s3" {
    bucket         = "taskapp-terraform-state-dev"
    key            = "environments/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "taskapp-terraform-locks-dev"
    encrypt        = true
  }
}
