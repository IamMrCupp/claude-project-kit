# Architecture Decision Records

This directory holds **Architecture Decision Records (ADRs)** for the kit — short documents that capture an architecturally-significant decision, the context that forced it, the alternatives considered, and the consequences of going one way over another.

The kit doesn't need ADRs for routine choices (filename casing, prose style, individual prompt wording). It does need them when a decision shapes the *structure* of what the kit produces or how adopters use it — folder model, tracker integration shape, bootstrap surface, etc. — and when "why did we do it this way?" might come back as a question six months later.

## Format

One file per decision (or one cohesive cluster of tightly-coupled decisions). Filename pattern: `NNNN-short-slug.md`, sequential, never renumbered. Each ADR includes:

- **Status** — Proposed / Accepted / Deprecated / Superseded by ADR-NNNN
- **Date** — when the decision was accepted
- **Anchor issue / phase** — the concrete signal that prompted the decision
- **Context** — why this decision is needed; what changed
- **Decision(s)** — what we chose, with rationale
- **Alternatives rejected** — what we considered and why it lost
- **Consequences** — positive, negative, neutral effects downstream

A decision can record multiple sub-decisions if they're tightly coupled and only make sense together (see [`0001-multi-repo-folder-model.md`](0001-multi-repo-folder-model.md)). Otherwise, prefer one decision per ADR.

## When to write a new ADR

- A phase opens with non-trivial structural decisions that gate downstream work.
- A signal forces a change to an established convention (e.g. swapping merge strategy).
- An adopter or contributor asks "why do you do it this way?" and the answer isn't already written down.

If the decision can be captured in a single CONVENTIONS.md bullet, it doesn't need an ADR.

## Index

| # | Title | Status | Date |
|---|---|---|---|
| [0001](0001-multi-repo-folder-model.md) | Multi-repo + ticket-driven folder model | Accepted | 2026-04-27 |
