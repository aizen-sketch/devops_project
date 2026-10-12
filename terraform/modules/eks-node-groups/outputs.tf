output "node_group_id" {
  description = "EKS Node Group ID"
  value       = aws_eks_node_group.main.id
}

output "node_group_arn" {
  description = "EKS Node Group ARN"
  value       = aws_eks_node_group.main.arn
}

output "node_role_arn" {
  description = "IAM Role ARN attached to EKS worker nodes"
  value       = aws_iam_role.node.arn
}
