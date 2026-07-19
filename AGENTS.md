# AGENTS.md

## Repository purpose

Mini GameDay: ALB + Fargate + Aurora with AWS FIS fault injection, Synthetics canaries, and a review dashboard.

Aligned with cdk-starter-style isolation (Nix + sandbox) and a hybrid toolchain (pnpm / Vite+ / oxfmt / lefthook / TS 7). Skills SSOT lives under `.agents/skills`.

## Scope

- TypeScript AWS CDK v2 application under `bin/` / `lib/`
- Dashboard / app / canaries / scenarios stay in-repo
- Local toolchain via `nix develop` (see `docs/nix.md`)
- AWS mutations for agents go through `$aws-sandbox-run` / `$aws-agent-lease`

## Tech stack

- Package manager: **pnpm** (`pnpm-lock.yaml`)
- TypeScript 7.0, Vite+ (`vp` for test/lint/dashboard), oxfmt, lefthook
- CDK app entry: `pnpm exec tsx` via `cdk.json`

## Setup

```bash
nix develop
pnpm install
pnpm symlinks
pnpm agent:check
```

## Validation

```bash
pnpm agent:check
```

Optional: `pnpm lint`, `pnpm typecheck`, `pnpm synth:nag`, `pnpm agent:predeploy` (needs AWS auth for `diff`)

## Deploy policy (two-layer)

- **Human (own terminal):** `pnpm deploy` / `destroy` / `reset` / `drift` and FIS CLI are allowed for personal GameDay runs.
- **Agent (Codex / Cursor):** Do **not** run bare `cdk deploy`, `aws cloudformation deploy`, or destructive `aws s3` / `aws iam`. Use `$aws-sandbox-run` or `$aws-agent-lease` (see `docs/deployment.md`).

Personal work targets PoC Sandbox only.

## Pass scenarios

Reproducibility gate: **scenario-01** and **scenario-05** on stack `GameDay`.

## Skills (SSOT)

Canonical skills: `.agents/skills/`. Cursor and Claude consume them via symlink (`pnpm symlinks`).

| Skill                   | Purpose                                   |
| ----------------------- | ----------------------------------------- |
| `add-scenario`          | New GameDay scenario workflow             |
| `fis-experiment`        | Implement FIS experiment templates in CDK |
| `gameday-dashboard`     | Dashboard / gameday.json operations       |
| `gameday-retrospective` | KPT retrospective materials               |
| `agent-quality-gate`    | Run `pnpm agent:check` before finishing   |
| `cdk-unit-test`         | Vitest + `aws-cdk-lib/assertions`         |
| `cdk-security-review`   | IAM / S3 / encryption review              |
| `cdk-synth-debug`       | Synth failure triage                      |
| `cdk-diff-explain`      | Diff review (via sandbox-run)             |
| `aws-sandbox-run`       | Account-safe AWS mutation boundary        |

Scenario design agent: `.cursor/agents/gameday-scenario.md` (`.claude/agents/` is a symlink).

## Agent handoff format

1. What changed (paths)
2. Commands run and results (`pnpm agent:check`)
3. Remaining risks / follow-ups
4. Whether any AWS mutation is still needed (must go through sandbox runners for agents)
