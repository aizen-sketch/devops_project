output "aws_lb_controller_role_arn" {
  description = "IAM Role ARN for AWS Load Balancer Controller"
  value       = aws_iam_role.aws_lb_controller.arn
}

output "app_secrets_role_arn" {
  description = "IAM Role ARN for EKS workloads to access AWS Secrets Manager"
  value       = aws_iam_role.app_secrets.arn
}
