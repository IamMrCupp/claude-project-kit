#!/usr/bin/env bats
# Phase 4 D.3 / A.6 — Terraform-shape detection and sibling-repo prompt.
# Detection signals: *.tf, *.tfvars, .terraform.lock.hcl, terragrunt.hcl,
# terraform/ or modules/ directories that contain *.tf files.

load 'helpers'

setup() { bootstrap_setup; }
teardown() { bootstrap_teardown; }

# --- Detection signals ---

@test "Terraform detection: *.tf at repo root triggers hint" {
  : > "$TEST_REPO/main.tf"
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory
  [ "$status" -eq 0 ]
  [[ "$output" == *"Terraform-shaped repo detected"* ]]
}

@test "Terraform detection: *.tfvars at repo root triggers hint" {
  : > "$TEST_REPO/terraform.tfvars"
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory
  [ "$status" -eq 0 ]
  [[ "$output" == *"Terraform-shaped repo detected"* ]]
}

@test "Terraform detection: .terraform.lock.hcl triggers hint" {
  : > "$TEST_REPO/.terraform.lock.hcl"
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory
  [ "$status" -eq 0 ]
  [[ "$output" == *"Terraform-shaped repo detected"* ]]
}

@test "Terraform detection: terragrunt.hcl triggers hint" {
  : > "$TEST_REPO/terragrunt.hcl"
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory
  [ "$status" -eq 0 ]
  [[ "$output" == *"Terraform-shaped repo detected"* ]]
}

@test "Terraform detection: terraform/ subdir with .tf files triggers hint" {
  mkdir -p "$TEST_REPO/terraform"
  : > "$TEST_REPO/terraform/main.tf"
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory
  [ "$status" -eq 0 ]
  [[ "$output" == *"Terraform-shaped repo detected"* ]]
}

@test "Terraform detection: modules/ subdir with nested .tf files triggers hint" {
  mkdir -p "$TEST_REPO/modules/vpc"
  : > "$TEST_REPO/modules/vpc/main.tf"
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory
  [ "$status" -eq 0 ]
  [[ "$output" == *"Terraform-shaped repo detected"* ]]
}

# --- Negative cases ---

@test "no Terraform signals: hint does not appear" {
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory
  [ "$status" -eq 0 ]
  [[ "$output" != *"Terraform-shaped repo detected"* ]]
}

@test "empty terraform/ subdir does not trigger hint" {
  mkdir -p "$TEST_REPO/terraform"
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory
  [ "$status" -eq 0 ]
  [[ "$output" != *"Terraform-shaped repo detected"* ]]
}

@test "empty modules/ subdir does not trigger hint" {
  mkdir -p "$TEST_REPO/modules"
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory
  [ "$status" -eq 0 ]
  [[ "$output" != *"Terraform-shaped repo detected"* ]]
}

@test "modules/ with non-.tf files (e.g. JS modules) does not trigger hint" {
  mkdir -p "$TEST_REPO/modules"
  : > "$TEST_REPO/modules/index.js"
  run "$BOOTSTRAP" "$TEST_WF" --skip-memory
  [ "$status" -eq 0 ]
  [[ "$output" != *"Terraform-shaped repo detected"* ]]
}

# --- Workspace mode suppresses the hint ---

@test "--workspace mode does not emit Terraform sibling-repo hint" {
  : > "$TEST_REPO/main.tf"
  WS="$TEST_TMP/lx-platform"
  run "$BOOTSTRAP" --workspace "$WS" --skip-memory
  [ "$status" -eq 0 ]
  [[ "$output" != *"Terraform-shaped repo detected"* ]]
}

# --- Hint also fires in dry-run mode (so users can preview the recommendation) ---

@test "Terraform hint fires in --dry-run mode" {
  : > "$TEST_REPO/main.tf"
  run "$BOOTSTRAP" --dry-run "$TEST_WF" --skip-memory
  [ "$status" -eq 0 ]
  [[ "$output" == *"Terraform-shaped repo detected"* ]]
}
