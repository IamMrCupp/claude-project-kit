# Prompts

Ready-to-paste prompts for starting Claude sessions in common scenarios. Copy the prompt, fill in any `<placeholders>`, paste into a fresh session.

---

## 1. Starting work on a project that uses this kit

Use this when opening a fresh Claude session in a repo you've already bootstrapped with the kit's templates and memory starters. The prompt points Claude at your persistent working folder so it picks up project state from where the last session left off.

### Short form — recommended for daily use

Once `reference_ai_working_folder.md` is in your project's auto-memory (the kit seeds it during bootstrap), the prompt collapses to one line:

```
Load context and give me a 3-bullet summary of where we are.
```

The memory tells Claude where the working folder lives, so you don't need to repeat the path. **This is the steady-state prompt** — paste it in, get your grounding summary, start working.

### Verbose form — first session, or no auto-memory yet

Use this if it's your very first session in a project, the auto-memory reference isn't set up yet, or you want Claude to see the full instructions explicitly:

```
Before we start, read these files in my AI working folder, in order:

1. `<working-folder>/CONTEXT.md` — project overview, working rules, current phase
2. `<working-folder>/SESSION-LOG.md` — chronological session history
3. The current phase's checklist (e.g. `<working-folder>/phase-<N>-checklist.md`)

These are my persistent project context — they live outside the repo and hold
scope, decisions, and current status. Don't edit them unless I ask; updates
happen at session end.

Once read, give me a 3–5 bullet summary of: where we are in the project, what
landed most recently, and any open threads. Then wait for my next instruction.
```

**Notes:**
- Replace `<working-folder>` with the actual path (e.g. `~/Documents/Claude/Projects/my-project/`).
- If you're resuming mid-PR, use [Prompt 4](#4-resuming-mid-pr) instead of either form above — it loads the same context but adds a structured branch + PR + CI assessment.
- The `/session-start` slash command (in `templates/.claude/commands/`) runs the verbose flow as a one-step invocation. Copy it into your repo's `.claude/commands/` to enable.
- **In workspace mode** (the working folder is a per-repo subfolder under a workspace dir), Claude should read `../workspace-CONTEXT.md` *first*, **before** the per-repo files — it identifies the **current initiative** so the per-repo load makes sense in context. Then read `../workspace-plan.md` if available for the broader initiative arc. Then load `<working-folder>/CONTEXT.md` etc. as normal. The verbose form's file list still works at the per-repo level; the workspace-level reads are additive.

---

## 2. Starting work on the kit itself

Use this when opening a fresh Claude session inside this repo (`claude-project-kit`) to improve the kit itself — add templates, refine conventions, fix docs. Fully self-contained; no prior conversation required.

```
Hi Claude. I'm working on `claude-project-kit` (the repo this session is
opened in — confirm with `pwd`). It's a scaffolding kit for starting
Claude-assisted projects: working-folder templates, auto-memory starters,
and cross-project conventions.

## Before we work — read these in order

1. `README.md` — what the kit is, why it works, what's inside
2. `SETUP.md` — how the kit is meant to be used for a new project
3. `CONVENTIONS.md` — the working rules the kit advocates; the kit itself
   should follow them (eat our own dogfood)
4. `PROMPTS.md` — the session-opening prompts the kit provides
5. One file each from `templates/` and `memory-templates/` so you've seen
   the concrete shape of what the kit produces

## Rules of engagement

- **Follow `CONVENTIONS.md` for this repo's own work** — Conventional Commits
  single-line with `-s` sign-off, branch name proposed before coding,
  merge-commit PR strategy, detailed manual test plans where applicable.
- If I ask for something that contradicts the kit's own conventions, flag it.
  A kit that preaches X while itself doing Y is a credibility leak.
- This repo is docs + templates — no runtime code — so "test plans" usually
  reduce to "did the README still render correctly, are template placeholders
  consistent across files," etc.

## To start

Read the files above, then give me a tight 5-bullet read on the repo:
what's strong, what's weak, where you'd expect a first-time user to get
confused. Don't make changes yet — align on direction first.
```

