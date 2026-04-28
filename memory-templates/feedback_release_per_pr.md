---
name: Don't manually tag releases when release automation is configured
description: If the project uses release-please (or similar), do nothing release-wise after a normal PR merge — the automation opens/updates a release PR. Manual `gh release create` is a fallback for when the automation is broken.
type: feedback
---

When a project has release automation configured (e.g. release-please, semantic-release, changesets), **do not manually tag or `gh release create` after a normal PR merge.** The automation handles it.

For release-please specifically:
- On every push to `main`, the workflow opens or updates a release PR that bundles all commits since the last tag with a generated CHANGELOG section.
- Merging the release PR creates the tag + GitHub Release in one action.

**How to apply:**
- When informed that a normal feature / fix PR merged: **do nothing release-wise.** The release automation will open or update its release PR within seconds. The user is responsible for reviewing and merging that PR when they're ready to cut a release.
- When informed that a **release PR** (titled like `chore(main): release <version>`) merged: the tag + release are already published — no further action needed.
- **Commit types matter.** `feat:` → minor bump, `fix:` → patch bump, `feat!:` or `BREAKING CHANGE:` in body → major. Non-bumping types (`docs:`, `chore:`, `test:`, etc.) don't trigger a release on their own but appear in the CHANGELOG once the next bumping commit lands. (Some kits intentionally configure `docs:` to bump — check `release-please-config.json` if one's present.)
- **CHANGELOG-in-PR is not required** under release-please. Hand-written entries in feature PRs are fine (release-please merges cleanly) but not necessary.
- **Fall back to manual tagging only if** the automation is broken (workflow disabled, config misconfigured, etc.) — and only after proposing the manual commands for user confirmation.

**What to propose if a manual release is needed:**

```bash
git tag -a v<X.Y.Z> <merge-sha> -m "<short title>"
git push origin v<X.Y.Z>
gh release create v<X.Y.Z> --latest --title "v<X.Y.Z> — <title>" --notes "..."
```

Always get user confirmation before executing.

**Detect whether release-please is configured:** look for `.github/workflows/release-please.yml` and `release-please-config.json` at the repo root.
