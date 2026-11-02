output "organization_id" {
  description = "The AWS Organization ID"
  value       = aws_organizations_organization.org.id
}

output "root_id" {
  description = "The Root OU ID of the organization"
  value       = aws_organizations_organization.org.roots[0].id
}

output "ou_core_id" {
  description = "Core Organizational Unit ID"
  value       = aws_organizations_organizational_unit.core.id
}

output "ou_security_id" {
  description = "Security Organizational Unit ID"
  value       = aws_organizations_organizational_unit.security.id
}

output "ou_workloads_id" {
  description = "Workloads Organizational Unit ID"
  value       = aws_organizations_organizational_unit.workloads.id
}

output "ou_workloads_prod_id" {
  description = "Workloads Production OU ID"
  value       = aws_organizations_organizational_unit.workloads_prod.id
}

output "ou_workloads_dev_id" {
  description = "Workloads Development OU ID"
  value       = aws_organizations_organizational_unit.workloads_dev.id
}

output "ou_sandbox_id" {
  description = "Sandbox OU ID"
  value       = aws_organizations_organizational_unit.sandbox.id
}
