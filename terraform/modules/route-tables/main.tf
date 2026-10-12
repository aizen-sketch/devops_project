# ==============================================================================
# 1. Public Route Table (Outbound to Internet Gateway)
# ==============================================================================
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-rt"
    Environment = var.environment
    Tier        = "Public"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_ids)
  subnet_id      = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public.id
}

# ==============================================================================
# 2. Private Application Route Tables (Outbound via NAT Gateways)
# ==============================================================================
resource "aws_route_table" "private_app" {
  count  = length(var.private_app_subnet_ids)
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = length(var.nat_gateway_ids) == 1 ? var.nat_gateway_ids[0] : var.nat_gateway_ids[count.index]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-app-rt-${count.index + 1}"
    Environment = var.environment
    Tier        = "Private-App"
  }
}

resource "aws_route_table_association" "private_app" {
  count          = length(var.private_app_subnet_ids)
  subnet_id      = var.private_app_subnet_ids[count.index]
  route_table_id = aws_route_table.private_app[count.index].id
}

# ==============================================================================
# 3. Private Database Route Table (Completely Isolated - NO Internet Route)
# ==============================================================================
resource "aws_route_table" "private_db" {
  vpc_id = var.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-db-rt"
    Environment = var.environment
    Tier        = "Private-DB"
  }
}

resource "aws_route_table_association" "private_db" {
  count          = length(var.private_db_subnet_ids)
  subnet_id      = var.private_db_subnet_ids[count.index]
  route_table_id = aws_route_table.private_db.id
}
