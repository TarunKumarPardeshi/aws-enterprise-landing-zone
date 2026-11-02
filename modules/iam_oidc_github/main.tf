# GitHub Actions OIDC Identity Provider
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c5876170ced27416a1f244f5d5e6850bc583324"
  ]

  tags = {
    Name        = "GitHubActionsOIDC"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Scoped IAM Role for CI/CD Deployment
resource "aws_iam_role" "github_actions_deployer" {
  name        = "GitHubActionsDeployer-${var.environment}"
  description = "Scoped role assumed by GitHub Actions runners with zero static AWS credentials"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_organization_or_user}/*:ref:refs/heads/${var.github_branch}"
          }
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Least-Privilege Terraform Plan/Apply Policy
resource "aws_iam_policy" "landing_zone_deploy_policy" {
  name        = "LandingZoneDeployPolicy-${var.environment}"
  description = "Permits managing Organizations, SCPs, and Security Hub components"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "OrganizationsManagement"
        Effect = "Allow"
        Action = [
          "organizations:Describe*",
          "organizations:List*",
          "organizations:CreatePolicy",
          "organizations:UpdatePolicy",
          "organizations:AttachPolicy",
          "organizations:DetachPolicy"
        ]
        Resource = "*"
      },
      {
        Sid    = "IAMOIDCManagement"
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:ListRolePolicies",
          "iam:GetOpenIDConnectProvider"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_deploy_policy" {
  role       = aws_iam_role.github_actions_deployer.name
  policy_arn = aws_iam_policy.landing_zone_deploy_policy.arn
}
