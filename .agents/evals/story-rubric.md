<!--
  story-rubric.md — Readiness rubric for story backlog
  Referenced by: .agents/skills/story-decomposer.md (Phase 5)
  Input format: story backlog follows .agents/templates/epic/story-shell.md
  doctrine: .agents/doctrine/parallelization-doctrine.md,
            .agents/doctrine/acceptance-criteria-rules.md,
            .agents/doctrine/ai-readable-spec-rules.md
  version: 2.2.0, owner: John D
-->

# Story Readiness Rubric

Use this rubric to assess whether a story backlog is ready for
implementation by AI coding agents. This rubric **assesses** — it does not
teach. Where a dimension's criteria are defined elsewhere, the dimension
references that source instead of restating it.

## Input format

The story backlog should follow the structure in
`.agents/templates/epic/story-shell.md`.

## Dimensions

### INVEST Criteria (critical — must pass)
1. **INVEST: Independent** — Gap if any story cannot be completed without
   waiting on another (except explicitly mapped dependencies).
2. **INVEST: Negotiable** — Gap if any story is a fixed contract leaving no
   room for implementation decisions.
3. **INVEST: Valuable** — Gap if any story delivers no measurable value to
   a user, the business, or the team (spikes/technical stories).
4. **INVEST: Estimable** — Gap if any story's scope or complexity is too
   unclear to estimate.
5. **INVEST: Small** — Gap if any story exceeds 1-3 days for a single
   developer.
6. **INVEST: Testable** — Gap if any story lacks BDD acceptance criteria
   verifiable with a pass/fail test.

### Quality Criteria (non-critical — minor gaps allowed)
7. **Vertical slicing** — Gap if any user story is a horizontal layer
   ("database", "API only") or technical stories are used beyond genuine
   prerequisites.
8. **Epic coverage** — Gap if any Epic AC is not covered by a user story,
   or any Epic constraint lacks a technical/spike story.
9. **Scope discipline** — Gap if any story falls outside the Epic's
   in-scope items.
10. **NFR traceability** — Gap if stories touching performance, security,
    accessibility, or compliance paths do not reference the relevant Epic NFRs.
11. **Dependency ordering + execution sequence** — assesses
    `.agents/doctrine/parallelization-doctrine.md`. Gap if the dependency
    graph is cyclic, lacks an explicit parallel-wave execution sequence,
    sequential gates are not minimized, any story lacks a
    "Parallelizable with"/"sequential" annotation, or sprint assignments
    are inconsistent with wave ordering.
12. **Epic back-link** — Gap if any story lacks an "Epic: [title]"
    back-link, its "Epic ACs covered" does not trace to a real Epic AC, or
    a technical/spike story does not trace to an Epic constraint.
13. **Acceptance criteria quality** — assesses
    `.agents/doctrine/acceptance-criteria-rules.md`. Gap if any story's
    acceptance criteria fail one of those rules (observability,
    testability, specificity, outcome focus, non-conflict, coverage).

### AI-Readiness Criteria (non-critical — minor gaps allowed)
14. **Task breakdown** — Gap if any story lacks a task breakdown where
    each task is specific enough for an AI coding agent to execute without
    clarifying questions, or file paths/component names/API endpoints are
    not named where known.
15. **AI-parallelization structure** — assesses
    `.agents/doctrine/parallelization-doctrine.md`. Gap if any M or L story
    lacks tasks structured as parallel tracks (shared contract → parallel
    tracks → integration), or the parallel structure was determined after
    task drafting rather than before.
16. **Story traceability** — Gap if any story does not trace back to Epic
    ACs and (through the Epic's traceability map) to original source
    material, or the source type (explicit/inferred/unresolved) is not
    noted.
17. **Risk and assumption surfacing** — Gap if any story lacks
    story-specific risks (with impact) and assumptions (with consequence
    if wrong).
18. **Feature flag and rollback** — Gap if stories modifying existing
    behavior lack a feature flag, or any story lacks a rollback approach.
19. **AI-readable language** — assesses `.agents/doctrine/ai-readable-spec-rules.md`.
    Gap if stories/tasks use ambiguous pronouns, omit specific
    component/file/API names, fail to distinguish existing vs. new code,
    or an AI agent would need to re-interpret requirements to implement.

## Readiness levels

Assign a readiness level based on the number and criticality of gaps:

- **Ready for Implementation** — 0 gaps in INVEST dimensions (1-6), and at
  most 3 gaps in non-critical dimensions (7-19), each explicitly noted and
  non-blocking. Stories are INVEST-compliant with BDD acceptance criteria,
  task breakdowns, Epic back-links, and source traceability.
- **Needs Revision** — 4+ gaps in non-critical dimensions (7-19), with all
  INVEST dimensions (1-6) Pass.
- **Draft** — Any gap in INVEST dimensions (1-6).

### Critical vs non-critical dimensions
- **Critical (must pass)**: 1-6 (all INVEST criteria)
- **Non-critical (can have minor gaps)**: 7-13 (quality criteria),
  14-19 (AI-readiness criteria)

## Output format

Produce the following structure:

```
## Story Readiness Assessment

### Dimension Scores
State the evidence in Notes first, then assign Status.

| # | Dimension | Notes (evidence) | Status |
|---|-----------|------------------|--------|
| 1 | INVEST: Independent | ... | Pass / Gap |
| 2 | INVEST: Negotiable | ... | Pass / Gap |
| 3 | INVEST: Valuable | ... | Pass / Gap |
| 4 | INVEST: Estimable | ... | Pass / Gap |
| 5 | INVEST: Small | ... | Pass / Gap |
| 6 | INVEST: Testable | ... | Pass / Gap |
| 7 | Vertical slicing | ... | Pass / Gap |
| 8 | Epic coverage | ... | Pass / Gap |
| 9 | Scope discipline | ... | Pass / Gap |
| 10 | NFR traceability | ... | Pass / Gap |
| 11 | Dependency ordering + execution sequence | ... | Pass / Gap |
| 12 | Epic back-link | ... | Pass / Gap |
| 13 | Acceptance criteria quality | ... | Pass / Gap |
| 14 | Task breakdown | ... | Pass / Gap |
| 15 | AI-parallelization structure | ... | Pass / Gap |
| 16 | Story traceability | ... | Pass / Gap |
| 17 | Risk/assumption surfacing | ... | Pass / Gap |
| 18 | Feature flag / rollback | ... | Pass / Gap |
| 19 | AI-readable language | ... | Pass / Gap |

### Readiness Level
Ready for Implementation | Needs Revision | Draft

### Quality Gaps
- (list each gap with the dimension it affects and what is needed to close it)

### Recommendation
Proceed to implementation / Return to decomposition / Needs story revision
```