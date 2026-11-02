"""Unit tests verifying Service Control Policy (SCP) JSON structures and guardrails."""

import json
import re
from pathlib import Path
import pytest


def extract_policy_statements(tf_file_path: Path, policy_resource_name: str) -> list[dict]:
    content = tf_file_path.read_text(encoding="utf-8")
    # Locate the jsonencode block
    match = re.search(
        rf'resource\s+"aws_organizations_policy"\s+"{policy_resource_name}".*?content\s+=\s+jsonencode\(({{.*?}}\))\s*\n}}',
        content,
        re.DOTALL
    )
    assert match, f"Could not find jsonencode for {policy_resource_name}"
    raw_hcl_dict = match.group(1)
    
    # We can inspect key strings directly or verify with HCL parser
    return raw_hcl_dict


def test_scp_file_exists():
    scp_main = Path(__file__).resolve().parent.parent / "modules" / "scp_guardrails" / "main.tf"
    assert scp_main.exists()
    content = scp_main.read_text(encoding="utf-8")
    assert "SCP-DenyUnapprovedRegions" in content
    assert "SCP-DenyRootUser" in content
    assert "SCP-ProtectSecurityInfrastructure" in content
    assert "SCP-EnforceS3Security" in content


def test_root_user_denial_logic():
    scp_main = Path(__file__).resolve().parent.parent / "modules" / "scp_guardrails" / "main.tf"
    content = scp_main.read_text(encoding="utf-8")
    assert '"aws:PrincipalArn" = "arn:aws:iam::*:root"' in content
    assert 'Effect    = "Deny"' in content


def test_s3_insecure_transport_denial():
    scp_main = Path(__file__).resolve().parent.parent / "modules" / "scp_guardrails" / "main.tf"
    content = scp_main.read_text(encoding="utf-8")
    assert '"aws:SecureTransport" = "false"' in content
    assert 'Action    = "s3:*"' in content


def test_github_oidc_trust_policy():
    oidc_main = Path(__file__).resolve().parent.parent / "modules" / "iam_oidc_github" / "main.tf"
    assert oidc_main.exists()
    content = oidc_main.read_text(encoding="utf-8")
    assert "token.actions.githubusercontent.com:aud" in content
    assert "token.actions.githubusercontent.com:sub" in content
    assert "sts:AssumeRoleWithWebIdentity" in content
