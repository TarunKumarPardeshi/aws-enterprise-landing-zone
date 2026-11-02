output "organization_id" {
  description = "AWS Organization ID"
  value       = module.organizations.organization_id
}

output "ou_workloads_id" {
  description = "Workloads OU ID"
  value       = module.organizations.ou_workloads_id
}

output "github_oidc_role_arn" {
  description = "IAM Role ARN for GitHub Actions workflows"
  value       = module.iam_oidc_github.deployer_role_arn
}
