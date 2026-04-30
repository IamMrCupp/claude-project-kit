# Contributing to claude-project-kit

A reusable scaffold for Claude-assisted projects. Contributions welcome — especially new tracker / CI variants and adopter feedback.

This guide tells you how to make changes that match the kit's conventions. If something here conflicts with [`CONVENTIONS.md`](CONVENTIONS.md), `CONVENTIONS.md` wins.

---

## Quick start

1. Fork the repo and clone your fork.
2. Make changes on a topic branch — see [Branch naming](#branch-naming).
3. Run the tests — see [Running tests](#running-tests).
4. Open a PR from your branch to `main`. The PR template prompts for the sections that matter.

---

## Common contribution shapes

### New tracker variant

Add support for an issue tracker beyond the current set (GitHub, Jira, Linear, GitLab, Shortcut).

1. Add `memory-templates/trackers/<tracker>.md` — mirror the format of an existing variant. Use `{{TRACKER_*_KEY}}`-style placeholders for fields the user provides at bootstrap time.
2. Add a case branch in `bootstrap.sh` for `--tracker <tracker>` (search `case "$TRACKER" in`).
3. Append the right line to the new project's `MEMORY.md` index inside that case branch.
4. Add a Bats test in `tests/bootstrap_tracker.bats` covering the new variant + any new flag.

### New CI variant

Same shape as tracker, but in `memory-templates/ci/` and `tests/bootstrap_ci.bats`.

### Documentation, examples, prompts

Edit the relevant `.md` file. The `link-check.yml` workflow runs `lychee --offline` on docs PRs — broken relative links will fail CI.

### Slash commands or agents

The canonical sources for the kit's slash commands and agents live under `templates/.claude/commands/` and `templates/.claude/agents/` — that's what `bootstrap.sh` copies into newly-bootstrapped projects.

The kit also dogfoods these files: identical copies live at `.claude/commands/` and `.claude/agents/` in the repo root so contributors can use `/session-start`, `/close-phase`, etc. while working on the kit itself. The two trees must stay byte-identical.

If you edit anything under `templates/.claude/commands/` or `templates/.claude/agents/`, run:

```bash
scripts/sync-claude-dogfood.sh
```

…to update the dogfood copies. The `tests/dogfood_claude_in_sync.bats` test enforces this in CI — it'll fail with a sync hint if the trees diverge.

---

## Branch naming

`<type>/<slug>` where `<type>` matches the Conventional Commit type you'll use: `feat`, `fix`, `docs`, `ci`, `test`, `chore`, `refactor`, `perf`, `build`. Examples: `feat/asana-tracker`, `fix/dry-run-tilde-bug`, `docs/contributor-onboarding`.

---

## Conventional Commits

Single-line, signed-off commits. No HEREDOC bodies. No AI co-author trailers.

```bash
git commit -s -m "feat(trackers): add asana variant"
```

`type(scope): description` — `type` drives the `release-please` version bump:

| Commit type | Bump | CHANGELOG | Notes |
|---|---|---|---|
| `feat` | minor | yes | new feature |
| `fix` | patch | yes | bug fix |
| `feat!` / `BREAKING CHANGE:` | major | yes | breaking change |
| `docs` | patch | yes | user-facing documentation (intentional — see below) |
| `refactor`, `test`, `ci`, `perf` | patch | yes | listed in CHANGELOG |
| `chore` | none | hidden | no release |
| `build` | none | hidden | no release |

The full mapping is in [release-please-config.json](release-please-config.json).

### Why `docs:` triggers a release

Out of the box, `release-please` does NOT bump on `docs:` commits. We've intentionally set `docs:` to `"hidden": false` in `release-please-config.json` so documentation that ships to users gets a CHANGELOG entry and a release tag. The kit IS its docs — there's no other artifact to ship.

If you want a change that does NOT trigger a release (e.g. internal cleanup, test scaffolding edits, config tweaks that don't ship to adopters), use `chore:`. It's hidden from CHANGELOG and won't bump the version.

---

## Running tests

The kit uses [Bats](https://bats-core.readthedocs.io/) for `bootstrap.sh` coverage.

```bash
# Install
brew install bats-core           # macOS
sudo apt-get install bats        # Debian/Ubuntu

# Run from repo root
bats tests/
```

CI runs the Bats suite on PRs that touch `bootstrap.sh`, `memory-templates/`, `templates/`, or `tests/`. The `lychee --offline` link-check workflow runs on PRs that touch any `*.md` file. See [tests/README.md](tests/README.md) for the layout, single-test invocation, and the gap around interactive-mode coverage.

---

## PRs

The repo has a [pull request template](.github/pull_request_template.md). The sections (Summary, Motivation, Design notes, Test plan, CHANGELOG) match what every prior PR has used.

- **Test plan is required** for runtime-affecting changes (anything that touches `bootstrap.sh`, the bats suite, or CI workflows). Numbered, copy-pasteable steps with expected outcomes. Tick the boxes after passing — `gh pr edit` to update the body.
- **Pure-docs PRs:** "no runtime change; verification is CI alone" is fine.
- **Merge strategy: merge commits only.** No squash, no rebase-merge — `release-please` consumes the granular Conventional Commits to generate the CHANGELOG.

---

## Issue templates

Use the closest-fit template:

- **Bug report** — something doesn't work as documented
- **Feature request** — open-ended idea
- **Tracker variant request** — request a new `--tracker <name>` variant
- **CI variant request** — request a new `--ci <name>` variant

The variant-request templates ask for the same shape we'd need to scaffold the variant ourselves. If you can fill them in, the PR is largely mechanical.

---

## A note for adopters who copy `.github/FUNDING.yml`

GitHub's Sponsor button does NOT render from `FUNDING.yml` alone — the repo also needs **Settings → General → Features → Sponsorships** enabled. This isn't documented prominently in GitHub's funding-file docs; we hit it on this repo and want to save you the same investigation.

---

## Questions

Open an issue with the closest-fit template (often "Feature request") and add the `question` label if there's no actionable change requested.
