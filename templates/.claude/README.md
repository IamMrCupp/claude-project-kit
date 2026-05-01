# `.claude/` starters

Two agents and six slash commands that follow the kit's session-start, session-end, session-handoff, and phase-close conventions. Staged here in your working folder; copy into your target repo's `.claude/` if you want them.

## What's here

### Agents (`.claude/agents/`)

- **`code-reviewer.md`** — reviews diffs, branches, or files for security / correctness / performance / style. Universal; works on any project.
- **`session-summarizer.md`** — drafts SESSION-LOG entries, CONTEXT.md status bumps, checklist scans, and memory candidates from the current session's activity. Specific to projects using the kit's working-folder pattern.

### Slash commands (`.claude/commands/`)

- **`/session-start`** — Prompt 1 from `PROMPTS.md` packaged as a slash command. Loads `CONTEXT.md`, `SESSION-LOG.md`, and the current phase checklist; hands back a 3–5 bullet grounding summary. Use at the start of a fresh session.
- **`/refresh-context`** — re-reads the working folder mid-session (after a `/close-phase` or `/session-end` writeback, or when a long session has drifted). Hands back a delta summary. Same flow as Prompt 5 in `PROMPTS.md`.
- **`/close-phase`** — runs the phase-close writeback (checklist tick, `plan.md` status, `CONTEXT.md`, `SESSION-LOG.md`, optional acceptance-results archive). Takes a phase number or infers from `CONTEXT.md`.
- **`/session-end`** — Prompt 3 from `PROMPTS.md` packaged as a slash command. Drafts the end-of-session updates, waits for confirmation before writing.
- **`/session-handoff`** — same drafting work as `/session-end`, but **writes immediately** without a confirmation gate. Use when waiting risks losing the session: switching to Claude desktop, context-window pressure, abrupt pause. Persistence > polish; review on the next `/session-start`.
- **`/pull-ticket <KEY>`** — pull a tracker ticket (JIRA / GitHub Issues / Linear / GitLab / Shortcut) into a per-ticket scratchpad at `tickets/<KEY>-<slug>.md`. Reads tracker config from `CONTEXT.md` (or `../workspace-CONTEXT.md` in workspace mode), fetches via the relevant MCP, fills the kit's ticket template. Updates `workspace-CONTEXT.md` and stages a `SESSION-LOG.md` line. **Read-only against the tracker** — never creates, edits, transitions, or comments. Same flow as Prompt 6 in `PROMPTS.md`. For terminal-driven use without Claude, see `pull-ticket.sh` at the kit root.

## How to activate them

These are **staged in your working folder, not in your target repo.** The kit doesn't modify the target repo — that's the kit's invariant. To activate the agents and commands, copy the directory into your target repo:

```bash
cp -r <working-folder>/.claude/ <your-repo>/.claude/
```

Then commit the target's `.claude/` (or `.gitignore` it) to taste — the kit doesn't have an opinion. Both agents and slash commands work the same way whether they're committed or not.

## Customizing

These are starters. Edit them, swap models in the frontmatter, restrict the tool allowlist, write new ones. The kit's role is to seed the pattern, not own the content.

To add a new agent: create `<working-folder>/.claude/agents/<name>.md` with frontmatter (`name`, `description`; optional `tools`, `model`). To add a new slash command: `<working-folder>/.claude/commands/<name>.md` with optional frontmatter (`description`, `argument-hint`, `allowed-tools`, `model`). Then re-copy into the target repo.
