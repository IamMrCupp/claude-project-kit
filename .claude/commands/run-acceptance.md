---
description: Run the current phase's acceptance tests — attempts the automatable ones, proposes writebacks to acceptance-test-results.md and the open PR body. Defers UI / judgment items to the human.
argument-hint: [test-N | all]
---

## Precheck — is this a kit project?

Before doing anything else:

1. Use the `Read` tool to load `~/.claude/projects/<KEY>/memory/reference_ai_working_folder.md`, where `<KEY>` is the absolute current working directory with `/` replaced by `-` (compute via `echo "$PWD" | sed 's|/|-|g'` — e.g. `/Users/foo/Code/bar` → `-Users-foo-Code-bar`). Do not rely on auto-memory recall — auto-memory loads only `MEMORY.md` into the session reminder, not the files it links to.
2. If it isn't there, OR the working-folder path it points to doesn't have a `CONTEXT.md` file, **stop** and tell me:
   > "No kit working folder found for this project. To use this command, either run `bootstrap.sh` from the kit (https://github.com/IamMrCupp/claude-project-kit) to create one, or `cd` into a kit-bootstrapped repo. If a working folder exists at a non-default path, tell me and I'll load from there."
3. Don't load partial state. If any required file is missing, treat the project as not-bootstrapped and bail with the message above.

If the precheck passes, continue.

---

Run acceptance tests for the current phase. Argument is optional:

- No argument or `all` → attempt every test in the plan
- `test-N` (e.g. `test-3`) → only that test

## Files to load

- `<working-folder>/CONTEXT.md` — confirms the current phase
- `<working-folder>/phase-<current-N>-checklist.md` — the `## Acceptance testing` section lists which tests exist
- `<working-folder>/acceptance-test-results.md` — current per-test record (Goal / Setup / Steps / Expected / Actual / Result)
- The open PR for the current branch, if any: `gh pr list --head $(git branch --show-current) --json number,body,title`

The working-folder path comes from `reference_ai_working_folder.md` in auto-memory.

## What to do

### 1. Classify each test per `CONVENTIONS.md` → "Automating acceptance tests where it makes sense"

For each test in scope, decide one of:

- **Run automatically** — bats / pytest / jest / shell commands; link-check / lint runs; CLI invocations whose expected output is grep-able; template renders diffable against a fixture. No external state mutation.
- **Run with confirmation** — anything that mutates external state (`gh pr edit`, `git push`, `gh release create`, hitting a real tracker, publishing). Propose the command, wait for nod.
- **Defer to human** — visual rendering on GitHub.com, behavior in a UI, prose-feel judgment. Don't silently skip — surface with rationale ("Test 4 needs Aaron's eye on the rendered GH page; can't be automated").

Print the classification table before running anything so the user sees what you're about to do.

### 2. Execute the run-automatically items

For each:

- Run the command (`bats tests/foo.bats`, `gh run list --branch X`, `grep -c pattern file`, etc.)
- Capture exit code + relevant output (the line(s) that matter, not entire logs)
- Decide PASS / FAIL against the test's Expected field
- On FAIL: capture the exact command, exact output, and a candidate fix. Do **not** silently retry.

### 3. Propose writebacks — both surfaces

After all run-automatically items finish, draft updates for **both**:

**A. `acceptance-test-results.md`** — for each tested item, fill in:
- **Actual:** the captured evidence (log line, run ID, output snippet)
- **Result:** ✅ PASS / ❌ FAIL — *next-step if fail*

**B. The open PR body** (if `gh pr list --head <branch>` returns one) — for each item that maps to a PR test-plan checkbox:
- Tick the box (`- [ ]` → `- [x]`)
- Paste evidence inline below the item
- Mark deferred-to-human items as `Aaron to verify` (or whatever the human's name / role is, from CONTEXT.md if available)

Show both diffs. Wait for confirmation per writeback. **Posting back is the default**, not opt-in — don't ask "want me to update the PR?" after the user already invoked `/run-acceptance`.

### 4. Apply writebacks after confirmation

- Write `acceptance-test-results.md` directly.
- Update the PR body via `gh pr edit <PR-number> --body-file <tempfile-with-full-new-body>`. Writing the full body in one shot is more reliable than patching individual lines.

### 5. Run-with-confirmation items

For each, propose the exact command + what it'll change. Run only after the user nods. Apply the same writeback flow as automatable items.

### 6. Defer-to-human items

Surface explicitly in the hand-back. Don't tick anything for these — they stay open with the rationale.

## Hand back

A summary table:

| Test | Class | Result | Evidence |
|---|---|---|---|
| 1. {{name}} | auto | ✅ PASS | {{one-line evidence}} |
| 2. {{name}} | confirm | ⏸ pending nod | {{proposed cmd}} |
| 3. {{name}} | human | ⏳ deferred | {{why}} |

Then list:
- Writebacks applied (paths + line counts)
- Items still pending the user (confirms, human-deferred)
- Any failures with command + output + candidate fix

Do **not** invoke `git commit` or `git push` as part of this command — the user reviews + commits writebacks separately.
