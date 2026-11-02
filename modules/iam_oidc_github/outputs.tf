output "oidc_provider_arn" {
  description = "ARN of GitHub Actions OIDC Provider"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "deployer_role_arn" {
  description = "ARN of the scoped IAM Role for GitHub Actions runners"
  value       = aws_iam_role.github_actions_deployer.arn
}
