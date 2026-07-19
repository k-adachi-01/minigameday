#!/usr/bin/env bash
set -euo pipefail

input="$(cat || true)"
command="$(printf '%s' "$input" | jq -r '.command // empty' 2>/dev/null || true)"

deny_pattern='(^|[[:space:]])(cdk([[:space:]]+|-)deploy|aws([[:space:]]+)cloudformation([[:space:]]+)deploy|aws([[:space:]]+)s3([[:space:]]+)(rb|rm)|aws([[:space:]]+)iam([[:space:]]+))'

if [[ -n "$command" ]] && [[ "$command" =~ $deny_pattern ]]; then
  jq -n --arg reason "Direct AWS mutation blocked. Use \$aws-sandbox-run instead. See docs/deployment.md" \
    '{permission:"deny",user_message:$reason,agent_message:$reason}'
  exit 0
fi

jq -n '{permission:"allow"}'
