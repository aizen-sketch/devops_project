# terraform {
#   backend "s3" {
#     bucket         = "taskapp-terraform-state-prod"
#     key            = "environments/prod/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "taskapp-terraform-locks-prod"
#     encrypt        = true
#   }
# }
