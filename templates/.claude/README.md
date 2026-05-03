# `.claude/` starters

Two agents and nine slash commands that follow the kit's session-start, session-end, session-handoff, phase-close, acceptance-test, and task-level (research / plan) conventions. Staged here in your working folder; copy into your target repo's `.claude/` if you want them.

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
- **`/run-acceptance [test-N | all]`** — run the current phase's acceptance tests. Classifies each one (run-automatically / run-with-confirmation / defer-to-human) per `CONVENTIONS.md` → "Automating acceptance tests where it makes sense", attempts the automatable items, and proposes writebacks to **both** `acceptance-test-results.md` and the open PR body (via `gh pr edit`). Posting back is the default, not opt-in. Same flow as Prompt 8 in `PROMPTS.md`.
- **`/research <topic-or-area>`** — deep-dive a topic in the codebase, write a research artifact (in the active ticket scratchpad if you're inside one, else `<working-folder>/research-<slug>.md`). Read + write-an-artifact only — never proposes code changes. Same flow as Prompt 9 in `PROMPTS.md`. Inspired by [Boris Tane's "How I use Claude Code"](https://boristane.com/blog/how-i-use-claude-code/).
- **`/plan <feature>`** — write a feature-scoped plan (Goal / Approach / Code snippets / Open questions / numbered todo list). Reads any recent `/research` artifact for the topic first, then writes to the active ticket scratchpad or `<working-folder>/plan-<slug>.md`. Plan-and-stop — never implements. Same flow as Prompt 10 in `PROMPTS.md`. Inspired by [Boris Tane's "How I use Claude Code"](https://boristane.com/blog/how-i-use-claude-code/).

## How to activate them

These commands and agents are **workflow-shaped**, not project-shaped — every kit project uses them the same way. Recommended install: **once, globally** at user level so they're available across every project on the machine. Use the kit's helper:

```bash
# Recommended: install at user level (~/.claude/{commands,agents}/).
# One install, every kit project on this machine.
<kit-dir>/scripts/install-commands.sh --global
```

The helper is **idempotent and write-once** — files already present in the target are skipped, never overwritten. Re-run after pulling kit updates to pick up new commands.

If you'd rather scope the install to a single repo (overriding any global copies for that repo, or keeping the kit's footprint visible per-project), use:

```bash
<kit-dir>/scripts/install-commands.sh --project <repo-path>
```

The staged copy in your working folder stays as a stable reference either way. To copy by hand instead of running the helper, the source is `<kit-dir>/templates/.claude/{commands,agents}/` — copy into `~/.claude/` (global) or `<your-repo>/.claude/` (per-project).

**On kit-coupling.** All slash commands and the `session-summarizer` agent expect a kit-bootstrapped project (CONTEXT.md / SESSION-LOG.md / phase-N-checklist.md / `reference_ai_working_folder.md` in auto-memory). When invoked in a project that isn't bootstrapped, each one **probes for the working folder up front** and bails with a friendly one-liner pointing at `bootstrap.sh` rather than crashing or doing partial work. Safe to install globally — they'll politely no-op outside kit projects. The `code-reviewer` agent is universal and works anywhere with no precheck.

## Customizing

These are starters. Edit them, swap models in the frontmatter, restrict the tool allowlist, write new ones. The kit's role is to seed the pattern, not own the content.

To add a new agent: create `<working-folder>/.claude/agents/<name>.md` with frontmatter (`name`, `description`; optional `tools`, `model`). To add a new slash command: `<working-folder>/.claude/commands/<name>.md` with optional frontmatter (`description`, `argument-hint`, `allowed-tools`, `model`). Then re-copy into the target repo.
