---
description: End-of-session wrap-up — draft SESSION-LOG entry, suggest CONTEXT.md status updates, flag unticked checklist items, draft any new memory entries. Same flow as Prompt 3 in PROMPTS.md, packaged as a slash command.
---

## Precheck — is this a kit project?

Before doing anything else:

1. Look up `reference_ai_working_folder.md` in this project's auto-memory.
2. If it isn't there, OR the working-folder path it points to doesn't have a `CONTEXT.md` file, **stop** and tell me:
   > "No kit working folder found for this project. To use this command, either run `bootstrap.sh` from the kit (https://github.com/IamMrCupp/claude-project-kit) to create one, or `cd` into a kit-bootstrapped repo. If a working folder exists at a non-default path, tell me and I'll load from there."
3. Don't load partial state. If any required file is missing, treat the project as not-bootstrapped and bail with the message above.

If the precheck passes, continue.

---

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
   short, copy-pasteable block tomorrow-me can grab to start the next
   session grounded. Tailor it from this session's actual state:
   focus phrase, current branch + open PR (if any), the top open thread.
   If nothing is open or in flight, fall back to the short form
   (`Load context and give me a 3-bullet summary of where we are.`).
   Format the field exactly as `templates/SESSION-LOG.md` shows it —
   `**Next session prompt:**` followed by a fenced code block.

Show me each of these as a separate section. I'll confirm each before
anything is written. After I confirm and you write everything, **echo
the next-session prompt back to me in chat** so I don't have to reopen
SESSION-LOG.md to grab it.
