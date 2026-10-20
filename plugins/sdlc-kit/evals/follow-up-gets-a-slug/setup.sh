#!/usr/bin/env bash
# Builds the eval workspace: a git repo with a draft intent on its docs/intent-* branch. Its Out of
# scope promises two pieces of later work in prose, with no follow-up marker. Run with --scaffold.
set -euo pipefail
git init -q -b main && git config user.email eval@example.com && git config user.name eval
echo "# Chat product" > README.md && git add -A && git commit -qm "chore: init"
git switch -q -c docs/intent-guest-chat
mkdir -p intent/2026-03-05-guest-chat
cat > intent/2026-03-05-guest-chat/intent.md <<'EOF'
# Intent: Anonymous guest access to the public chat

- **Author:** sam
- **Date:** 2026-03-05
- **Status:** draft
- **Approved by:** <product owner, once accepted>

## Problem
The public chat requires a login, but the chat page can't send one, so anonymous visitors get a 401
on every message (**verified**: `api/src/auth.py` requires a user on every chat route, and
`web/src/chat-api.ts` sends no `Authorization` header).

## Desired outcome
- An anonymous visitor can chat with no sign-up, including follow-up questions in the same thread.
- The same browser gets its history back on later visits.
- Anonymous use is rate limited, so one person can't run up the model bill.

We'll know it worked when a fresh browser completes a chat with zero 401s, and the test suite
proves guests can't reach any other route.

## Users affected
Anonymous visitors to the public chat, and the operators who pay for model usage.

## Systems affected
- [x] api: issue guest tokens, accept them on the chat route only, add rate limits.
- [x] web: get, store and send the guest token.

## Constraints
- No route that requires a login today may become reachable without one, except the chat route.
- Guests are isolated from each other and from logged-in users.

## Out of scope
- Purging stored guest conversations. That's a follow-up intent.
- Routing all model calls through a gateway. That's a separate intent, not this one.
- A CAPTCHA.

## Open questions
1. How long does a guest token last? Proposal: 30 days, renewed on each visit.
2. What status do guests get on routes they can't use? Proposal: 401.
EOF
git add -A && git commit -qm "docs(intent): anonymous guest access to the public chat"
