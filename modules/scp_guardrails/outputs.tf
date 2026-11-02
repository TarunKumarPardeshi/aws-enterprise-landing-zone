output "policy_deny_unapproved_regions_id" {
  description = "SCP Policy ID for unapproved regions restriction"
  value       = aws_organizations_policy.deny_unapproved_regions.id
}

output "policy_deny_root_user_id" {
  description = "SCP Policy ID for root user restriction"
  value       = aws_organizations_policy.deny_root_user.id
}

output "policy_protect_sec_infra_id" {
  description = "SCP Policy ID protecting security tools"
  value       = aws_organizations_policy.protect_security_infrastructure.id
}

output "policy_s3_guardrails_id" {
  description = "SCP Policy ID for S3 guardrails"
  value       = aws_organizations_policy.enforce_s3_guardrails.id
}
