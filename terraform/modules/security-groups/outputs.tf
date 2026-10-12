output "alb_security_group_id" {
  description = "Security Group ID of the public Application Load Balancer"
  value       = aws_security_group.alb.id
}

output "eks_cluster_security_group_id" {
  description = "Security Group ID of the EKS control plane"
  value       = aws_security_group.eks_cluster.id
}

output "eks_nodes_security_group_id" {
  description = "Security Group ID of the EKS worker nodes"
  value       = aws_security_group.eks_nodes.id
}

output "rds_security_group_id" {
  description = "Security Group ID of the private RDS database"
  value       = aws_security_group.rds.id
}

output "vpc_endpoints_security_group_id" {
  description = "Security Group ID of the VPC Endpoints"
  value       = aws_security_group.vpc_endpoints.id
}
