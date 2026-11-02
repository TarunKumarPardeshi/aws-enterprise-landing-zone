terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 1. AWS Organizations & Organizational Unit Hierarchy
module "organizations" {
  source = "../../modules/organizations"
}

# 2. Preventative SCP Guardrails
module "scp_guardrails" {
  source                 = "../../modules/scp_guardrails"
  target_ou_workloads_id = module.organizations.ou_workloads_id
  approved_regions       = var.approved_regions
}

# 3. GitHub Actions Zero-Static-Credential OIDC Federation
module "iam_oidc_github" {
  source                      = "../../modules/iam_oidc_github"
  environment                 = var.environment
  github_organization_or_user = var.github_user
  github_branch               = "main"
}
