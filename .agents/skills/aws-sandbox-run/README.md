# aws-sandbox-run (reference only)

This repository does **not** redefine the `$aws-sandbox-run` skill body.

Canonical skill:

`/Users/adachi/agent-skills/aws-sandbox-run`

## Calling convention

PoC / disposable sandbox (human SSO session):

```bash
/Users/adachi/agent-skills/aws-sandbox-run/scripts/aws-sandbox-run \
  --experiment-id YYYYMMDD-minigameday-001 \
  --expires-at YYYY-MM-DD \
  -- pnpm diff
```

Autonomous agent against PoC Sandbox:

```bash
/Users/adachi/agent-skills/aws-sandbox-run/scripts/aws-agent-lease \
  --experiment-id YYYYMMDD-minigameday-001 \
  --expires-at YYYY-MM-DD \
  -- pnpm diff
```

Agents must not run bare `cdk deploy`. Route mutations through the runners above. See [docs/deployment.md](../../../docs/deployment.md).
