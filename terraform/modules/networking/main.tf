# ==============================================================================
# Amazon VPC
# ==============================================================================
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name                                        = "${var.project_name}-${var.environment}-vpc"
    Environment                                 = var.environment
    Project                                     = var.project_name
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# ==============================================================================
# Public Subnets (Tier 1: Internet-facing ALB & NAT Gateways)
# ==============================================================================
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "${var.project_name}-${var.environment}-public-${var.availability_zones[count.index]}"
    Environment                                 = var.environment
    Tier                                        = "Public"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# ==============================================================================
# Private Application Subnets (Tier 2: EKS Worker Nodes & Application Pods)
# ==============================================================================
resource "aws_subnet" "private_app" {
  count                   = length(var.private_app_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_app_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name                                        = "${var.project_name}-${var.environment}-private-app-${var.availability_zones[count.index]}"
    Environment                                 = var.environment
    Tier                                        = "Private-App"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# ==============================================================================
# Private Database Subnets (Tier 3: Isolated RDS Datastores)
# ==============================================================================
resource "aws_subnet" "private_db" {
  count                   = length(var.private_db_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_db_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-db-${var.availability_zones[count.index]}"
    Environment = var.environment
    Tier        = "Private-DB"
  }
}
