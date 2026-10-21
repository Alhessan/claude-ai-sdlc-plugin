---
name: review-intent
description: Review a drafted intent.md for gaps, resolve every open question with the user, and record the decisions so a human can approve it by merging (Stage 1 of the AI-native SDLC). Use when someone asks to review, resolve, sign off, defer, or reject an intent, to amend an intent that's already accepted, or asks what's blocking one. Do NOT use to draft a new intent (/sdlc-kit:new-intent), to design one (/sdlc-kit:new-spec), or to review code.
argument-hint: "[intent folder | backlog]"
---

# /sdlc-kit:review-intent: resolve an intent and record its decisions

Intent folder: **$ARGUMENTS**

If that's empty, run `intents status` (on your PATH while this plugin is enabled; if it can't run,
read `intent/*/intent.md` and search for `follow-up:` markers yourself) and list every
intent that isn't `accepted`, with its status, its open question count, and its PR if it has one.
Include drafts that exist only on other `docs/intent-*` branches; `intents status` shows them. Also
list `deferred` intents whose **Revisit** month has arrived, and the **reserved slugs**: work an
intent promised as a follow-up, or depends on, that nobody has written yet. Ask which one to review.
`backlog` lists those and stops.

This is **Stage 1 only**. Do not write `spec.md` or `plan.md` and do not change code.

**You do not approve the intent.** A human approves it by merging its PR. Your job is to make the
intent complete enough that the decision is easy, and to record what was decided.

## 1. Load context
Read `CLAUDE.md`, `intent/README.md`, the intent itself, and the evidence it links to. If the intent
has a PR, read it and its review comments (`gh pr view --comments`); decisions already made there must
end up in the file. Load the project's policy skills (those whose description starts with `Policy -`)
to know which surfaces need an owner's answer.

## 2. Amendment mode: the intent is already accepted
If the intent is on the default branch with `Status: accepted` (or `deferred`/`rejected`), this is an
**amendment**, not a first review. That is the normal case: `/sdlc-kit:new-spec` or
`/sdlc-kit:new-plan` found that the intent contradicts the code, or a decision turned out wrong
during the build.

- **Ask what forced the change,** and name the artifact that found it — a spec requirement, a plan
  step, a build step — with a link, so the reason outlives the conversation.
- **Don't change `Status`.** An accepted intent stays accepted; an amendment doesn't put the whole
  intent back up for approval. If the change is big enough to need re-approval, say so and let the
  user decide.
- **Keep the original wording, struck through** (`~~like this~~`), with the new wording beside it,
  and add a dated amendment note. The template's Decisions section explains the convention. Never
  overwrite silently: a reader has to see what changed and why.
- **Add a Decisions row per change:** what changed, what forced it, who decided, the date.
- **Adding or dropping a story is an amendment too.** Strike a dropped story's whole line through,
  so it stops counting. Never renumber or reuse a story's id or slug.
- **Branch `docs/intent-<slug>-amend-<topic>`,** commit the intent alone, and open a PR against the default branch titled
  `docs(intent): amend <slug> — <what changed>`. Never merge it.
- Then work only the questions the amendment reopens. Don't re-interview what's already settled.

## 3. Find the gaps
The listed open questions are the easy half. Review the whole intent for what it doesn't say:
- **Assumed claims.** Anything marked *assumed* that a cheap read-only check could settle: run it, and
  mark the claim *verified* with what you ran. Never read real `.env*` files.
- **Technical detail in the business sections.** File paths, class names or code findings in the
  Problem or *Where we are today* belong in **Evidence** at the end; move them there and leave a
  plain-language line with a link. An older intent with no Evidence section is fine as it is.
- **An untestable outcome.** If "desired outcome" can't become Given/When/Then rows in a spec, it's
  too vague. Say what's missing.
- **Systems affected.** Ticked with no reason, or unticked though the code says otherwise.
- **Missing constraints,** especially ones `CLAUDE.md` or a policy skill calls out: performance, cost,
  privacy, compliance, localization, backward compatibility, deadlines.
- **No out-of-scope section,** or one that leaves the obvious adjacent work ambiguous.
- **An uncovered policy surface:** the intent touches an area no policy skill covers. Note it; never
  imply a policy checked it.
