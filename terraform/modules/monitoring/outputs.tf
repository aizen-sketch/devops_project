output "eks_log_group_name" {
  description = "Name of the CloudWatch log group for EKS control plane"
  value       = var.create_eks_log_group ? aws_cloudwatch_log_group.eks_cluster[0].name : "/aws/eks/${var.cluster_name}/cluster"
}

output "app_log_group_name" {
  description = "Name of the CloudWatch log group for microservices"
  value       = aws_cloudwatch_log_group.applications.name
}

output "alerts_sns_topic_arn" {
  description = "ARN of the SNS topic for alarm notifications"
  value       = aws_sns_topic.alerts.arn
}
