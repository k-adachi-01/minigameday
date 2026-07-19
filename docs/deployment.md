# Deployment

## Policy (two-layer)

| Actor                  | Rule                                                                                                                                                                                   |
| ---------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Human (own terminal)   | `pnpm deploy` / `destroy` / `reset` / `drift` / FIS CLI are allowed for personal GameDay operation                                                                                     |
| Agent (Codex / Cursor) | Do **not** run bare `cdk deploy`, `aws cloudformation deploy`, or destructive `aws s3` / `aws iam` mutations. Route AWS-changing work through `$aws-sandbox-run` or `$aws-agent-lease` |

Personal validation in this repo targets **PoC Sandbox** only. Do not deploy to Management or long-running App Dev accounts.

`pnpm deploy` remains in `package.json` (GameDay needs it). Agents still must not invoke it directly.

## Use `$aws-sandbox-run`

Skill body lives outside this repo:

`/Users/adachi/agent-skills/aws-sandbox-run`

See also [`.agents/skills/aws-sandbox-run/README.md`](../.agents/skills/aws-sandbox-run/README.md).

### Human SSO session (interactive)

```bash
/Users/adachi/agent-skills/aws-sandbox-run/scripts/aws-sandbox-run \
  --experiment-id YYYYMMDD-minigameday-001 \
  --expires-at YYYY-MM-DD \
  -- pnpm synth
```

```bash
/Users/adachi/agent-skills/aws-sandbox-run/scripts/aws-sandbox-run \
  --experiment-id YYYYMMDD-minigameday-001 \
  --expires-at YYYY-MM-DD \
  -- pnpm deploy
```

### Autonomous / background agent (no long-lived human SSO)

```bash
/Users/adachi/agent-skills/aws-sandbox-run/scripts/aws-agent-lease \
  --experiment-id YYYYMMDD-minigameday-001 \
  --expires-at YYYY-MM-DD \
  -- pnpm diff
```

## Pass scenarios (reproducibility gate)

Initial pass criteria: **scenario-01** and **scenario-05** on the `GameDay` stack (not Legacy / not scenario-04).

Suggested flow inside sandbox-run:

1. `pnpm deploy` (or `pnpm exec cdk deploy GameDay`) via sandbox-run
2. Confirm ALB URL / canary healthy
3. scenario-01: `aws fis start-experiment` with StopTask template id (observe self-heal)
4. scenario-05: `aws fis start-experiment` with ScaleToZero template id, then restore `desiredCount=2`
5. `pnpm destroy` via sandbox-run when finished (stop billing)

FIS CLI is not blocked by agent hooks in this phase; still prefer wrapping AWS CLI through sandbox-run so account/region metadata stays enforced.

## Local checks (no AWS)

```bash
pnpm agent:check
```
