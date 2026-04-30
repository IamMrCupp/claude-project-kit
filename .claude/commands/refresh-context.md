---
description: Re-read CONTEXT.md, SESSION-LOG.md, and the current phase checklist mid-session — for picking up changes after a /close-phase or /session-end writeback, or re-anchoring on a long session. Same flow as Prompt 5 in PROMPTS.md.
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
