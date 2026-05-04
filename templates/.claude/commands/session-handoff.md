---
description: Hand off mid-session — capture everything to disk now, no confirmation gate. Use when context is at risk (window pressure, switching machines, abrupt pause). Drafts and writes immediately; review on next session start.
---

## Precheck — is this a kit project?

Before doing anything else:

1. Use the `Read` tool to load `~/.claude/projects/<KEY>/memory/reference_ai_working_folder.md`, where `<KEY>` is the absolute current working directory with `/` replaced by `-` (compute via `echo "$PWD" | sed 's|/|-|g'` — e.g. `/Users/foo/Code/bar` → `-Users-foo-Code-bar`). Do not rely on auto-memory recall — auto-memory loads only `MEMORY.md` into the session reminder, not the files it links to.
2. If it isn't there, OR the working-folder path it points to doesn't have a `CONTEXT.md` file, **stop** and tell me:
   > "No kit working folder found for this project. To use this command, either run `bootstrap.sh` from the kit (https://github.com/IamMrCupp/claude-project-kit) to create one, or `cd` into a kit-bootstrapped repo. If a working folder exists at a non-default path, tell me and I'll load from there."
3. Don't load partial state. If any required file is missing, treat the project as not-bootstrapped and bail with the message above.

If the precheck passes, continue.

---

We're handing this session off NOW. Capture everything to disk in one pass —
do **not** wait for my confirmation. Persistence over polish: I will review on
the next `/session-start`. The kit's normal `/session-end` flow drafts and waits
for review; this command exists for moments when waiting risks losing work.

1. Append a SESSION-LOG.md entry for today, using this shape:
   - Date (YYYY-MM-DD)
   - 1-line focus
   - Branches touched / PRs opened, merged, or still open (with numbers)
   - Decisions, rule changes, or gotchas worth recording for next session
   - Open threads ("what we'd pick up next time")
   Write the entry directly. If anything is uncertain, write your best guess
   and mark it `[CLAUDE-INFERRED]` so I can correct on next session start.

2. If `CONTEXT.md`'s "Current Phase Status" line is clearly out of date based
   on what changed this session, update it. Mark the line `[CLAUDE-INFERRED]`
   if the call was a judgment.

3. Tick any items in `phase-<N>-checklist.md` that landed this session. If a
   ticked item is missing a branch or PR number, leave a note in the SESSION-LOG
   entry rather than guessing.

4. If a preference or rule came up more than once this session, draft a
   `feedback_*.md` memory file for it under the project's auto-memory dir
   AND add a one-line entry to `MEMORY.md`. Better to write a draft I edit
   later than to lose the rule.

5. Include a **Next session prompt** as part of the SESSION-LOG entry —
   a short, copy-pasteable block to start the next session grounded.
   Tailor it from this session's state: focus phrase, current branch +
   open PR (if any), top open thread. If nothing is in flight, use the
   short form (`Load context and give me a 3-bullet summary of where we
   are.`). Format exactly as `templates/SESSION-LOG.md` shows:
   `**Next session prompt:**` followed by a fenced code block.

After writing, print a one-paragraph summary of what you wrote — what entries,
what status changes, what new memory. **Then echo the next-session prompt
back in chat** so I can grab it without reopening SESSION-LOG.md. That's the
read-on-next-session checkpoint.

## When to use this vs. `/session-end`

- **`/session-end`** — stable end of a working session, you have time to review
  drafts before they land. Default to this.
- **`/session-handoff`** — hand-off interrupt: switching to Claude desktop,
  context window pressure, abrupt pause, anything where waiting risks losing
  work. Persistence > review.

The trade-off is real: handoff occasionally writes something slightly off, which
gets corrected on the next `/session-start` read. Strictly better than losing
the session entirely.
