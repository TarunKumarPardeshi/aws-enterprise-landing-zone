variable "environment" {
  description = "Target deployment environment"
  type        = string
  default     = "prod"
}

variable "github_organization_or_user" {
  description = "GitHub username or organization allowed to assume this role"
  type        = string
  default     = "TarunKumarPardeshi"
}

variable "github_branch" {
  description = "Whitelisted Git branch trigger"
  type        = string
  default     = "main"
}
