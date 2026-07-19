---
name: cdk-security-review
description: Use when reviewing AWS CDK TypeScript changes for IAM, S3 public access, encryption, RemovalPolicy, and other security risks. Do not use for routine formatting.
---

# CDK security review

## Checklist

- Block public S3 access
- Encryption at rest
- Least-privilege IAM (avoid `Action: "*"`)
- Intentional `RemovalPolicy`
- No hardcoded secrets

## Instructions

1. Read changed files under `bin/` and `lib/`.
2. Cross-check with `docs/security.md`.
3. Ensure Vitest covers security-sensitive properties.
4. Never suggest direct `cdk deploy`; point to `$aws-sandbox-run`.
