---
description: Deep-dive a topic or codebase area, write a research artifact in the working folder. Read + write-an-artifact only — never proposes code changes.
argument-hint: <topic-or-area>
---

<!--
Inspired by Boris Tane, "How I use Claude Code"
(https://boristane.com/blog/how-i-use-claude-code/) — task-level research
phase that produces a written report before any planning or implementation.
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

If `$ARGUMENTS` is empty, **stop and ask me what topic or area to research** before reading anything. The research scope must be explicit — vague research produces vague artifacts.

## Load-bearing rule

**Do NOT propose code changes. Do NOT implement anything. This is a read-and-write-an-artifact operation only.** If during the research you spot something that obviously needs fixing, note it as an *open question* in the artifact — don't reach for the editor.

## Step 1 — read deeply

Read the codebase area or topic specified in `$ARGUMENTS`:

- Follow imports / call chains. Don't stop at the first file — understand the surrounding context.
- Note non-obvious patterns: state machines, retry logic, custom error handling, ordering constraints, idempotence guards.
- Note conventions specific to this area (naming, file layout, test patterns).
- Note edge cases hinted at by error messages, special-case branches, or comment markers like `XXX` / `TODO` / `HACK`.
- If the topic spans multiple files, build a mental graph before writing.

## Step 2 — pick the artifact location

**Ticket-aware:**

- If the active session has been working in a ticket scratchpad — i.e. `<working-folder>/tickets/<KEY>-<slug>.md` exists AND has been recently edited / referenced AND the user's current focus appears to be that ticket — append a new section to it:
  ```
  ## Research: <topic>  (YYYY-MM-DD)
  ```
- Otherwise, write a standalone research artifact at `<working-folder>/research-<slug>.md` where `<slug>` is a kebab-cased version of the topic. If that file already exists, append a dated section rather than overwriting.

When in doubt, ask which path I want before writing.

## Step 3 — write the artifact

Sections to include:

1. **What this is** — one-paragraph summary of what the area does. High level. No code yet.
2. **Entry points** — the files / functions / endpoints where this area starts. Where you'd put a breakpoint to follow execution.
3. **Key components** — short bullets of the main pieces, with file paths.
4. **Specificities** — non-obvious patterns, conventions, ordering constraints, edge cases. The stuff a new contributor would trip over.
5. **Open questions** — things you noticed but couldn't resolve from reading alone. Anything you'd want to confirm with the human before planning.
6. **References** — file paths cited. Optional but useful for re-visiting.

## Hand back

A 3–5 bullet summary of the report, with the artifact's file path. Then **wait** — don't propose a plan, don't propose changes. The user reads the artifact and either asks follow-up research questions or moves on to `/plan`.

## When to use a different command

- **You want a feature-scoped plan** (Goal / Approach / Snippets / Todo list) — use `/plan` after this. `/plan` reads recent research artifacts when picking up the same topic.
- **You want whole-repo bootstrap research** — that's the `SEED-PROMPT.md` flow at bootstrap time, not this. `/research` is for an *area* of an already-bootstrapped repo.
- **You're trying to understand the kit's own setup** — read CONTEXT.md and SESSION-LOG.md (or use `/session-start`); don't reach for `/research` first.
