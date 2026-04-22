---
name: Check off PR test criteria after passing
description: When manual tests pass, edit the PR body to tick checkboxes, paste measured evidence inline, mark sections ✅ PASS. Then recommend merge.
type: feedback
---

After running a PR's manual test plan and the tests pass, don't just say "tests pass" in chat — update the PR body itself:

```bash
gh pr edit <N> --body "$(cat <<'EOF'
<updated body with checkboxes ticked, evidence pasted, ✅ PASS markers>
EOF
)"
```

Only after the PR body reflects the actual test outcome do you recommend merge.

**Why:** the PR body is the permanent record. If someone comes back to a bug six months later and git-blames into this PR, they'll read the PR body — not the chat transcript. Evidence inline (log snippets, timings, observed behavior) converts "I tested this" into "here's what I saw." The checkboxes also force the tester to be honest about what actually ran vs. what was planned.

**How to apply:**
- Tick `[x]` on each checklist item that was exercised
- Paste the specific evidence that proves it: log lines, timings, command output — tight, not dumps
- Add `✅ PASS` or `❌ FAIL` markers at the top of each test section
- If a test didn't run (skipped, not applicable), say so explicitly — don't leave unchecked boxes ambiguous
- Only then recommend merge
