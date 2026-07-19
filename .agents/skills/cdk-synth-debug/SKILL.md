---
name: cdk-synth-debug
description: Use when cdk synth fails or synthesized templates look wrong. Do not use for AWS account deploy troubleshooting.
---

# CDK synth debug

## Steps

1. Run `pnpm typecheck`
2. Run `pnpm synth` and capture the error
3. Check `cdk.json` app entry (`pnpm exec tsx bin/app.ts`)
4. Verify imports use `.js` extensions with NodeNext
5. Re-run `pnpm agent:check` after the fix
