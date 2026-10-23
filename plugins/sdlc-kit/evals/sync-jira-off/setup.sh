#!/usr/bin/env bash
# Builds the eval workspace: a git repo whose main branch has an accepted intent with two stories,
# and a .claude/settings.json without SDLC_JIRA_PROJECT, so Jira is off. Run with --scaffold.
set -euo pipefail
git init -q -b main && git config user.email eval@example.com && git config user.name eval
I=intent/2026-02-01-guest-access
mkdir -p $I .claude
printf '{ "env": { "INTENTS_BASE": "main" } }\n' > .claude/settings.json
cat > $I/intent.md <<'MD'
# Intent: Guest access with usage reporting

- **Author:** sam
- **Date:** 2026-02-01
- **Status:** accepted
- **Approved by:** pat (2026-02-03)

## Problem
Anonymous visitors can't use the public chat, and admins have no view of what guest use would cost.

## Desired outcome
1. An anonymous visitor can chat with no sign-up.
2. Admins see daily guest usage: messages, unique guests, and estimated model cost.

## Stories

### S1 guest-token: Chat without signing up
Visitors get a guest token the chat accepts.

- **Outcomes:** 1
- **Actors:** anonymous visitors
- **User story:** As a visitor, I want to chat without an account, so I can try the product first.

**Acceptance criteria**
- A visitor with no account can send a message and get an answer.

### S2 usage-dashboard: See how guests use the chat
An admin page reporting daily guest usage.

- **Outcomes:** 2
- **After:** S1 ships
- **Actors:** admins
- **User story:** As an admin, I want daily guest usage, so I can see what it costs.

**Acceptance criteria**
- An admin sees yesterday's guest messages, unique guests and estimated cost.

## Out of scope
- Billing guests.
MD
git add -A && git commit -qm "docs(intent): guest access, accepted"
