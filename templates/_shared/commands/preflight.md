---
description: Run local CI checks (lint, format, types, constitution, tests) before pushing
---

Run all CI-equivalent checks locally and report results. This mirrors what the CI pipeline runs so issues are caught before push.

## Steps

1. **Suite-health gate (skip/xfail scan)** — Run `bash .claude/hooks/check-no-skipped-tests.sh` first. If any forbidden skip/xfail pattern is checked in, fix that before running anything else.

2. **Backend lint & format** — Run `cd {{BACKEND_PATH}} && {{LINT_BACKEND_CMD}}` and report pass/fail.

3. **Backend type check** — Run `cd {{BACKEND_PATH}} && {{TYPE_BACKEND_CMD}}` and report the error count. Focus on NEW errors in recently changed files.

4. **Constitution check** — Run `cd {{BACKEND_PATH}} && {{PKG_MANAGER_BACKEND}} run python scripts/check-constitution.py` and report pass/fail.

5. **Frontend lint** — Run `cd {{FRONTEND_PATH}} && {{LINT_FRONTEND_CMD}}` and report pass/fail.

6. **Frontend type check** — Run `cd {{FRONTEND_PATH}} && {{TYPE_FRONTEND_CMD}}` and report pass/fail. Focus on NEW errors.

7. **Backend contract tests (quick)** — Run `cd {{BACKEND_PATH}} && {{TEST_BACKEND_CMD}} tests/contract/ -x --tb=short -q` with a 120s timeout.

8. **Frontend unit tests (quick)** — Run `cd {{FRONTEND_PATH}} && {{TEST_FRONTEND_CMD}} --reporter=verbose` with a 120s timeout.

## Output

After all checks complete, produce a summary table:

| Check | Status | Details |
|-------|--------|---------|
| Suite health (skip scan) | PASS/FAIL | violation count |
| Backend lint | PASS/FAIL | error count |
| Backend format | PASS/FAIL | files needing format |
| Backend types | PASS/FAIL | new errors only |
| Constitution | PASS/FAIL | violations |
| Frontend lint | PASS/FAIL | error count |
| Frontend types | PASS/FAIL | new errors only |
| Backend contracts | PASS/FAIL | first failure |
| Frontend units | PASS/FAIL | failure count |

If any check FAILs, list the specific errors and suggest fixes. If all pass, confirm ready to push.

**Hard stop**: if the suite-health gate fails, do not proceed to the other checks — fix the skip/xfail violations first.
