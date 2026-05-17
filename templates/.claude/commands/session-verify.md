---
description: Dump every kit-loaded resource — auto-memory dir, MEMORY.md disk-vs-runtime parity, working-folder files, workspace files — as a verification table. Use after `/session-start` (or when you suspect auto-memory is loading from the wrong path).
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

This command runs a **verification dump** — it confirms what the kit has actually loaded for this session vs. what it should have loaded. The point is to catch silent drift (e.g. the v0.39.x dot-sanitization bug, where the runtime auto-loaded `MEMORY.md` from a path that didn't match the precheck's resolved path).

Read-only. No writebacks, no fixes — just report what you find.

## Step 1 — resolve the auto-memory directory

Run this Bash command to print the absolute path of the auto-memory directory the precheck resolves to, plus a directory listing:

```bash
REPO_ROOT=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) && REPO_ROOT=$(dirname "$REPO_ROOT") || REPO_ROOT="$PWD"
MEM_DIR="$HOME/.claude/projects/$(echo "$REPO_ROOT" | sed 's|[/.]|-|g')/memory"
echo "$MEM_DIR"
ls -1 "$MEM_DIR" 2>/dev/null || echo "(directory does not exist)"
```

The `git rev-parse` step makes the resolution worktree-aware: from inside a `git worktree`, it walks up to the parent repo's `.git` directory before sanitizing, matching where bootstrap seeded auto-memory.

## Step 2 — compare on-disk MEMORY.md to runtime auto-memory

The system reminder for this session contains the auto-loaded `MEMORY.md` content. Compare it to the on-disk file at `$MEM_DIR/MEMORY.md`:

1. Count index entries on disk:
   ```bash
   grep -c '^- \[' "$MEM_DIR/MEMORY.md" 2>/dev/null || echo 0
   ```
2. Count index entries in the system-reminder copy (the auto-loaded `MEMORY.md` you can already see in context).
3. List the first 3 entry titles from each side. If they don't match, flag it.

**Mismatch signal:** if the two counts differ, or the titles differ, the runtime is auto-loading from a different path than the precheck resolves to. That's the bug shape #205 fixed; it can also surface from a stale `~/.claude/projects/` directory left over from before the fix landed.

## Step 3 — working-folder files

From `reference_ai_working_folder.md` (already loaded above), extract the working-folder path. Then for each of these files, report absolute path + line count + a single signal line:

- `<working-folder>/CONTEXT.md` — signal = the `**Last updated:**` line if present
- `<working-folder>/SESSION-LOG.md` — signal = the date of the most recent `## Session:` heading
- The current phase checklist (e.g. `<working-folder>/phase-N-checklist.md` — find via `CONTEXT.md`'s "Current Phase Status" or list all matching files) — signal = phase number + status

Use `wc -l` and `grep` / `head` for the signal lines. Do not re-load the files into context — you only need their metadata for the dump.

## Step 4 — workspace mode (only if applicable)

If `<working-folder>/../workspace-CONTEXT.md` exists, also report:
- `workspace-CONTEXT.md` — abs path, line count
- `workspace-plan.md` (if present) — abs path, line count
- `workspace-phase-N-checklist.md` (if present) — abs path, line count

Skip this step entirely if not in workspace mode.

## Hand back

A single markdown table — one row per resource:

| Resource | Path | Lines | Signal |

Followed by a one-line verdict on the next line:

- **OK** — disk MEMORY.md matches runtime auto-memory, all expected files present.
- **MISMATCH** — disk MEMORY.md and runtime auto-memory differ; quote the specific signal (e.g. "disk has 22 entries, runtime has 4").
- **MISSING** — one or more expected files not found at their resolved paths.

Don't propose fixes. If MISMATCH or MISSING fires, tell me which one and let me decide next steps.
