---
name: sync-jira
description: Mirror accepted intents into Jira (an epic per intent with stories, a Jira story per intent story, blocked-by links, optional subtasks from plan steps), and turn edits or comments made in Jira into intent amendments. Only for projects that set SDLC_JIRA_PROJECT. Use when someone asks to create, sync, update or push Jira tickets for an intent, or to pull Jira comments or edits back. Do NOT use to write or change an intent (/sdlc-kit:new-intent, /sdlc-kit:review-intent) or to move tickets on the board.
argument-hint: "[intent or story slug] [--pull]"
---

# /sdlc-kit:sync-jira: mirror accepted intents in Jira

Target: **$ARGUMENTS** (empty means every merged intent)

The repo is the source of truth and Jira mirrors it. Tickets are made from what's merged to the
default branch, never from a draft. A change made in Jira comes back only as an intent amendment that
a human merges. The team moves tickets through the board by hand; this skill never changes a
ticket's status, except to close a story the intent dropped.

`--pull` reads Jira and drafts amendments, and writes nothing to Jira.

## 0. Gate: is Jira on for this project?
Run `echo "SDLC_JIRA_PROJECT=$SDLC_JIRA_PROJECT"`. If you can't run it, treat Jira as off. These
settings live in the `env` block of the
project's checked-in `.claude/settings.json`:

| Setting | Meaning | Default |
|---|---|---|
| `SDLC_JIRA_PROJECT` | The Jira project key. Setting it turns the sync on. | unset: no Jira |
| `SDLC_JIRA_EPIC_TYPE` | Issue type for an intent with stories | `Epic` |
| `SDLC_JIRA_STORY_TYPE` | Issue type for a story, or a single-story intent | `Story` |
| `SDLC_JIRA_SUBTASK_TYPE` | Issue type for a plan step | `Subtask` |
| `SDLC_JIRA_BLOCKS_LINK` | Link type for `After:` and `Depends on:` | `Blocks` |
| `SDLC_JIRA_DROPPED_STATUS` | Status a dropped story moves to | `Won't Do` |
| `SDLC_JIRA_SUBTASKS` | `on` creates a subtask per plan step | off |

- **`SDLC_JIRA_PROJECT` is empty:** stop. Say that Jira isn't set up for this project, and that a
  maintainer turns it on by adding `"SDLC_JIRA_PROJECT": "<KEY>"` to the `env` block of
  `.claude/settings.json` in a reviewed PR (or with `/sdlc-kit:init`), then restarting Claude Code.
  **Never ask for a key and carry on.** One developer must not turn Jira on for the team by
  accident.
- **The Atlassian connector isn't available or isn't signed in:** stop and say so. The user
  connects it with `/mcp`. Never ask for an API token or password.
- Find the Jira site the connector can reach, and check the project key exists there. If the key
  is missing, stop and show the projects you can see.

## 1. Export what's merged
1. `git fetch` (so the default branch is current), then `intents export <slug>`, or
   `intents export` for every merged intent. If `intents` can't run, stop: the sync needs the export
   to stay consistent, so don't build tickets by hand.
2. Keep intents whose `status` is `accepted`. Skip `deferred` and `rejected` ones. For a `superseded`
   intent that already has tickets, add a comment naming its successor, and leave its status alone.
3. Each record carries the summary, description, `label`, `digest`, `blocked_by`, `stage`, `spec`
   and `plan` to use. Don't rewrite descriptions: the export builds them, including the banner that
   tells readers to change the intent rather than the ticket.

