# ==============================================================================
# 1. S3 Gateway Endpoint (Free & keeps S3 traffic off NAT Gateways)
# ==============================================================================
resource "aws_vpc_endpoint" "s3" {
  count             = var.enable_vpc_endpoints ? 1 : 0
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.route_table_ids

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpce-s3"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ==============================================================================
# 2. Interface Endpoints (ECR, CloudWatch Logs, STS, Secrets Manager)
# ==============================================================================
locals {
  interface_services = {
    ecr_api = "com.amazonaws.${var.aws_region}.ecr.api"
    ecr_dkr = "com.amazonaws.${var.aws_region}.ecr.dkr"
    logs    = "com.amazonaws.${var.aws_region}.logs"
    sts     = "com.amazonaws.${var.aws_region}.sts"
    secrets = "com.amazonaws.${var.aws_region}.secretsmanager"
  }
}

resource "aws_vpc_endpoint" "interface" {
  for_each = var.enable_vpc_endpoints ? local.interface_services : {}

  vpc_id              = var.vpc_id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = var.security_group_ids
  private_dns_enabled = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpce-${each.key}"
    Environment = var.environment
    Project     = var.project_name
  }
}
