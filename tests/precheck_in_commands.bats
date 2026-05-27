#!/usr/bin/env bats
# Regression check — every kit-coupled slash command and the session-summarizer
# agent must include a "Precheck — is this a kit project?" block instructing
# Claude to bail with a friendly message when invoked outside a kit working
# folder. Closes #82's "graceful degradation" requirement.

load 'helpers'

# Slash commands that read/write kit files (everything except code-reviewer
# is kit-coupled).
KIT_COUPLED_COMMANDS=(
  templates/.claude/commands/session-start.md
  templates/.claude/commands/session-end.md
  templates/.claude/commands/session-handoff.md
  templates/.claude/commands/session-verify.md
  templates/.claude/commands/refresh-context.md
  templates/.claude/commands/close-phase.md
  templates/.claude/commands/pull-ticket.md
  templates/.claude/commands/archive-ticket.md
  templates/.claude/commands/run-acceptance.md
  templates/.claude/commands/plan.md
  templates/.claude/commands/research.md
)

# Kit-coupled agents (code-reviewer is universal — no kit dependency).
KIT_COUPLED_AGENTS=(
  templates/.claude/agents/session-summarizer.md
)

@test "every kit-coupled slash command includes a Precheck block" {
  for cmd in "${KIT_COUPLED_COMMANDS[@]}"; do
    f="$KIT_ROOT/$cmd"
    [ -f "$f" ]
    if ! grep -q "^## Precheck — is this a kit project?$" "$f"; then
      echo "missing Precheck block: $cmd"
      return 1
    fi
  done
}

@test "every kit-coupled command Precheck mentions reference_ai_working_folder.md" {
  for cmd in "${KIT_COUPLED_COMMANDS[@]}"; do
    f="$KIT_ROOT/$cmd"
    if ! grep -q 'reference_ai_working_folder\.md' "$f"; then
      echo "missing reference_ai_working_folder.md probe in: $cmd"
      return 1
    fi
  done
}

@test "every kit-coupled command Precheck has a friendly bail message" {
  for cmd in "${KIT_COUPLED_COMMANDS[@]}"; do
    f="$KIT_ROOT/$cmd"
    if ! grep -q 'No kit working folder found for this project' "$f"; then
      echo "missing bail message in: $cmd"
      return 1
    fi
  done
}

# Regression guard for #187 / #190 / #218 — the precheck must (1) resolve the
# auto-memory pointer path via a single matchable Bash invocation that
# Claude Code's permission system can allowlist, and (2) Read the absolute
# path the script prints (not the literal "~/" form, which Read does not
# expand).
#
# Historical wordings that regressed and must stay out:
#   - "Look up `reference_ai_working_folder.md` in this project's auto-memory"
#     was ambiguous — models read it as "check the session reminder", which
#     only contains MEMORY.md, and bailed on properly bootstrapped projects.
#   - "Use the `Read` tool to load `~/.claude/projects/...`" — the Read tool
#     does not expand `~/`, so passing the literal `~/...` string fails with
#     "file not found" and the precheck bails the same way.
#   - The compound inline `git rev-parse ... && dirname || ...; echo ...`
#     pattern — compound shell can't be statically analyzed by Claude Code's
#     permission matcher, so every fresh session hit a permission prompt
#     that no allowlist rule could silence (#218).
@test "every kit-coupled command Precheck invokes kit-print-memory-pointer.sh" {
  for cmd in "${KIT_COUPLED_COMMANDS[@]}"; do
    f="$KIT_ROOT/$cmd"
    # Must invoke the extracted helper script with a clean, allowlist-friendly
    # single-command shape.
    if ! grep -qF '~/.claude/scripts/kit-print-memory-pointer.sh' "$f"; then
      echo "missing kit-print-memory-pointer.sh invocation in: $cmd"
      return 1
    fi
    # Must explicitly direct the model to NOT pass ~/ to Read.
    if ! grep -q 'do not pass `~/` to Read' "$f"; then
      echo "missing 'do not pass ~/ to Read' guidance in: $cmd"
      return 1
    fi
    # Old ambiguous wording must be gone.
    if grep -q "Look up \`reference_ai_working_folder\.md\` in this project's auto-memory" "$f"; then
      echo "regression — original ambiguous wording still present in: $cmd"
      return 1
    fi
    # Old tilde-passing wording must also be gone.
    if grep -q 'Use the `Read` tool to load `~/\.claude/projects/' "$f"; then
      echo "regression — tilde-path wording still present in: $cmd"
      return 1
    fi
  done
}