What maps to what:
- **An intent with stories** (`epic` isn't null) becomes an epic, and each story a child of it.
- **An intent without stories** becomes one story with no epic. Its single record in `stories`
  uses the intent's slug.
- **`blocked_by`** becomes a `SDLC_JIRA_BLOCKS_LINK` link: this ticket is blocked by the other one.
  Link only to slugs that have a ticket. A `#N` ref, or a slug nothing defines yet, stays in the
  description only.
- **A dropped story** (`dropped: true`) gets a comment, and moves to `SDLC_JIRA_DROPPED_STATUS`.
  Never delete a ticket.
- **Plan steps** (`plan.steps`, only with `SDLC_JIRA_SUBTASKS=on`) become subtasks of their story,
  summarised `Step <n>: <title>`, labelled `sdlc:<slug>:step-<n>`. Create the missing ones only;
  never delete or renumber them.

## 2. Find the tickets that already exist
The label is the link between the repo and Jira. Search the project with JQL:
`project = <KEY> AND labels in ("sdlc:<slug>", …)`, for every epic and story slug in the export.
- **One ticket per label:** that's its ticket.
- **None:** it gets created in step 4.
- **More than one:** stop for that slug and list the duplicates. A human picks which one to keep and
  removes the label from the others.

For each existing ticket, find its **last sync comment**, which starts `sdlc-kit sync`. It names the
commit and digest the ticket was last written from.

## 3. Read Jira before writing to it
For every existing ticket, look for changes people made in Jira since the last sync comment:
- **Comments** added after it, except the sync's own.
- **Description edits.** Run `intents export <slug> --base <commit from the sync comment>` to get the
  text the sync wrote then. Compare it with the ticket's description now. Jira re-renders markdown,
  so ignore formatting and look at the substance: wording, criteria, scope. If there's no sync
  comment, the ticket wasn't written by this skill; treat its whole description as Jira-side
  content.

A ticket with a description edit is **held**: step 4 doesn't overwrite it. Comments alone don't hold
a ticket.

Turn what you found into a list, one item per edit or comment, each with the ticket key, who wrote
it and when, and what it asks:
- **A change to the intent** (scope, wording, an acceptance criterion): it becomes an amendment in
  step 5.
- **A question or a discussion point:** list it for the user. Don't answer it in Jira yourself.
- **Nothing to do** (a thank-you, a status note): mention it, once.

With `--pull`, skip step 4.

## 4. Write to Jira, after the user confirms
Show the plan first, as a table with one row per ticket: slug, key (or *new*), and the action
(create, update, link, subtasks, close as dropped, held, or nothing). Writing to Jira is visible to
the whole team, so **ask before writing**. On a yes:

1. **Create the epic first,** so its stories can name it as their parent. Use the type, the
   summary, the description and the `sdlc:<slug>` label from the export.
2. **Create or update each story.** Update only when the export's `digest` differs from the one in
   the last sync comment, and never update a held ticket.
3. **Add the missing blocked-by links.** Check the existing links first, so you don't add one twice.
4. **Create the missing subtasks,** if they're turned on.
5. **Close dropped stories:** add a comment quoting the amendment, then use the transition whose
   target status is `SDLC_JIRA_DROPPED_STATUS`. If the workflow has no such transition, leave the
   status alone and say so.
6. **After each create or update,** add the sync comment:
   `sdlc-kit sync · commit <first 12 of commit> · digest <digest>`, with a link to the intent.
7. **Close the review doc.** If the intent's header has a **Review doc** link and the Claude Docs
   connector is available, make sure the line under the doc's title reads "Accepted on <date>.
   Discussion continues in Jira: <link to the epic, or the story>". If the connector isn't
   available, ask the user to add that line.

If a call fails partway, stop. Report what was written and what wasn't. Running the sync again is
safe, because the labels find what already exists.

## 5. Bring Jira changes back as amendments
For each item in step 3 that changes the intent:
1. Show the item, and propose the amendment: what to strike through, and what replaces it.
2. Once the user agrees, make the change with `/sdlc-kit:review-intent <intent folder>`. Its
   amendment mode keeps the old wording struck through, adds a dated note, and opens the PR. Put
   the ticket key and the commenter in the Decisions row, e.g. "from PROJ-12, comment by <name>".
3. Never edit the default branch directly, and never treat a Jira edit as approved. The amendment
   PR is reviewed and merged like any other.

Once that PR merges, the next sync writes the new text over the held ticket and adds a sync comment,
which ends the hold.

## 6. Report
End with a table of slug, ticket key with a link, and what happened. Under it, list the held tickets,
the open questions found in Jira, and any amendment PRs opened. Say when to run the sync next:
- after an intent is merged;
- after a story's spec merges (its ticket gains the spec link and acceptance tests);
- after a plan merges, when subtasks are turned on;
- after an amendment merges.

## Hard rules
- No `SDLC_JIRA_PROJECT`, no sync. Never pick or guess a project key.
- Only merged intents are exported. Never create tickets from a draft.
- Never delete a Jira ticket, and never move one except a dropped story.
- Never overwrite a description someone edited in Jira. It becomes an amendment first.
- Never write to Jira without showing the plan and getting a yes.
- Never paste a token or password anywhere. The connector handles sign-in.
