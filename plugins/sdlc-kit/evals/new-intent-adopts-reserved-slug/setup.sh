#!/usr/bin/env bash
# Builds the eval workspace: a git repo whose main branch has an accepted intent that reserved a
# follow-up slug, guest-chat-retention, for work nobody has written yet. Run with --scaffold.
set -euo pipefail
git init -q -b main && git config user.email eval@example.com && git config user.name eval
mkdir -p intent/2026-01-10-guest-chat
cat > intent/2026-01-10-guest-chat/intent.md <<'EOF'
# Intent: Anonymous guest access to the public chat

- **Author:** sam
- **Date:** 2026-01-10
- **Status:** accepted
- **Approved by:** pat (2026-01-12)

## Problem
Anonymous visitors got a 401 on every chat message, because every chat route required a login
(**verified**: `api/src/auth.py`).

## Desired outcome
- An anonymous visitor can chat with no sign-up, and the same browser gets its history back later.
- Anonymous use is rate limited.

## Users affected
Anonymous visitors, and the operators who pay for model usage.

## Systems affected
- [x] api: guest tokens on the chat route only, plus rate limits.
- [x] web: get, store and send the guest token.

## Constraints
- No other route becomes reachable without a login.

## Out of scope
- Deleting old guest conversations. Nothing removes them in this intent, so they are kept
  indefinitely. → follow-up: guest-chat-retention
- A CAPTCHA.

## Decisions
| Question | Resolution | Who | Date |
|---|---|---|---|
| Guest token lifetime | 30 days, renewed on each visit | pat | 2026-01-12 |
EOF
git add -A && git commit -qm "docs(intent): accept anonymous guest access"