**Notes:**
- This prompt is deliberately verbose because it starts fully cold — no prior conversation, no memory on the kit repo.
- After a few sessions, if you want continuity across kit-development work, bootstrap the kit using its own templates: create `~/Documents/Claude/Projects/claude-project-kit/` with its own `CONTEXT.md` + `SESSION-LOG.md`, and then you can switch to the shorter prompt #1 above. Meta, but useful — and a live demo that the kit works.

---

## 3. Wrapping up a session

Use this at the end of a session to apply the end-of-session hygiene from [SETUP.md §7](SETUP.md). It takes stock of what actually happened and drafts the updates for your review — it does **not** edit the working folder autonomously.

```
We're wrapping up this session. Help me apply the end-of-session hygiene.
Do NOT edit any files yet — draft everything, show me, and wait for my
confirmation before writing anything.

1. Draft a SESSION-LOG.md entry for today:
   - Date (YYYY-MM-DD)
   - 1-line focus
   - Branches touched / PRs opened, merged, or still open (with numbers)
   - Decisions, rule changes, or gotchas worth recording for next session
   - Open threads ("what we'd pick up next time")

2. Suggest whether CONTEXT.md's "Current Phase Status" line needs a bump,
   based on what changed this session. If so, propose the new wording.

3. Scan the current phase-<N>-checklist.md:
   - Flag items that landed this session but aren't yet ticked
   - Flag ticked items missing a branch or PR number

4. Flag any preference or rule that came up more than once this session —
   those are candidates for a new feedback_*.md memory file. Draft the
   feedback entry if applicable.

5. Draft a **Next session prompt** as part of the SESSION-LOG entry — a
   short, copy-pasteable block I can grab tomorrow to start the next
   session grounded. Tailor it from this session's actual state: focus
   phrase, current branch + open PR (if any), top open thread. If
   nothing is in flight, fall back to "Load context and give me a
   3-bullet summary of where we are." Format the field as
   `**Next session prompt:**` followed by a fenced code block, matching
   the entry-format example at the top of `SESSION-LOG.md`.

Show me each of these as a separate section. I'll confirm each before
anything is written. After writing, echo the next-session prompt back
in chat so I can grab it without reopening SESSION-LOG.md.
```

**Notes:**
- If `reference_ai_working_folder.md` is set up in auto-memory, Claude already knows where the working folder lives. Otherwise prefix with: *"Working folder is `<path>`."*
- The "draft first, don't write" guard is load-bearing — session-end updates are easy to get wrong (overzealous status bumps, hallucinated PR numbers), and reviewing is faster than undoing.
- For a bare-minimum wrap-up (no checklist or memory review), the one-liner *"Draft a SESSION-LOG.md entry for today and show it to me"* is usually enough.
- **For mid-session handoffs** (switching to Claude desktop, context-window pressure, abrupt pause), use `/session-handoff` instead — same drafting work but writes immediately without the confirmation gate. The trade-off is real (occasionally writes something slightly off, corrected on the next `/session-start`) and strictly better than losing the session entirely.

---

## 4. Resuming mid-PR

Use this when a previous session ended with a branch in flight and you want to pick it up cleanly. Combines the working-folder context load (like Prompt 1) with a structured branch / PR / CI assessment so Claude has the full picture before proposing next steps.

```
I had a branch open from a previous session. Help me resume.

## Before we work — load context

1. Read `<working-folder>/CONTEXT.md`, `<working-folder>/SESSION-LOG.md`, and the
   current phase checklist — same as Prompt 1.
2. Note the most recent SESSION-LOG entry's "Open threads" / "Next steps"
   section if there is one — that's likely what this branch is about.

## Then assess the branch

Run these and report:

1. `git status` — anything uncommitted? Position relative to `origin/<branch>`?
2. `git log --oneline origin/main..HEAD` — what commits are on this branch?
3. `gh pr list --head <branch> --json number,state,title,body,statusCheckRollup`
   — is there an open PR?
4. If a PR exists, extract the test plan from the body. Note which checkboxes
   are ticked, which aren't.
5. Latest CI run for this branch — conclusion, and any failed check names.

## Hand back

A 5-bullet read:
- What this branch is for (your inference + SESSION-LOG cross-reference)
- What's been done (commits, ticked test-plan items)
- What's left (untested test-plan items, unaddressed review comments,
  CI failures)
- The likely next concrete step
- Any conflicts with `origin/main` since the branch was pushed

Don't start coding — wait for me to confirm direction.
```

