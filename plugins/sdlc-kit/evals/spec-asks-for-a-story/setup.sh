#!/usr/bin/env bash
# Builds the eval workspace: a git repo whose main branch has an accepted intent with two stories and
# nothing else, so each story still needs its own spec. Run with --scaffold.
set -euo pipefail
git init -q -b main && git config user.email eval@example.com && git config user.name eval
I=intent/2026-02-01-guest-access
mkdir -p $I
cat > $I/intent.md <<'EOF'
# Intent: Guest access with usage reporting

- **Author:** sam
- **Date:** 2026-02-01
- **Status:** accepted
- **Approved by:** pat (2026-02-03)

## Problem
Anonymous visitors can't use the public chat (every chat route requires a login), and admins have no
view of how much anonymous use would cost.

## Desired outcome
1. An anonymous visitor can chat with no sign-up.
2. Admins see daily guest usage: messages, unique guests, and estimated model cost.

## Stories
- **S1 guest-token**: visitors get a guest token that the chat route accepts, and each guest message
  is logged with the guest's id. Outcomes: 1.
- **S2 usage-dashboard**: an admin page that reports daily guest usage from those logs. Outcomes: 2.
  After: S1 ships.

## Users affected
Anonymous visitors, and admins.

## Systems affected
- [x] api: guest tokens and usage logs (S1), a usage report endpoint (S2).
- [x] admin dashboard: the usage page (S2).

## Constraints
- Guest messages are logged without their content.

## Out of scope
- Billing guests.
EOF
git add -A && git commit -qm "docs(intent): accept guest access with usage reporting"
