---
name: new-intent
description: Turn a feature idea into an intent.md ready for approval (Stage 1, Plan, of the AI-native SDLC). Use when someone has a new feature, product change, or "I have an idea for…", or asks to create/draft an intent. Do NOT use for bug fixes, typos, dependency bumps, or other small changes; those go straight to a PR.
argument-hint: <feature idea, rough is fine>
---

# /sdlc-kit:new-intent: capture a feature as `intent.md`

The idea: **$ARGUMENTS**

If that's empty, ask the user for the idea in a sentence or two, and who asked for it or why now.

This is **Stage 1 only**. Do not write `spec.md` or `plan.md`, do not change any code, and don't
design the implementation beyond what's needed to state constraints.

## 1. Load context
Read `CLAUDE.md`, `intent/README.md` and `intent/_TEMPLATE.md`. If `intent/` doesn't exist, suggest
running `/sdlc-kit:init` first. Don't read other intents as examples: their constraints, decisions
and scope leak into the new one.

Run `intents status` (on your PATH while this plugin is enabled). It lists every intent with its
stage, including drafts that exist only on other people's `docs/intent-*` branches, and **reserved
slugs**: work other intents promised as a follow-up but nobody has written.
- **If the idea is a reserved slug's work,** use that slug for the folder, so the promise resolves to
  this intent, and say where it was promised.
- **If an existing intent or draft overlaps the idea,** raise it before interviewing. This one may
  supersede it, depend on it, or belong inside it.

If `intents` can't run (it needs python3 and git), find the same things by hand. Search `intent/` and
the policy skills for `follow-up:`: each marker's slug is reserved for the work it describes. Drafts
are intent folders on other `docs/intent-*` branches.

Read another intent only when it's related: it promised this work, it overlaps, or this one depends
on it. Read it for what relates, not as a model to copy.

## 2. Screen the request
If it's a small fix (typo, one-line bug, dependency bump, doc tweak), say so and suggest a direct
PR instead. Those skip the intent process. Stop unless the user insists.

If it's too big to ship in one piece, propose splitting it, and say why:
- **A dependency or sign-off blocks only part of it.** Split along that line.
- **Part of it would be useful on its own,** to different users.
- **It's really two problems,** with separate evidence and users, either of which someone could want
  without the other. Those are two intents, linked by **Depends on**, not stories.

Otherwise, one intent with 2–4 **stories** (see the template's Stories section). Each story must be
safe to ship alone: a slice that leaves the default branch broken until the next one lands isn't a
story. Most intents need no stories at all.

## 3. Interview
Ask 3–5 questions at a time until the idea is concrete:
- What's the problem, and what evidence do we have for it?
- Who is affected?
- What does "done" look like, and how will we know it worked?
- What are the constraints (performance, cost, privacy, compliance, deadlines, anything `CLAUDE.md`
  or the project's policy skills call out)?
- What's out of scope?

Push back when the user describes a solution instead of a problem. Ask what problem that solution
solves.

## 4. Investigate the current state
Find the services, routes, models, and UI the idea touches, using `CLAUDE.md`'s project map. Run
cheap, read-only checks (existing tests, scripts, grep) to gather evidence. For each finding, record
whether it's **verified** (you saw or ran it) or **assumed**. Never read real `.env*` files.

## 5. Draft
Write `intent/<YYYY-MM-DD>-<slug>/intent.md` from the template, using today's date.
- Tick only the systems you have evidence the change touches.
- Write the Problem and *Where we are today* for the product owner: business terms, no file paths or
  class names. Put the technical findings in **Evidence** at the end, grouped under `###` headings
  and marked **verified** or **assumed**, and link each *Where we are today* line to its group. Use
  this layout even if the project's `_TEMPLATE.md` predates it.
- Give every open question your proposed answer, so the approver can say "yes" or "no, because…".
  Split them under `### Business` (what users see or what the product does; the product owner
  answers) and then `### Technical` (for the spec), numbered straight through. Write each question
  in bold and its `*Proposed:*` answer as short bullet items, not a paragraph.
- Write relations so they can be checked: **Depends on** and **Supersedes** name intents or stories
  by slug, or pull requests as `#N`. Out-of-scope work someone will do later ends with
  `→ follow-up: <slug>`. A dependency on work nobody has written yet gets a slug too; it's reserved
  until someone writes it.
- With stories, number the desired outcomes and give each story the template's block: a `###`
  heading with its id, slug and a title saying what users can do, then its outcomes, waits, actors,
  a one-line user story, what users get, and a few acceptance criteria. Write them from the user's
  side, as short bullets, and keep the criteria plain: no Given / When / Then, which the spec adds.
  Delete the template's optional parts that don't apply.
- A hook runs `intents check` on the file after you write it. Fix any error it reports.

## 6. Review, then open a PR
Show the draft and fix it with the user until they're happy. Then:
1. Branch off the default branch as `docs/intent-<slug>`, and commit only the intent file. If it
   supersedes a merged intent, also amend that one's Status to `superseded` in the same commit (see
   the template's amendment convention).
2. Open a PR against the default branch titled `docs(intent): <title>`. The body summarizes the problem, key evidence, and the
   decisions needed.
3. **Never merge it.** Merging the PR is the product-owner approval.

Then run `/sdlc-kit:review-intent intent/<folder>`. It closes out the open questions, records the
decisions, and sets the status, so the approver has a complete file to merge.
