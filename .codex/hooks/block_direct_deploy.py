#!/usr/bin/env python3
"""PreToolUse: deny direct deploy / dangerous AWS mutations."""
from __future__ import annotations

import json
import re
import sys

DENY = re.compile(
    r"(cdk(\s+|-)deploy|aws\s+cloudformation\s+deploy|aws\s+s3\s+(rb|rm)|aws\s+iam\s+)",
    re.IGNORECASE,
)


def main() -> int:
    raw = sys.stdin.read()
    try:
        payload = json.loads(raw) if raw.strip() else {}
    except json.JSONDecodeError:
        payload = {}

    tool_input = payload.get("tool_input") or payload.get("input") or {}
    command = ""
    if isinstance(tool_input, dict):
        command = str(tool_input.get("command") or tool_input.get("cmd") or "")
    elif isinstance(tool_input, str):
        command = tool_input

    if DENY.search(command):
        reason = (
            "Direct AWS mutation blocked by repo hook. "
            "Use $aws-sandbox-run instead. See docs/deployment.md and AGENTS.md."
        )
        print(
            json.dumps(
                {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "deny",
                    "permissionDecisionReason": reason,
                }
            )
        )
        return 0

    print(json.dumps({"hookEventName": "PreToolUse", "permissionDecision": "allow"}))
    return 0


if __name__ == "__main__":
    sys.exit(main())