**Notes:**
- Assumes the branch is already checked out. If you don't remember which branch, prefix with: *"My open branches: `git branch --no-merged origin/main`. Pick the right one with me first."*
- For a branch that was never pushed, skip steps 3–5 — no PR or CI exists yet.
- If `reference_ai_working_folder.md` is in auto-memory, the "load context" section can shrink to *"Load context (per memory)."*

---

## 5. Refreshing context mid-session

Use this mid-session — typically after a `/close-phase` or `/session-end` writeback, or when a long session has drifted and you want to re-anchor on the working folder's current state. Different from Prompt 1 because the session is already going; this just re-reads the docs so subsequent prompts use the updated content.

```
Re-read my AI working folder so the rest of this session uses the latest state.

## Files to reload

1. `<working-folder>/CONTEXT.md` — project status, current phase, working rules
2. `<working-folder>/SESSION-LOG.md` — focus on the most recent entry
3. The current phase's checklist (`<working-folder>/phase-<N>-checklist.md`)

## Hand back

A short delta read (≤5 bullets):

- Current phase / status per CONTEXT.md right now
- Most recent SESSION-LOG entry — date, focus, what landed
- Any unticked items in the current phase checklist
- Open threads / next-steps from the latest log entry
- One sentence on what shifted since you last had this context loaded, if anything obvious — otherwise "no obvious deltas"

Then wait for my next instruction. Don't propose changes yet.
```

**Notes:**
- Useful right after running `/close-phase` or `/session-end` — the writeback updates the docs, but the active session is still working from the pre-writeback version until told to reload.
- The "what shifted" bullet is intentionally hedged with the fallback. Claude doesn't have perfect visibility into its own loaded context; honest framing beats false confidence.
- For a cold session start, use Prompt 1 (or `/session-start` if installed) instead — this prompt assumes you're already mid-session.
- If `reference_ai_working_folder.md` is in auto-memory, the path doesn't need to be in the prompt — Claude knows where to look.

---

## 6. Pulling a ticket into a per-ticket scratchpad

Use this when starting work on a tracker ticket (JIRA, GitHub Issues, Linear, etc.) and you want a local working scratchpad seeded from the tracker — summary, AC, status. Read-only — pulls from the tracker, never pushes back. The scratchpad lives at `tickets/<KEY>-<slug>.md` and accumulates working notes, branches, and PRs as work happens; the tracker stays the source of truth.

```
Pull ticket <KEY> from the tracker.

## Step 1 — read tracker config

Read `<working-folder>/CONTEXT.md`. Find the **Tracker Configuration** section.
If `<working-folder>/../workspace-CONTEXT.md` exists, read that too — workspace-level
tracker config takes precedence in workspace mode.

Stop and ask before proceeding if:
- Tracker type is `none` or `other`
- MCP availability is `not installed` or `unknown`
- The ticket key doesn't match the project key

## Step 2 — fetch the ticket

Use the tracker MCP that matches the configured type (JIRA / GitHub Issues / Linear /
GitLab / Shortcut). Read-only — get / view / search only. Never create, edit,
transition, or comment.

## Step 3 — write tickets/<KEY>-<slug>.md

Use the kit's `templates/workspace/ticket.md` shape. Fill key, title, tracker URL,
status, summary, and acceptance criteria. Leave working notes, branches, decisions
empty for now. Slug is the title lowercased and dashed (max ~40 chars).

If a file with the `<KEY>-` prefix already exists in `tickets/` or
`tickets/archive/`, stop and ask before overwriting.

## Step 4 — update workspace-CONTEXT.md (workspace mode only)

Append the ticket to the **Active:** sub-section under `## Tickets` and bump
the **Last updated:** date.

