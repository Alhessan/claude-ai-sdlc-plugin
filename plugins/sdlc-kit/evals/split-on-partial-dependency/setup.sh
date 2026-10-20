#!/usr/bin/env bash
# Builds the eval workspace: a git repo with a draft intent on its docs/intent-* branch. One of its
# dependencies blocks only part of the outcome. Run with --scaffold.
set -euo pipefail
git init -q -b main && git config user.email eval@example.com && git config user.name eval
echo "# Chat product" > README.md && git add -A && git commit -qm "chore: init"
git switch -q -c docs/intent-answer-feedback
mkdir -p intent/2026-03-01-answer-feedback
cat > intent/2026-03-01-answer-feedback/intent.md <<'EOF'
# Intent: Star ratings on chat answers, triaged by admins

- **Author:** sam
- **Date:** 2026-03-01
- **Status:** draft
- **Approved by:** <product owner, once accepted>

## Problem
We have no signal on answer quality, so we can't tell which answers were wrong or unhelpful.
- The admin dashboard's Feedback page renders mock data (**verified**: `admin/src/feedback.tsx`
  imports `mock-data`).
- The backend has a `POST /feedback` endpoint that nothing calls (**verified**: no callers found).

## Desired outcome
1. A logged-in chat user rates each answer 1–5 stars, with an optional comment.
2. Admins see real ratings on the Feedback page, filter them by rating, and mark each one reviewed.

We'll know it worked when a rating left in the chat shows up on the admin page after a refresh.

## Users affected
Logged-in chat users, and admins.

## Systems affected
- [x] backend: store ratings with a triage status, and add filters.
- [x] admin dashboard: replace the mock Feedback page with the real queue.
- [x] chat UI: add the rating control under each answer.

## Constraints
- Depends on the chat login work, which nobody has written up yet. Until it ships there are no
  logged-in chat users, so the rating control can't be used. The backend and admin parts don't
  depend on it.
- Only admins can see feedback.

## Out of scope
- Replying to the user who left the rating.

## Open questions
1. Can a rating be edited? Proposal: yes, within 15 minutes of submitting.
2. Which triage statuses? Proposal: new, reviewed, dismissed.
EOF
git add -A && git commit -qm "docs(intent): star ratings on chat answers"
