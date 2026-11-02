variable "approved_regions" {
  description = "Whitelisted AWS regions permitted for operational workloads"
  type        = list(string)
  default     = ["ca-central-1", "us-east-1"]
}

variable "target_ou_workloads_id" {
  description = "Target OU ID to attach mandatory guardrails"
  type        = string
}

variable "security_admin_role_arn" {
  description = "Central Security Admin IAM role exempted from specific administrative blocks"
  type        = string
  default     = "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*/AWSReservedSSO_SecurityAdmin_*"
}
