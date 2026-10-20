#!/usr/bin/env bash
# Builds the eval workspace: a git repo whose main branch has an accepted intent with two stories.
# S2 (usage-dashboard) comes `After: S1 ships`. S1 (guest-token) has a merged spec and plan but
# hasn't been built, and S2's spec is merged. So S2 can't be planned yet. Run with --scaffold.
set -euo pipefail
git init -q -b main && git config user.email eval@example.com && git config user.name eval
I=intent/2026-02-01-guest-access
mkdir -p $I/guest-token $I/usage-dashboard
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
cat > $I/guest-token/spec.md <<'EOF'
# Spec: Guest tokens (S1 of guest-access)
R1. `POST /auth/guest` issues a 30-day guest token. R2. The chat route accepts it.
R3. Each guest message is logged as `guest_message(guest_id, at, tokens)`, without its content.
A1 (R1), A2 (R2), A3 (R3): Given/When/Then rows.
EOF
cat > $I/guest-token/plan.md <<'EOF'
# Plan: Guest tokens (S1)
1. **Token issuing and verification.** 2. **Accept guests on the chat route.** 3. **Usage log.**
EOF
cat > $I/usage-dashboard/spec.md <<'EOF'
# Spec: Usage dashboard (S2 of guest-access)
R1. `GET /admin/guest-usage?day=` sums `guest_message` rows per day (built by S1).
R2. The admin page shows messages, unique guests and estimated cost per day.
EOF
git add -A && git commit -qm "docs: accepted intent; S1 spec and plan; S2 spec"
