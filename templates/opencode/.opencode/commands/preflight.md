---
description: Run local CI checks (lint, format, types, constitution, tests) before pushing
---

Run all CI-equivalent checks locally and report results.

## Steps

1. Suite-health gate — Run skip/xfail scan.
2. Backend lint & format.
3. Backend type check (focus on NEW errors).
4. Constitution check.
5. Frontend lint.
6. Frontend type check (focus on NEW errors).
7. Backend contract tests (quick, 120s timeout).
8. Frontend unit tests (quick, 120s timeout).

## Output

Summary table: Check | Status | Details.
Hard stop if suite-health gate fails.
