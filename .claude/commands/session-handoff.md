---
description: Hand off mid-session — capture everything to disk now, no confirmation gate. Use when context is at risk (window pressure, switching machines, abrupt pause). Drafts and writes immediately; review on next session start.
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
