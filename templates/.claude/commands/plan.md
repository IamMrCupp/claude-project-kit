---
description: Write a feature-scoped plan as a working-folder artifact. Includes Goal / Approach / Code snippets / Open questions / numbered todo list. Plan-and-stop — never implements.
argument-hint: <feature-or-task>
---

<!--
Inspired by Boris Tane, "How I use Claude Code"
(https://boristane.com/blog/how-i-use-claude-code/) — feature-scoped
planning phase that produces a written plan before any implementation,
with a load-bearing "don't implement yet" guard.
-->

## Precheck — is this a kit project?

Before doing anything else:

1. Look up `reference_ai_working_folder.md` in this project's auto-memory.
2. If it isn't there, OR the working-folder path it points to doesn't have a `CONTEXT.md` file, **stop** and tell me:
   > "No kit working folder found for this project. To use this command, either run `bootstrap.sh` from the kit (https://github.com/IamMrCupp/claude-project-kit) to create one, or `cd` into a kit-bootstrapped repo. If a working folder exists at a non-default path, tell me and I'll load from there."
3. Don't load partial state. If any required file is missing, treat the project as not-bootstrapped and bail with the message above.

If the precheck passes, continue.

---

## Argument

If `$ARGUMENTS` is empty, **stop and ask me what feature or task to plan** before reading or writing anything. Vague feature descriptions produce vague plans — make me commit to a scope statement first.

## Load-bearing rule

**Do NOT implement. This is plan-and-stop.** Write the plan, hand it back, and wait. After I review (and possibly leave inline notes for refinement), I'll come back and tell you when to implement.

If during planning you find a tiny obvious bug or trivial cleanup that's clearly in scope, note it in the plan's todo list — don't fix it inline.

## Step 1 — gather context

In order:

1. **Read recent research, if any.** If `<working-folder>/research-<slug>.md` exists for the same or adjacent topic, read it. If we're inside an active ticket scratchpad with a `## Research:` section, use that.
2. **Read the current phase checklist** (`<working-folder>/phase-N-checklist.md`) so the plan slots cleanly into existing phase structure.
3. **Read `CONVENTIONS.md`** — apply the project's commit / branch / PR conventions when planning the work breakdown.

If you can't find research and the feature is non-trivial, **stop and suggest running `/research` first** rather than planning blind.

## Step 2 — pick the artifact location

**Ticket-aware:**

- If the active session is working in a ticket scratchpad (`<working-folder>/tickets/<KEY>-<slug>.md`), append a new section:
  ```
  ## Plan: <feature>  (YYYY-MM-DD)
  ```
- Otherwise, write to `<working-folder>/plan-<slug>.md` where `<slug>` is a kebab-cased version of the feature name. If that file exists, append a dated section.

When in doubt, ask which path I want.

## Step 3 — write the plan

Required sections, in this order:

1. **Goal** — 1–2 sentences. What the user can do / what behavior changes / what bug is fixed when this is shipped. Write the *outcome*, not the activities.
2. **Approach** — ordered steps. High-level enough that a reader gets the shape in one minute. Each step is a unit of work, not a single line of code.
3. **Code snippets** — for the tricky bits *only*. Show the minimal example that proves the approach works (e.g. the new function signature, a tricky regex, a config snippet). Skip boilerplate — the reader can fill in idioms.
4. **Open questions / risks** — what could go wrong, what's underspecified, where decisions are deferred. Be specific. *"What if the input is empty?"* is more useful than *"edge cases."*
5. **Todo list** — numbered list at the bottom, one item per branch / PR. Each item maps to a unit you'd review and merge independently. Match the phase-checklist style if you're inside an active phase. Short imperative phrasing (*"Wire the X handler into the Y router"*).

## Hand back

- File path
- 3–5 bullet summary covering: the goal in one sentence, the major approach steps, the riskiest open question, and the count of todo items
- Then **wait**. Don't ask "should I start implementing?" — assume no until told yes.

## Iterating on the plan

If I add inline notes or comments to the plan file (e.g. `> NOTE: ...` lines or annotated text) and ask you to refine, follow these rules:

- Address each note. Update the relevant section of the plan.
- **Still don't implement.** Refinement is plan-document edits only.
- After refining, hand back a delta summary (what changed, what notes were addressed). Then wait again.

## When to use a different command

- **You haven't read the area yet** — run `/research` first, then `/plan`.
- **You're closing out a phase, not starting one** — use `/close-phase`.
- **You want to actually execute the plan** — that's a separate *"go ahead and implement"* prompt from me, after I've reviewed this plan. The kit doesn't ship a `/implement` slash command because the right execution loop is project-specific (typecheck command, test runner, build).
