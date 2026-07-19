# Nix

## Purpose

`flake.nix` pins a reproducible local toolchain so the machine is not polluted with ad-hoc global installs.

Nix provides: Node.js 22, pnpm, AWS CLI v2, jq, ripgrep, git.

Node package install for this repo uses **pnpm** (`pnpm-lock.yaml`). Prefer Corepack / the `packageManager` field so the lockfile matches `pnpm@11.10.0`.

## Enter the shell

```bash
cd minigameday
nix develop
```

One-shot:

```bash
nix develop --command bash -lc 'node -v && pnpm -v && aws --version'
```

## Notes

- `flake.lock` must be committed so everyone resolves the same nixpkgs.
- After entering the shell: `pnpm install` then `pnpm agent:check`.
- AWS mutations still go through `$aws-sandbox-run` — see [deployment.md](deployment.md).
