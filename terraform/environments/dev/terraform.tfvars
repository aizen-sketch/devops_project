project_name = "cloudops-taskapp"
environment  = "dev"
aws_region   = "us-east-1"

vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

public_subnet_cidrs      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_app_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
private_db_subnet_cidrs  = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

single_nat_gateway   = true # Cost optimization for dev
enable_vpc_endpoints = true

cluster_version    = "1.30"
eks_instance_types = ["t3.medium"]
eks_desired_size   = 2
eks_min_size       = 2
eks_max_size       = 4

db_name           = "taskmanagement"
db_username       = "postgresadmin"
db_instance_class = "db.t4g.medium"
db_multi_az       = false # Single AZ for dev
db_port           = 5432

create_custom_domain_records = false # Set true once Route 53 domain is active
