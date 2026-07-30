<!--
  parallelization-doctrine.md — Shared parallel-first doctrine
  Referenced by: story-decomposer, task-decomposer,
                 story-rubric dimensions 11 & 15
  version: 1.0.0, owner: John D
  Single source of truth for the contract → tracks/waves → integration pattern.
  Replaces the parallel-first prose previously restated in both decomposers.
-->

# Parallel-First Doctrine

Decompose for maximum parallelism from the start. The default for any
independent work is **parallel**, not sequential. Mark work sequential only
when it genuinely depends on another unit's output.

## The pattern

1. Identify which work groups are independent (can run in parallel).
2. Define the **shared contract** that unblocks parallel work — the interface,
   API spec, type definition, or file format both sides need, defined upfront.
3. Define the **parallel tracks** (tasks) or **waves** (stories) — each is an
   independent stream an AI agent can execute without waiting on the others.
4. Define the **integration** task that merges all tracks.
5. Minimize the number of sequential gates. If a dependency can be broken with
   a shared contract defined upfront, do it.

When two units seem dependent, ask whether they can proceed in parallel behind
a shared contract (API spec, type definition, file format) defined upfront
rather than sequencing them.

## Parallelization decision

Determine whether the unit is parallelizable:

- **Yes**: 2+ independent tracks with a clear integration point, and the unit
  is M or L sized.
- **No**: single component, hard sequential dependency, or S sized.
- **Partial**: some tracks are independent but others are sequential.

Only parallelize when there are genuinely independent tracks. Do not
over-parallelize S-sized units or those with hard sequential dependencies.

## Output shape

Parallel-structured work is grouped so an AI harness can see at a glance which
units it can dispatch simultaneously and which must wait:

```
Shared contract (sequential — must complete first)
  → Track/Wave A (parallel — after contract)
  → Track/Wave B (parallel — after contract)
Integration (sequential — after all tracks)
```

## How callers use this file

- `story-decomposer` Phase 4 turns this doctrine into an explicit
  wave-grouped execution sequence for stories.
- `task-decomposer` Phase 2 applies it at the task level: shared contract →
  parallel tracks → integration.
- `story-rubric` dimensions 11 (dependency ordering + execution sequence) and
  15 (AI-parallelization structure) assess against this doctrine (Pass/Gap)
  without restating it.