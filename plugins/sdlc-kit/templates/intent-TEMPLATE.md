# Intent: <short title>

- **Author:** <name>
- **Date:** YYYY-MM-DD
- **Status:** draft | accepted | deferred | rejected | superseded
- **Approved by:** <product owner, once accepted>
- **Revisit:** <YYYY-MM and who, when deferred>
- **Depends on:** <slugs of intents or stories, or #PR, comma-separated; delete if none>
- **Supersedes:** <slug of the intent this replaces; delete if none>

## Problem
What is wrong or missing today, and who feels it? Include evidence (user reports, metrics, logs, code
you read or ran), marking each item **verified** or **assumed**.

## Desired outcome
What does "done" look like from the user's point of view? How will we know it worked? Number the
outcomes if the intent has stories, so each story can say which ones it delivers.

## Stories
Delete this section if the intent ships as one piece, which most do. Otherwise split it into 2–4
stories. Each one is specced, planned and built on its own, in its own folder (`<story-slug>/`), and
each must be safe to ship alone:

- **S1 <story-slug>**: <what ships>. Outcomes: <numbers>.
- **S2 <story-slug>**: <what ships>. Outcomes: <numbers>. After: S1.

`After: S1` waits for S1's spec to merge, which is enough to build against its contract. Write
`After: S1 ships` to wait for it to ship. Story slugs name branches and commits, so they must be
unique across `intent/`.

## Users affected
<Who uses the affected parts: end users, admins, operators, other services…>

## Systems affected
Tick what you expect to change, and note why.

- [ ] <project or service 1>
- [ ] <project or service 2>
- [ ] Datastores (schema, indexes, collections)
- [ ] Infrastructure / deployment

## Constraints
Performance, cost, privacy, compliance, localization, backward compatibility, deadlines. Name work
this depends on in **Depends on** above, by slug or PR number, so it can be checked.

## Out of scope
What we are deliberately *not* doing. When someone will do it later, end the item with
`→ follow-up: <slug>`, so the slug is reserved and `intents status` lists it until it's written.

## Open questions
Each with a proposed answer, so the approver can say "yes" or "no, because…".

## Decisions
Filled in by `/sdlc-kit:review-intent`. One row per question: the question, its
resolution (decided / deferred to spec / out of scope / needs <name>), who decided, and the date.

| Question | Resolution | Who | Date |
|---|---|---|---|

**Amending this intent after it's accepted.** The spec or the plan will sometimes prove part of this
file wrong. When that happens, don't overwrite it:

- strike the original wording (`~~a 60-day purge of idle sessions~~`) and put the new wording beside
  it, so the change is visible in place;
- mark it `(Amended YYYY-MM-DD: <what changed and what forced it>)`, naming the spec section, plan
  step or PR that found the problem;
- add a row here for each amendment;
- leave `Status` alone. An amendment doesn't re-run approval of the whole intent.

To drop a story, strike its whole line through the same way; a struck-through story no longer counts.

A struck-through line that turned out to be wrong is more useful to the next reader than a clean file
that hides the correction.