## Step 5 — hand back

Print the file path, the first three lines (key + title, tracker link, status), and
remind me the tracker is the source of truth. Don't propose a branch — wait.
```

**Notes:**
- The `/pull-ticket <KEY>` slash command (in `templates/.claude/commands/`) runs this flow as a one-step invocation. Copy it into your repo's `.claude/commands/` to enable.
- For terminal-driven use without Claude, the `pull-ticket.sh <KEY>` helper script does the same thing (uses `gh` / `jira` / `glab` CLIs when available, writes a stub for tracker types without a CLI fallback).
- This is read/reference only. The kit never creates, edits, transitions, or comments on tracker resources — see ADR-0001 D3 and CONVENTIONS.md "Ticket-driven workflows → What the kit does NOT do with trackers".

---

## 7. Closing a phase

Use this when the current phase is done and you want to draft all the closure paperwork — checklist tick-throughs, `plan.md` status bump, `CONTEXT.md` update, acceptance-results archive, SESSION-LOG entry. Mirrors `/close-phase`. Includes the kit's acceptance-tests-must-exist enforcement.

```
Close phase <N> of this project. (If you don't know which phase, read
CONTEXT.md and infer the current one.)

## Files to load

1. `<working-folder>/CONTEXT.md` — current phase status
2. `<working-folder>/plan.md` — phase breakdown
3. `<working-folder>/phase-<N>-checklist.md`
4. `<working-folder>/SESSION-LOG.md` — last entry for context
5. `<working-folder>/acceptance-test-results.md` if it exists

## Enforcement — acceptance tests must exist

Before drafting anything else, verify the convention from CONVENTIONS.md →
"Acceptance tests at phase boundaries". Refuse and stop if either check fails:

1. The phase checklist contains a `## Acceptance testing` section.
2. Either `acceptance-test-results.md` exists and is non-empty (at least one
   Result field set to ✅ PASS or ❌ FAIL, not ⏳ Pending), OR the checklist's
   `## Phase exit` block contains a single line matching:
   `Acceptance tests intentionally skipped — rationale: <one sentence>`

If neither is met, stop and tell me which condition failed and how to fix it.
If a skip-rationale line is present, surface the rationale verbatim in the
SESSION-LOG entry drafted in Step 5 below.

## What to do

1. Tick remaining unchecked items in the phase checklist. Find the matching
   merged PR (`gh pr list --state merged`) for each, add PR number + merge
   date. Flag any item without a PR for human review rather than ticking
   blindly.
2. Update plan.md "Status" line at the top to reflect phase closure.
3. Update CONTEXT.md "Current Phase Status" block.
4. Archive acceptance results: rename `acceptance-test-results.md` →
   `acceptance-test-results-phase-<N>.md`, update CONTEXT.md Reference
   section to point at the archive.
5. Draft a SESSION-LOG entry covering focus, PRs landed, key decisions,
   non-obvious findings, open threads. Include a Next session prompt as
   a fenced code block under `**Next session prompt:**`.

## Hand back

Show each change as a diff. Wait for my confirmation per change before
writing. After confirmation, echo the next-session prompt back in chat.
Don't invoke `git commit` or push — I'll commit the working-folder updates
separately.
```

**Notes:**
- The `/close-phase` slash command runs this flow as a one-step invocation. Copy `templates/.claude/commands/close-phase.md` into your repo's `.claude/commands/` to enable.
- The enforcement rules above are the same ones the slash command applies. If you're terminal-only without slash-command support, this prompt keeps the discipline in place.
- See `CONVENTIONS.md` → "Acceptance tests at phase boundaries" for the rule and the explicit-skip escape hatch.

---

## When to write a new prompt

Add one here whenever you find yourself typing similar setup instructions into a fresh session for the third time. A good prompt is:

- **Self-contained** — assumes no memory of prior conversations
- **Specific about what to read** — don't make Claude guess
- **Explicit about rules of engagement** — merge strategy, commit format, test expectations
- **Ends with a concrete first action** — a summary, a plan, a question — so Claude has something to do before it asks "what do you want?"
