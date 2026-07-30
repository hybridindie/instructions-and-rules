<!--
  epic-rubric.md — Readiness rubric for assessing Epic completeness
  Referenced by: .agents/skills/epic-composer.md (Phase 5), .agents/skills/epic-acceptance-linter.md
  Input format: epic_draft follows .agents/templates/epic/epic-shell.md,
                traceability_map follows .agents/templates/epic/traceability-template.md
  doctrine: .agents/doctrine/acceptance-criteria-rules.md,
            .agents/doctrine/source-discipline.md
  version: 3.2.0, owner: John D
-->

# Epic Readiness Rubric

Use this rubric to assess whether an Epic is ready for decomposition into
features, stories, and tasks. This rubric **assesses** — it does not teach.
Where a dimension's criteria are defined elsewhere, the dimension references
that source instead of restating it.

## Input format

The `epic_draft` input should follow the structure in
`.agents/templates/epic/epic-shell.md`. The `traceability_map` input should
follow `.agents/templates/epic/traceability-template.md`.

## Dimensions

Score each Pass/Gap. Assign Gap when its failing condition holds.

1. Problem clarity — Gap if the current-state problem is vague or assumed, not grounded in source.
2. Outcome focus — Gap if the desired state describes implementation, not an observable outcome.
3. Scope boundaries — Gap if In/Out of scope or the MVP/Phase-2 split is missing.
4. User and stakeholder clarity — Gap if the primary actor or decision owner is unnamed.
5. Constraints and dependencies — Gap if known constraints or dependencies are absent.
6. Assumptions and risks — Gap if material assumptions or risks are unstated.
7. Edge cases and validations — Gap if major unhappy paths or validations are missing.
8. Acceptance criteria quality — assesses `.agents/doctrine/acceptance-criteria-rules.md`. Gap if any AC fails one of those rules (observability, testability, specificity, outcome focus, non-conflict, coverage).
9. Success measures and metrics — Gap if there is no outcome metric, or baseline/target is unmarked.
10. Traceability — Gap if any scope item or AC lacks a source link.
11. Explicit unknowns and open questions — assesses `.agents/doctrine/source-discipline.md`. Gap if unknowns are hidden, presented as fact, or inferred content is not labeled.

## Readiness levels

Assign a readiness level based on the number and criticality of gaps:

- **Ready for Decomposition** — 0 gaps in critical dimensions (1-4), and at
  most 2 gaps in non-critical dimensions (5-11), each explicitly marked
  [BLOCKED] with an owner and non-blocking for decomposition.
- **Needs Clarification** — 3+ gaps in non-critical dimensions (5-11), with
  all critical dimensions (1-4) Pass.
- **Draft** — Any gap in critical dimensions (1-4). The Epic needs
  significant rework before decomposition.

### Critical vs non-critical dimensions
- **Critical (must pass)**: 1. Problem clarity, 2. Outcome focus,
  3. Scope boundaries, 4. User and stakeholder clarity
- **Non-critical (can have minor gaps)**: 5. Constraints and dependencies,
  6. Assumptions and risks, 7. Edge cases and validations,
  8. Acceptance criteria quality, 9. Success measures and metrics,
  10. Traceability, 11. Explicit unknowns and open questions

## Output format

Produce the following structure:

```
## Readiness Assessment

### Dimension Scores
State the evidence in Notes first, then assign Status.

| # | Dimension | Notes (evidence) | Status |
|---|-----------|------------------|--------|
| 1 | Problem clarity | ... | Pass / Gap |
| 2 | Outcome focus | ... | Pass / Gap |
| 3 | Scope boundaries | ... | Pass / Gap |
| 4 | User and stakeholder clarity | ... | Pass / Gap |
| 5 | Constraints and dependencies | ... | Pass / Gap |
| 6 | Assumptions and risks | ... | Pass / Gap |
| 7 | Edge cases and validations | ... | Pass / Gap |
| 8 | Acceptance criteria quality | ... | Pass / Gap |
| 9 | Success measures and metrics | ... | Pass / Gap |
| 10 | Traceability | ... | Pass / Gap |
| 11 | Explicit unknowns and open questions | ... | Pass / Gap |

### Readiness Level
Draft | Needs Clarification | Ready for Decomposition

### Quality Gaps
- (list each gap with the dimension it affects and what is needed to close it)

### Recommendation
Proceed to decomposition / Return to interview / Needs partial redraft
```
