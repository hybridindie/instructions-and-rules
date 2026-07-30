# Epic Acceptance Criteria Linter

<!--
  Shared content — referenced by harness-specific SKILL.md wrappers.
  version: 3.2.0, owner: John D
  invokes: .agents/evals/epic-rubric.md
  doctrine: .agents/doctrine/acceptance-criteria-rules.md,
            .agents/doctrine/source-discipline.md
-->

You use this skill to evaluate and refine acceptance criteria in an Epic.

## When to use
Use this skill after acceptance criteria have been drafted and you need a
quality pass before marking the Epic ready. The typical call sequence is:
`epic-composer` Phase 4 (Epic Draft) reads this file and applies its linting
rules, then Phase 5 reads `.agents/evals/epic-rubric.md` for the readiness
assessment.

You can also be invoked directly by the user via the `/epic-acceptance-linter`
command to review an existing Epic draft.

## Goal
Acceptance criteria should be clear, concise, specific, testable, aligned with
user and business outcomes, and realistic within constraints. The full
definition and the six linting rules live in
`.agents/doctrine/acceptance-criteria-rules.md` — this skill is the canonical
applier of those rules.

## Linting
Apply the six rules from `.agents/doctrine/acceptance-criteria-rules.md`
(observability, testability, specificity, outcome focus, non-conflict,
coverage) to each acceptance criterion. Use the example lints there as
reference for strengthening weak criteria.

## Response States

Every response must clearly label one of:

| State | When to use |
|---|---|
| **PASS** | All criteria meet the quality bar; Epic can proceed to readiness assessment |
| **NEEDS_REVISION** | One or more criteria require strengthening, clarification, or coverage additions |
| **BLOCKED** | Source material is too vague to support any criteria; switch back to Epic interview mode for clarity |

Label the state at the top of every response.

## Output format

### Acceptance Criteria Review
- Criteria reviewed
- Lint results per criterion
- Suggested improvements
- Coverage notes

## Behavior rules
Applies `.agents/doctrine/source-discipline.md`. On top of that:
- Prefer strengthening existing criteria over adding many new ones.
- Do not fabricate thresholds or metrics not supported by source material
  (per `acceptance-criteria-rules.md`).
- If the source material is too vague to support good criteria, read
  `.agents/skills/epic-interview.md` and follow its instructions to request
  clarity from the user.
- When the lint returns PASS, return to the caller (epic-composer Phase 5, or
  the user). If called from epic-composer, it will read `.agents/evals/epic-rubric.md`
  for the final readiness assessment.