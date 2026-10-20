#!/usr/bin/env bash
# PostToolUse (sdlc-kit): after Claude writes markdown in an intent folder or a policy skill, run
# `intents hook` on it. Errors exit 2 for Claude to fix; prose warnings only add context, never block.
# It runs after every Edit/Write, so anything else leaves before jq or python starts.
set -uo pipefail

IFS= read -r -d '' input || true
case $input in *intent/*|*SKILL.md*) ;; *) exit 0 ;; esac
path=$(jq -r '.tool_input.file_path // empty' <<<"$input")
case "$path" in
  */intent/*/*.md | */.claude/skills/*/SKILL.md) ;;
  *) exit 0 ;;
esac
command -v python3 >/dev/null 2>&1 || exit 0
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
printf '%s' "$input" | python3 "$here/../lib/intents.py" hook
