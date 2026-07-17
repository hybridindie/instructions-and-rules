---
name: epic-acceptance-linter
description: 'Reviews and strengthens Epic acceptance criteria for observability, specificity, testability, outcome focus, and coverage. Triggers: lint acceptance criteria, review AC, validate acceptance criteria, check epic quality, strengthen criteria, check testability.'
---

Read and follow the complete instructions at `.agents/skills/epic-acceptance-linter.md`.

If the file is not accessible, apply these core rules to each acceptance
criterion:
1. **Observability** — Can someone measure whether this is satisfied?
2. **Testability** — Can this be validated with a yes/no or pass/fail test?
3. **Specificity** — Does it avoid vague terms like "easy", "fast",
   "intuitive"? Are thresholds or examples provided?
4. **Outcome focus** — Does it describe an outcome, not an implementation step?
5. **Non-conflict** — Is it consistent with other criteria and the Epic scope?
6. **Coverage** — Do criteria cover success path, alternate paths, edge cases,
   and validation/permission aspects?

Label the response: PASS, NEEDS_REVISION, or BLOCKED.