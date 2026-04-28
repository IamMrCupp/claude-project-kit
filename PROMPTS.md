# Prompts

Ready-to-paste prompts for starting Claude sessions in common scenarios. Copy the prompt, fill in any `<placeholders>`, paste into a fresh session.

---

## 1. Starting work on a project that uses this kit

Use this when opening a fresh Claude session in a repo you've already bootstrapped with the kit's templates and memory starters. The prompt points Claude at your persistent working folder so it picks up project state from where the last session left off.

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
- Replace `<working-folder>` with the actual path (e.g. `~/Documents/Claude/Projects/my-project/`)
- **Once you've set up `memory-templates/reference_ai_working_folder.md` for the project**, the memory tells Claude where to look automatically — you can shorten the prompt to *"Load context and give me a 3-bullet summary of where we are."*
- If you're resuming mid-PR, use [Prompt 4](#4-resuming-mid-pr) instead of this one — it loads the same context but adds a structured branch + PR + CI assessment.

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

Show me each of these as a separate section. I'll confirm each before
anything is written.
```

**Notes:**
- If `reference_ai_working_folder.md` is set up in auto-memory, Claude already knows where the working folder lives. Otherwise prefix with: *"Working folder is `<path>`."*
- The "draft first, don't write" guard is load-bearing — session-end updates are easy to get wrong (overzealous status bumps, hallucinated PR numbers), and reviewing is faster than undoing.
- For a bare-minimum wrap-up (no checklist or memory review), the one-liner *"Draft a SESSION-LOG.md entry for today and show it to me"* is usually enough.

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

## When to write a new prompt

Add one here whenever you find yourself typing similar setup instructions into a fresh session for the third time. A good prompt is:

- **Self-contained** — assumes no memory of prior conversations
- **Specific about what to read** — don't make Claude guess
- **Explicit about rules of engagement** — merge strategy, commit format, test expectations
- **Ends with a concrete first action** — a summary, a plan, a question — so Claude has something to do before it asks "what do you want?"
