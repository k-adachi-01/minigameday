---
name: cdk-unit-test
description: Use when adding or updating AWS CDK TypeScript constructs and Vitest tests with aws-cdk-lib/assertions. Do not use for deploy or AWS CLI mutation.
---

# CDK unit test

## When to use

- Adding/changing constructs under `lib/`
- Fixing failing Vitest CDK tests

## Instructions

1. Prefer `Template.fromStack(stack)` fine-grained assertions.
2. Keep snapshot tests for intentional template drift.
3. Add negative/security assertions for public access and broad IAM.
4. Run `pnpm test` (Vite+ / `vp test run`) then `pnpm agent:check`.
5. Official assertions docs: https://docs.aws.amazon.com/cdk/v2/guide/testing.html (runner here is Vitest via Vite+, not Jest).
