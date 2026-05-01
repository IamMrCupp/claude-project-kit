# Session Log — {{PROJECT_NAME}}

Chronological record of Claude working sessions. Each entry captures what was done, decisions made, and anything non-obvious that future sessions should know.

**Append-only.** Never delete past entries. If something in an old entry turns out wrong, note the correction in the current session's entry rather than editing history.

> **Workspace mode:** if this `SESSION-LOG.md` lives inside a workspace per-repo subfolder, the per-ticket scratchpads at `../tickets/<KEY>-<slug>.md` are the canonical record for ticket-specific decisions and acceptance criteria. SESSION-LOG entries summarize and cross-reference; tickets can be touched by multiple sessions and span repos.

---

## Entry format

Use this shape for every session entry. Keep prose tight — future-you will scan, not read.

```
## Session: {{YYYY-MM-DD}} — {{short focus phrase}}

**Focus:** {{one sentence — what this session was about}}

**Tickets touched** (workspace mode only — omit if single-repo):
- [{{KEY}}](../tickets/{{KEY}}-{{slug}}.md) — {{what got done on it this session}}
- …

**Branches/PRs:**
- `{{branch-name}}` → PR #{{N}} (merged / open / abandoned)
- …

**Key decisions:**
- {{decision + one-line rationale}}
- …

**Non-obvious findings** (things worth knowing in the next session):
- {{…}}

**Open threads / next steps:**
- {{…}}
```

---

<!--
Session entries go below. `bootstrap.sh` appends a factual "Bootstrap" entry
on first run capturing the date, working-folder path, repo path, tracker /
CI config, and kit version — so the bootstrap session is durable even if
hand-off interrupts before /session-end runs. Subsequent sessions append
their own entries here using the format above.
-->
