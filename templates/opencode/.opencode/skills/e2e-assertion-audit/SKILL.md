---
name: e2e-assertion-audit
description: Scan E2E tests for no-op assertions and overly permissive checks
user-invocable: true
disable-model-invocation: true
---

# E2E Assertion Audit

Review E2E tests for assertions that pass without validating behavior.

## Anti-Patterns

1. No-op assertions (`expect(true).toBe(true)`)
2. Overly permissive (`toBeLessThan(500)`, `toBeTruthy()`)
3. Missing negative cases
4. Fragile selectors (`page.click('button')`)

## Output

File:line citations with concrete replacement assertions.
