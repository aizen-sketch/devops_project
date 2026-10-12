# ==============================================================================
# 1. DB Subnet Group (Private Database Subnets Across Multi-AZ)
# ==============================================================================
resource "aws_db_subnet_group" "main" {
  name        = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids  = var.private_db_subnet_ids
  description = "Private database subnet group for ${var.project_name} ${var.environment}"

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-subnet-group"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ==============================================================================
# 2. RDS Parameter Group
# ==============================================================================
resource "aws_db_parameter_group" "main" {
  name        = "${var.project_name}-${var.environment}-pg"
  family      = "postgres16"
  description = "Parameter group for PostgreSQL 16"

  parameter {
    name  = "rds.force_ssl"
    value = "1" # Force SSL in transit
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-pg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ==============================================================================
# 3. RDS Instance (Strictly Private, Encrypted at Rest)
# ==============================================================================
resource "aws_db_instance" "main" {
  identifier     = "${var.project_name}-${var.environment}-db"
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_security_group_id]
  parameter_group_name   = aws_db_parameter_group.main.name

  publicly_accessible = false # Strictly isolated from the public internet
  multi_az            = var.multi_az

  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "Sun:04:30-Sun:05:30"

  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false
  deletion_protection         = var.deletion_protection
  skip_final_snapshot         = var.skip_final_snapshot
  final_snapshot_identifier   = var.skip_final_snapshot ? null : "${var.project_name}-${var.environment}-db-final-snapshot"

  tags = {
    Name        = "${var.project_name}-${var.environment}-db"
    Environment = var.environment
    Project     = var.project_name
  }
}
