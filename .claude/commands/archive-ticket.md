---
description: Move a resolved per-ticket scratchpad from tickets/ into tickets/archive/, then note the archival in SESSION-LOG.md. Never touches the external tracker.
argument-hint: <KEY>
---

## Precheck — is this a kit project?

Before doing anything else:

1. Run this Bash command to print the absolute path of this project's auto-memory pointer file (`reference_ai_working_folder.md`), then use the `Read` tool on the **exact absolute path** the command prints (it will begin with `/`, not `~/` — do not pass `~/` to Read, it does not expand it):
   ```bash
   ~/.claude/scripts/kit-print-memory-pointer.sh
   ```
   If you get `command not found`, the kit's helper scripts aren't installed yet — from the kit checkout run `scripts/install-scripts.sh --global` (or re-run `bootstrap.sh` in this repo), then retry. Do not rely on auto-memory recall — auto-memory loads only `MEMORY.md` into the session reminder, not the files it links to.
2. If it isn't there, OR the working-folder path it points to doesn't have a `CONTEXT.md` file, **stop** and tell me:
   > "No kit working folder found for this project. To use this command, either run `bootstrap.sh` from the kit (https://github.com/IamMrCupp/claude-project-kit) to create one, or `cd` into a kit-bootstrapped repo. If a working folder exists at a non-default path, tell me and I'll load from there."
3. Don't load partial state. If any required file is missing, treat the project as not-bootstrapped and bail with the message above.

If the precheck passes, continue.

---

I want to archive the resolved ticket `$ARGUMENTS`. This only tidies the local working folder — it never transitions or comments on the external tracker.

## Step 1 — locate the tickets directory

- **Workspace mode** (`../workspace-CONTEXT.md` exists relative to the working folder): tickets live in `../tickets/`, archive in `../tickets/archive/`.
- **Single-repo mode**: tickets live in `<working-folder>/tickets/`, archive in `<working-folder>/tickets/archive/`.

## Step 2 — find the scratchpad

Look for a single file matching `<KEY>-*.md` directly in `tickets/` (NOT inside `tickets/archive/`).

- **No match:** if a `<KEY>-*.md` already exists under `tickets/archive/`, tell me it's already archived and stop. Otherwise tell me no active ticket matches `$ARGUMENTS` and stop — don't guess.
- **Multiple matches:** list them and stop. Ask me which one (or to resolve the ambiguity) — never guess.
- **One match:** that's the target.

If the kit's `archive-ticket.sh` helper is handy you may run it instead (`archive-ticket.sh <KEY> --working-folder <path>`) — same logic — but doing the move directly is fine.

## Step 3 — move it

Move the matched file into `tickets/archive/` (create `archive/` if missing). Preserve the filename and contents exactly — this is a move, not an edit. If a file with the same name already exists in `archive/`, stop and ask me to reconcile rather than overwriting.

## Step 4 — log it

Append a one-line entry to the working folder's `SESSION-LOG.md` under the current session, e.g.:

```
- Archived <KEY> — <one-line outcome / why it's done>
```

If there's no in-flight session entry yet, this can fold into the next `/session-end` writeback instead.

## Step 5 — hand back

Print:

1. What moved (`tickets/<KEY>-<slug>.md` → `tickets/archive/<KEY>-<slug>.md`).
2. A reminder: "Tracker is unchanged — transition `<KEY>` in your tracker yourself if it isn't already."

Then stop.