@test "every kit-coupled command Precheck includes the install-scripts fallback note" {
  # If a user has the new precheck shape but hasn't installed the helper
  # script yet (older kit install, upgraded the commands but not the
  # scripts), the precheck would fail silently with "command not found".
  # The markdown must point them at install-scripts.sh / bootstrap.sh so
  # they can self-recover without filing a confused issue.
  for cmd in "${KIT_COUPLED_COMMANDS[@]}"; do
    f="$KIT_ROOT/$cmd"
    if ! grep -qF 'scripts/install-scripts.sh --global' "$f"; then
      echo "missing install-scripts.sh fallback note in: $cmd"
      return 1
    fi
  done
}

@test "kit-coupled agents include a Precheck block" {
  for agent in "${KIT_COUPLED_AGENTS[@]}"; do
    f="$KIT_ROOT/$agent"
    [ -f "$f" ]
    if ! grep -q "^## Precheck — is this a kit project?$" "$f"; then
      echo "missing Precheck block: $agent"
      return 1
    fi
  done
}

@test "kit-coupled agents Precheck invokes kit-print-memory-pointer.sh" {
  for agent in "${KIT_COUPLED_AGENTS[@]}"; do
    f="$KIT_ROOT/$agent"
    if ! grep -qF '~/.claude/scripts/kit-print-memory-pointer.sh' "$f"; then
      echo "missing kit-print-memory-pointer.sh invocation in: $agent"
      return 1
    fi
    if grep -q 'Use the `Read` tool to load `~/\.claude/projects/' "$f"; then
      echo "regression — tilde-path wording still present in: $agent"
      return 1
    fi
  done
}

# Regression guard for #218 — the compound inline precheck Bash that was
# extracted into kit-print-memory-pointer.sh must NOT come back. The
# compound shape (chained `git rev-parse ... && dirname || ...; echo ...`)
# triggers Claude Code's "cannot be statically analyzed" permission prompt
# on every fresh session — re-adding it would break the allowlist fix.
#
# session-verify.md is exempt because it intentionally embeds the same
# logic inline in its Step 1 diagnostic dump (it's a manual verification
# command, not a per-session precheck — one prompt during /session-verify
# is tolerated; tracked separately if it ever becomes annoying).
@test "kit-coupled command Prechecks must not embed the old compound bash" {
  for cmd in "${KIT_COUPLED_COMMANDS[@]}"; do
    # Exempt session-verify.md's Step 1 diagnostic — see test header above.
    case "$cmd" in
      *session-verify.md) continue ;;
    esac
    f="$KIT_ROOT/$cmd"
    if grep -q 'REPO_ROOT=\$(git rev-parse --path-format=absolute --git-common-dir' "$f"; then
      echo "regression — old compound precheck bash still present in: $cmd"
      echo "(extract into kit-print-memory-pointer.sh per #218; the matcher cannot allowlist compound shell)"
      return 1
    fi
  done
}

@test "kit-coupled agents must not embed the old compound bash" {
  for agent in "${KIT_COUPLED_AGENTS[@]}"; do
    f="$KIT_ROOT/$agent"
    if grep -q 'REPO_ROOT=\$(git rev-parse --path-format=absolute --git-common-dir' "$f"; then
      echo "regression — old compound precheck bash still present in: $agent"
      return 1
    fi
  done
}

@test "code-reviewer agent does NOT include the kit Precheck (universal agent)" {
  f="$KIT_ROOT/templates/.claude/agents/code-reviewer.md"
  [ -f "$f" ]
  ! grep -q "Precheck — is this a kit project" "$f"
}
