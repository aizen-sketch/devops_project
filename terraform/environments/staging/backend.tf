# terraform {
#   backend "s3" {
#     bucket         = "taskapp-terraform-state-staging"
#     key            = "environments/staging/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "taskapp-terraform-locks-staging"
#     encrypt        = true
#   }
# }
