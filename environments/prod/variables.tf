variable "aws_region" {
  description = "Primary AWS management region"
  type        = string
  default     = "ca-central-1"
}

variable "environment" {
  description = "Target environment"
  type        = string
  default     = "prod"
}

variable "approved_regions" {
  description = "Permitted sovereign regions"
  type        = list(string)
  default     = ["ca-central-1", "us-east-1"]
}

variable "github_user" {
  description = "GitHub account holding the repository"
  type        = string
  default     = "TarunKumarPardeshi"
}
