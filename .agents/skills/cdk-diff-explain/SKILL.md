---
name: cdk-diff-explain
description: Use when explaining cdk diff output or preparing a predeploy review. Diff execution that needs AWS credentials should go through $aws-sandbox-run. Do not deploy.
---

# CDK diff explain

## Instructions

1. Prefer `pnpm agent:predeploy` only with valid AWS credentials.
2. For sandbox account safety, wrap with `$aws-sandbox-run` (see `.agents/skills/aws-sandbox-run`).
3. Summarize CREATE / UPDATE / DELETE and security impact.
4. Never run bare `cdk deploy`; agents must use `$aws-sandbox-run` / `$aws-agent-lease`.
