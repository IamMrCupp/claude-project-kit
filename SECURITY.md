# Security policy

`claude-project-kit` ships a shell script (`bootstrap.sh`) that runs on contributor and adopter machines, plus a set of templates and prompts that get copied into other projects. If you find a security concern in any of that surface, this doc is how to report it.

---

## What's in scope

- **`bootstrap.sh`** — argument injection, path traversal in `<working-folder>` / `--project-name` handling, `sed` delimiter collisions, unsafe handling of values from `git remote get-url`, accidental clobbering of files outside the documented write paths.
- **Memory placeholder substitution** — values that escape `{{PLACEHOLDER}}` boundaries during `sed` replacement and end up modifying unintended fields.
- **Templates and prompts** — content in `templates/` or `memory-templates/` that, when seeded into a downstream project, instructs Claude to read or exfiltrate data outside the project's expected scope. (`SEED-PROMPT.md` already includes a prompt-injection guard for target-repo content; gaps in that guard are in scope.)
- **CI workflows** — anything in `.github/workflows/` that could run untrusted code, leak secrets, or be triggered with elevated permissions from an unprivileged source.

## What's NOT in scope

- The kit's downstream projects. If you're using the kit and find a security issue in *your* project, that's between you and your project's policy — not this kit's.
- Best-practice suggestions for hardening downstream usage (e.g. "you should pin commit SHAs"). Open a regular issue for those.
- The kit's documentation phrasing or markdown rendering.

---

## How to report

**Preferred — GitHub Security Advisories (private vulnerability reporting):**
[Open a draft advisory](https://github.com/IamMrCupp/claude-project-kit/security/advisories/new). This keeps the report private until disclosure is coordinated. If the link returns "private vulnerability reporting is not enabled," fall back to email below — and mention it in your report so the maintainer can enable it.

**Fallback — email:** `mrcupp@mrcupp.com`. Subject line `[claude-project-kit security]`. Include:
- A description of the issue and which file(s) / version(s) it affects.
- Reproduction steps. A minimal `bootstrap.sh` invocation that triggers the issue is ideal.
- The impact you observed (file written outside the working folder, command executed unexpectedly, secret exposed, etc.).
- Whether you'd like credit in the disclosure, and how.

**Please do NOT:**
- Open a public GitHub Issue describing the vulnerability before it's been triaged.
- Post the report to Discussions, social media, or anywhere else public.
- Open a PR with the fix attached — that publishes the issue. Send the report first; we'll coordinate the fix branch privately.

---

## What to expect

This is a hobby / personal project, not a vendor product. Realistic expectations:

- **Acknowledgement:** within 7 days of the report.
- **Triage:** within 14 days. If the issue is in scope and reproducible, we'll agree on a coordinated disclosure timeline (typically 30–90 days depending on severity and exploitability).
- **Fix:** released as a `fix:` (patch bump) or `feat!:` (major bump if the fix is breaking) Conventional Commit. The CHANGELOG entry will reference the disclosure once coordinated.
- **Credit:** named in the release notes if you want it; anonymous if you prefer.

If a report turns out to be out of scope, you'll get a brief explanation and a pointer to the right place (regular issue, downstream-project policy, or "this is intended behavior").

---

## Other security posture

For transparency, the repo currently has these GitHub features enabled:

- **Dependabot security updates** — automated PRs for vulnerable dependencies.
- **Secret scanning** + push protection — accidental commits of common secret patterns (API keys, tokens, etc.) are blocked at push time.
- **Branch protection on `main`** — not currently configured. CI workflows (lychee link-check, bats) run advisory-only; merges aren't gated. Tracked as a maintainer follow-up; not a security-disclosure issue.
