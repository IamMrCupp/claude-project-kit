---
name: Automation for {{PROJECT_NAME}} — Ansible (CLI)
description: This project uses Ansible via the local CLI (`ansible-playbook`) rather than CI-driven runs.
type: reference
---

**{{PROJECT_NAME}}** uses **Ansible** via the local CLI for automation runs.

- **Primary command:** `ansible-playbook <playbook>.yml` with inventory, limit, and tag flags as needed.
- **Inventory:** typically `inventory/` or `hosts.yml` at repo root (check `ansible.cfg` for the default inventory path).
- **Vault:** `ansible-vault` for encrypted secrets. Vault password typically supplied via `--ask-vault-pass`, `--vault-password-file`, or the `ANSIBLE_VAULT_PASSWORD_FILE` env var.
- **Dry-run:** `--check` for dry-run, `--diff` for showing file diffs that would be applied. Combine them for maximum preview.
- **Targeting:** `-l <host-pattern>` to limit to specific hosts; `-t <tag>` for specific tagged tasks.

**Why:** CI-driven Ansible exists but this project runs it locally — the operator is the point of coordination. This means change control happens at the terminal, not in a PR dashboard. Safety hinges on discipline (use `--check`, review `--diff`, narrow scope with `-l` and `-t`).

**How to apply:**
- Before suggesting an `ansible-playbook` invocation that touches real hosts, propose the full command and show what `-l` / `-t` will constrain it to. Never shell out to a live playbook run without explicit user confirmation.
- Default to `--check --diff` for the first preview of any change. Only then propose the actual run.
- If the user asks "did it work," ask for the output of the previous run rather than guessing based on the playbook contents.
- Vault secrets never appear in commit messages, SESSION-LOG, or this memory — they're operator-local.
- Document any nonstandard inventory layout, role dependencies, or pre-run steps (e.g. `ansible-galaxy install`) in `CONTEXT.md`.
