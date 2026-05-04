---
description: Re-read CONTEXT.md, SESSION-LOG.md, and the current phase checklist mid-session — for picking up changes after a /close-phase or /session-end writeback, or re-anchoring on a long session. Same flow as Prompt 5 in PROMPTS.md.
---

## Precheck — is this a kit project?

Before doing anything else:

1. Run this Bash command to print the absolute path of this project's auto-memory pointer file, then use the `Read` tool on the **exact absolute path** the command prints (it will begin with `/`, not `~/` — do not pass `~/` to Read, it does not expand it):
   ```bash
   echo "$HOME/.claude/projects/$(echo "$PWD" | sed 's|/|-|g')/memory/reference_ai_working_folder.md"
   ```
   Do not rely on auto-memory recall — auto-memory loads only `MEMORY.md` into the session reminder, not the files it links to.
2. If it isn't there, OR the working-folder path it points to doesn't have a `CONTEXT.md` file, **stop** and tell me:
   > "No kit working folder found for this project. To use this command, either run `bootstrap.sh` from the kit (https://github.com/IamMrCupp/claude-project-kit) to create one, or `cd` into a kit-bootstrapped repo. If a working folder exists at a non-default path, tell me and I'll load from there."
3. Don't load partial state. If any required file is missing, treat the project as not-bootstrapped and bail with the message above.

If the precheck passes, continue.

---

Re-read my AI working folder so the rest of this session uses the latest state.

## Files to reload

1. `<working-folder>/CONTEXT.md` — project status, current phase, working rules
2. `<working-folder>/SESSION-LOG.md` — focus on the most recent entry
3. The current phase's checklist (`<working-folder>/phase-<N>-checklist.md`)

The working-folder path comes from `reference_ai_working_folder.md` in auto-memory. If that's not set, ask before guessing.

## Hand back

A short delta read (≤5 bullets):

- Current phase / status per CONTEXT.md right now
- Most recent SESSION-LOG entry — date, focus, what landed
- Any unticked items in the current phase checklist
- Open threads / next-steps from the latest log entry
- One sentence on what shifted since you last had this context loaded, if anything obvious — otherwise "no obvious deltas"

Then wait for my next instruction. Don't propose changes yet.

## Notes

- Useful right after running `/close-phase` or `/session-end` — the writeback updates the docs, but the active session is still working from the pre-writeback version until told to reload.
- The "what shifted" bullet is intentionally hedged with the fallback. Claude doesn't have perfect visibility into its own loaded context; honest framing beats false confidence.
- For a cold session start, use `/session-start` instead — this command assumes you're already mid-session.