- **Duplicates.** Look for an intent that overlaps, supersedes, or is superseded by this one: in
  `intent/*/intent.md`, and in the drafts on other branches that `intents status` lists. A draft is
  invisible from this branch otherwise. If this intent replaces one, record it with **Supersedes**,
  and say the other's PR should be closed.
- **A solution in place of a problem.** Ask what problem it solves.
- **Too big for one story.** A dependency or sign-off that blocks only part of the outcome, or parts
  useful on their own to different users, mean it should split into stories. Two separate problems
  mean two intents linked by **Depends on**. More than five stories usually means two intents. Each
  story must be safe to ship on its own.
- **Relations written as prose.** "A separate intent", "a follow-up", "depends on the X work" can't
  be checked. Propose a **Depends on** or **Supersedes** entry, or a `→ follow-up: <slug>` marker,
  with the slug. Run `intents check intent/<folder>/intent.md`. Every error must be fixed, and its
  warnings point at prose like this. If `intents` can't run, read the Out of scope and Constraints
  sections for such prose yourself.
- **A dependency on unwritten work.** Depending on a reserved slug is fine, but the plan is blocked
  until that work ships. Say so, and ask who will write it.

Add each gap to the list to resolve, with your proposed answer. Report gaps you can't resolve as new
open questions rather than answering them yourself.

## 4. Resolve, with the user
Ask 3–5 questions at a time, each with your recommendation, so the user can say "yes" or "no,
because…". Keep going until every question has one of these resolutions:
- **Decided** — the answer, in the user's words.
- **Deferred to spec** — a genuine design question Stage 1 can't settle. Record why. `/sdlc-kit:new-spec`
  must ask it.
- **Out of scope** — moved to Non-goals.
- **Needs <name>** — only that person can answer (a policy owner, a customer, legal). Name them. The
  intent can't be accepted until they do.

Never mark something decided because the user didn't object, and never invent an answer to close a
question out.

## 5. Agree the outcome
**If the user already signalled the outcome** ("not this quarter", "we're not doing this", "this is
good, let's go"), say so back in your first reply and ask for what that outcome needs — for a
deferral, the revisit month and who revisits — rather than waiting until the questions are done. A
stated intention that never gets recorded is how a deferral turns into a forgotten file.

Otherwise, once the questions are resolved, summarize: what changed in the intent, what was decided,
and what's still open. Then ask the user which outcome they want. Never pick it yourself.
- **accepted** — ready to build. Every question is decided, deferred to spec, or out of scope.
- **deferred** — the intent is sound, but not now. Requires a **Revisit** month (`YYYY-MM`) and the
  person who revisits it. Merging it as `deferred` is how it enters the backlog.
- **rejected** — we're not doing this. Record why.
- **still draft** — blocked on someone, or the user wants more work first. Say exactly what's needed.

## 6. Write the intent
*In amendment mode (§2), keep `Status` as it is and strike through what you replace.*

- Fill the **Decisions** table: each question, its resolution, who decided, and the date.
- Set **Status**, and **Approved by** (or **Revisit**, when deferred).
- Keep the rest of the file true: if a decision changes scope, constraints or non-goals, edit those
  sections too and note the change in Decisions. Never leave a decision that contradicts the body.
- Verified claims lose their *assumed* marker, and gain the evidence.
- If it **Supersedes** a merged intent, amend that intent's Status to `superseded` in the same commit.

## 7. Commit, after the user confirms
Show the full diff and **ask before committing**. Once they confirm:
1. If the intent has an open PR, commit to its branch (`docs/intent-<slug>`) and push. Otherwise
   branch off the default branch and open one against it, titled `docs(intent): <title>`.
2. Message: `docs(intent): record decisions for <slug>`, or `docs(intent): defer <slug> to <YYYY-MM>`.
3. Update the PR body with the outcome and anything still blocking it.
4. **Never merge it.** Merging is the product owner's approval, including for `deferred` and
   `rejected`, which are merged so the record stays in `intent/`.

Then say what's next: `/sdlc-kit:new-spec intent/<folder>` once the PR is merged as `accepted` (for an
intent with stories, `intent/<folder>/<story-slug>`, starting with a story that waits on nothing), or
who is being waited on.
