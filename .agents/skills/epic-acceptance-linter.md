# Epic Acceptance Criteria Linter

<!--
  Shared content — referenced by harness-specific SKILL.md wrappers.
  version: 3.1.0, owner: John D
  invokes: .agents/evals/epic-rubric.md
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
Acceptance criteria should be:
- clear
- concise
- specific
- testable (yes/no or pass/fail)
- aligned with user and business outcomes
- realistic within constraints

## Linting rules
For each acceptance criterion, check:

1. **Observability**
   - Can someone observe or measure whether this criterion is satisfied?
   - Does it avoid internal or unobservable states?

2. **Testability**
   - Can this criterion be validated with a straightforward yes/no or pass/fail test?
   - Could a tester or automated test reasonably implement verification?

3. **Specificity**
   - Is the behavior or outcome described precisely?
   - Does it avoid vague phrases like "easy", "fast", "intuitive", "robust", or "user-friendly"?
   - If such terms appear, are they backed by thresholds or examples?

4. **Outcome focus**
   - Does the criterion describe an outcome rather than an implementation step?

5. **Non-conflict**
   - Is the criterion consistent with other criteria and the Epic's scope?
   - If criteria conflict, surface that conflict rather than resolving silently.

6. **Coverage**
   - Do the criteria collectively cover the main success path, alternate paths, key edge cases, and validation or permission aspects?

## Example lints

**Weak:** "The export feature is fast and user-friendly."
- Specificity / Observability: "fast" and "user-friendly" have no threshold.
- **Strengthened:** "When a user exports a report under 500 rows, the PDF
  downloads within 10s at p95."

**Weak:** "The API returns order history as JSON."
- Outcome focus: describes implementation, not observable value.
- **Strengthened:** "When a signed-in user opens Order History, their orders
  from the last 12 months are listed newest-first."

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
- Prefer strengthening existing criteria over adding many new ones.
- If the source material is too vague to support good criteria, read
  `.agents/skills/epic-interview.md` and follow its instructions to request
  clarity from the user.
- Do not fabricate thresholds or metrics not supported by source material.
- When the lint returns PASS, return to the caller (epic-composer Phase 5, or
  the user). If called from epic-composer, it will read `.agents/evals/epic-rubric.md`
  for the final readiness assessment.