---
name: Commit messages — Conventional Commits, single line, signed off
description: Commit format rule — single `-m`, Conventional Commits, signed off. No body, no bullets. Context goes in the PR.
type: feedback
---

Always commit with:

```bash
git commit -s -m "type(scope): description"
```

One `-m`. Single line. DCO sign-off (`-s`). No body, no bullets, no "Co-Authored-By" trailers unless explicitly requested.

**Why:** Conventional Commits feed changelog tooling (git-cliff, release-please) which expects clean, structured one-liners. Multi-line commit bodies bloat the changelog and duplicate content that belongs in the PR description. Sign-off (`-s`) is required by many OSS projects (kernel, OBS, GNOME) and harmless where it isn't required.

**How to apply:**
- Before committing, confirm the type: `feat`, `fix`, `ci`, `docs`, `chore`, `refactor`, `test`, `perf`, `build`
- Scope is optional but preferred: `fix(auth)` beats `fix`
- If you need more words, they go in the PR body — not the commit
- For work projects where DCO isn't required or isn't wanted, drop `-s`. Check the project's CONTRIBUTING.md.
