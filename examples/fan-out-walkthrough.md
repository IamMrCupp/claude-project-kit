# Worked example — subagent fan-out on a research-heavy phase

A concrete walkthrough of the fan-out pattern (see `CONVENTIONS.md` → *Subagent fan-out (parallel delegation)*). It uses the kit's `research-question` starter agent. Read it, don't copy it — the point is the *shape*, not these specific questions.

## The situation

You're starting a phase to **pick a job queue** for a new service. The decision needs three independent investigations:

1. How does the current codebase enqueue background work today? (codebase question)
2. What does Redis-backed BullMQ cost us operationally? (external question)
3. What does SQS cost us operationally? (external question)

None of these depends on the others — they're a textbook fan-out: three independent, non-trivial questions whose answers you'll merge into one decision.

## Don't fan-out when…

If question 2 were *"given the answer to question 1, which queue fits?"* — that's **sequential**, not parallel. You'd run question 1 first, then decide. Fan-out only pays off when the pieces are genuinely independent. (And if the whole thing were a five-minute grep, one agent beats the coordination overhead of three.)

## The fan-out

Spawn three `research-question` agents **in parallel** — a single message with three agent calls — each briefed with one self-contained question and the kit's return format:

```
Agent 1 → research-question:
  "How does this codebase enqueue background work today? Find the current
   mechanism, where jobs are defined, and how they're consumed. Return the
   standard brief (Question / Answer / Evidence / Confidence / Follow-ups)."

Agent 2 → research-question:
  "What are the operational costs of Redis-backed BullMQ for a service doing
   ~50 jobs/sec — infra, failure modes, ops burden? Return the standard brief."

Agent 3 → research-question:
  "Same question for AWS SQS at ~50 jobs/sec. Return the standard brief."
```

Each agent starts cold, investigates its one question, and returns a tight brief that stands on its own — `file:line` cites for the codebase one, doc links for the cost ones.

## The merge (still your job)

Fan-out gives you three briefs in roughly the wall-clock time of one — but the **synthesis is yours**. Read the three briefs in one pass, reconcile them (e.g. "we already run Redis → BullMQ's ops cost is near-zero for us; SQS adds a new dependency"), and record the decision in `plan.md` / the phase checklist. The agents did the legwork; you made the call.

## When it would have been a mistake

If you'd fired five agents at a task one could handle — say, "review these five files" when the files are tiny and interrelated — you'd burn 5× the tokens and get five partial drafts to stitch together. Fan-out is a wall-clock optimization for independent, non-trivial work, not a default. See the cost note in `CONVENTIONS.md`.
