---
name: agent-quality-gate
description: Use before finishing CDK work to run the repository quality gate pnpm agent:check. Use whenever an agent claims a task is complete.
---

# Agent quality gate

## Required command

```bash
pnpm agent:check
```

This runs format check, lint, typecheck, tests, and synth.

## Notes

- Do not skip because husky exists; run explicitly.
- `pnpm agent:predeploy` adds `diff` and needs AWS auth; not required for local completion.
