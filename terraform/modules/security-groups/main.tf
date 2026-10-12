# ==============================================================================
# 1. Application Load Balancer Security Group (Public Entrypoint)
# ==============================================================================
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security group for internet-facing Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_security_group_rule" "alb_http_inbound" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
  description       = "Allow inbound HTTP for redirection to HTTPS"
}

resource "aws_security_group_rule" "alb_https_inbound" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
  description       = "Allow inbound HTTPS from the internet"
}

# ==============================================================================
# 2. EKS Cluster Control Plane Security Group
# ==============================================================================
resource "aws_security_group" "eks_cluster" {
  name        = "${var.project_name}-${var.environment}-eks-cluster-sg"
  description = "Security group for EKS control plane API server"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-eks-cluster-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ==============================================================================
# 3. EKS Worker Nodes Security Group (Private Compute)
# ==============================================================================
resource "aws_security_group" "eks_nodes" {
  name        = "${var.project_name}-${var.environment}-eks-nodes-sg"
  description = "Security group for EKS worker nodes and pod network"
  vpc_id      = var.vpc_id

  tags = {
    Name                                                           = "${var.project_name}-${var.environment}-eks-nodes-sg"
    Environment                                                    = var.environment
    Project                                                        = var.project_name
    "kubernetes.io/cluster/${var.project_name}-${var.environment}" = "owned"
  }
}

# Node <-> Node (Intra-cluster communication for Pods)
resource "aws_security_group_rule" "nodes_internal" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.eks_nodes.id
  description              = "Allow all internal pod-to-pod and node-to-node traffic"
}

# ALB -> Nodes (Allows ALB to reach backend pods or NodePorts)
resource "aws_security_group_rule" "nodes_from_alb" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.eks_nodes.id
  description              = "Allow traffic from ALB to pods / target groups"
}

# Cluster Control Plane -> Nodes (Kubelet, metrics, exec)
resource "aws_security_group_rule" "nodes_from_cluster" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_cluster.id
  security_group_id        = aws_security_group.eks_nodes.id
  description              = "Allow EKS control plane to communicate with kubelet"
}

resource "aws_security_group_rule" "nodes_from_cluster_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_cluster.id
  security_group_id        = aws_security_group.eks_nodes.id
  description              = "Allow control plane to manage webhook/extension pods"
}

# Nodes -> Cluster Control Plane
resource "aws_security_group_rule" "cluster_from_nodes" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.eks_cluster.id
  description              = "Allow worker nodes to reach Kubernetes API server"
}

# Node Egress (Allow outbound to NAT GW / VPC Endpoints)
resource "aws_security_group_rule" "nodes_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_nodes.id
  description       = "Allow all outbound traffic from worker nodes"
}

# ALB Egress to Nodes
resource "aws_security_group_rule" "alb_egress_to_nodes" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.alb.id
  description              = "Allow ALB to forward requests to worker nodes / pods"
}

# Cluster Egress to Nodes
resource "aws_security_group_rule" "cluster_egress" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.eks_cluster.id
  description              = "Allow EKS cluster to reach worker nodes"
}

# ==============================================================================
# 4. Amazon RDS Database Security Group (Strictly Private)
# ==============================================================================
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Security group for private RDS database instance"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_security_group_rule" "rds_from_nodes" {
  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.rds.id
  description              = "Allow database access STRICTLY from EKS application workloads"
}

resource "aws_security_group_rule" "rds_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds.id
  description       = "Allow outbound database responses"
}

# ==============================================================================
# 5. VPC Endpoints Security Group
# ==============================================================================
resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.project_name}-${var.environment}-vpce-sg"
  description = "Security group for internal AWS VPC Interface Endpoints"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpce-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_security_group_rule" "vpce_from_nodes" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.vpc_endpoints.id
  description              = "Allow HTTPS from EKS nodes to private VPC endpoints"
}

resource "aws_security_group_rule" "vpce_from_vpc" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.vpc_endpoints.id
  description       = "Allow HTTPS from VPC CIDR to private VPC endpoints"
}
