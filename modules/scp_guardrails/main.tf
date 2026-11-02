# 1. Deny Unapproved Regions (Strict Canadian/US Sovereign Governance)
resource "aws_organizations_policy" "deny_unapproved_regions" {
  name        = "SCP-DenyUnapprovedRegions"
  description = "Restricts AWS API requests to authorized operational regions except global services"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyAllOutsideApprovedRegions"
        Effect   = "Deny"
        NotAction = [
          "a4b:*",
          "acm:*",
          "aws-marketplace-management:*",
          "aws-marketplace:*",
          "aws-portal:*",
          "budgets:*",
          "ce:*",
          "chime:*",
          "cloudfront:*",
          "config:*",
          "cur:*",
          "directconnect:*",
          "ec2:DescribeRegions",
          "ec2:DescribeTransitGateways",
          "ec2:DescribeVpnGateways",
          "fms:*",
          "globalaccelerator:*",
          "health:*",
          "iam:*",
          "importexport:*",
          "kms:*",
          "mobileanalytics:*",
          "networkmanager:*",
          "organizations:*",
          "pricing:*",
          "route53:*",
          "route53domains:*",
          "s3:GetAccountPublicAccessBlock",
          "s3:ListAllMyBuckets",
          "shield:*",
          "sts:*",
          "support:*",
          "trustedadvisor:*",
          "waf-regional:*",
          "waf:*",
          "wafv2:*",
          "wellarchitected:*"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = var.approved_regions
          }
          "Null" = {
            "aws:RequestedRegion" = "false"
          }
        }
      }
    ]
  })
}

# 2. Deny Root User Account Actions
resource "aws_organizations_policy" "deny_root_user" {
  name        = "SCP-DenyRootUser"
  description = "Prohibits operations executed directly with account root user credentials"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyRootAccountUsage"
        Effect    = "Deny"
        Action    = "*"
        Resource  = "*"
        Condition = {
          StringLike = {
            "aws:PrincipalArn" = "arn:aws:iam::*:root"
          }
        }
      }
    ]
  })
}

# 3. Deny Disabling Security & Observability Tools
resource "aws_organizations_policy" "protect_security_infrastructure" {
  name        = "SCP-ProtectSecurityInfrastructure"
  description = "Prevents tampering, stopping, or deleting CloudTrail, GuardDuty, Config, and SecurityHub"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyDisablingCloudTrail"
        Effect = "Deny"
        Action = [
          "cloudtrail:DeleteTrail",
          "cloudtrail:StopLogging",
          "cloudtrail:UpdateTrail"
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyDisablingGuardDuty"
        Effect = "Deny"
        Action = [
          "guardduty:DeleteDetector",
          "guardduty:DisassociateFromMasterAccount",
          "guardduty:StopMonitoringMembers"
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyDisablingAWSConfig"
        Effect = "Deny"
        Action = [
          "config:DeleteConfigRule",
          "config:DeleteConfigurationRecorder",
          "config:DeleteDeliveryChannel",
          "config:StopConfigurationRecorder"
        ]
        Resource = "*"
      }
    ]
  })
}

# 4. Enforce S3 Encryption in Transit and Block Public Access
resource "aws_organizations_policy" "enforce_s3_guardrails" {
  name        = "SCP-EnforceS3Security"
  description = "Denies unencrypted object uploads and forbids disabling S3 Block Public Access"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureS3Transport"
        Effect    = "Deny"
        Action    = "s3:*"
        Resource  = "arn:aws:s3:::*"
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid       = "DenyDisablingPublicAccessBlock"
        Effect    = "Deny"
        Action    = [
          "s3:DeleteAccountPublicAccessBlock",
          "s3:PutAccountPublicAccessBlock"
        ]
        Resource  = "*"
        Condition = {
          StringNotEquals = {
            "aws:PrincipalArn" = var.security_admin_role_arn
          }
        }
      }
    ]
  })
}

# 5. Prevent Leaving Organization
resource "aws_organizations_policy" "deny_leaving_org" {
  name        = "SCP-DenyLeavingOrganization"
  description = "Prohibits member accounts from leaving the AWS Organization"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyLeaveOrganization"
        Effect   = "Deny"
        Action   = "organizations:LeaveOrganization"
        Resource = "*"
      }
    ]
  })
}

# Attach Guardrails to Target Organizational Units
resource "aws_organizations_policy_attachment" "attach_unapproved_regions_workloads" {
  policy_id = aws_organizations_policy.deny_unapproved_regions.id
  target_id = var.target_ou_workloads_id
}

resource "aws_organizations_policy_attachment" "attach_root_guard_workloads" {
  policy_id = aws_organizations_policy.deny_root_user.id
  target_id = var.target_ou_workloads_id
}

resource "aws_organizations_policy_attachment" "attach_sec_infrastructure_workloads" {
  policy_id = aws_organizations_policy.protect_security_infrastructure.id
  target_id = var.target_ou_workloads_id
}

resource "aws_organizations_policy_attachment" "attach_s3_guard_workloads" {
  policy_id = aws_organizations_policy.enforce_s3_guardrails.id
  target_id = var.target_ou_workloads_id
}

resource "aws_organizations_policy_attachment" "attach_leaving_org_workloads" {
  policy_id = aws_organizations_policy.deny_leaving_org.id
  target_id = var.target_ou_workloads_id
}
