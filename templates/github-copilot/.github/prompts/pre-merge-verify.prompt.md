---
description: Pre-merge verification prompt. Run all quality gates before merging a PR.
---

# Pre-Merge Verification

Run these checks in order. Any FAIL blocks merge.

## 1. Suite Health (Skip/XFail Scan)
```bash
bash .claude/hooks/check-no-skipped-tests.sh
```
Must report zero forbidden skip patterns.

## 2. Backend Tests
```bash
cd {{BACKEND_PATH}} && {{TEST_BACKEND_CMD}} tests/contract tests/unit -n auto --no-cov
```
Must exit zero.

## 3. Frontend Tests
```bash
cd {{FRONTEND_PATH}} && {{TEST_FRONTEND_CMD}}
```
Must exit zero.

## 4. Lint & Type
```bash
cd {{BACKEND_PATH}} && {{LINT_BACKEND_CMD}}
cd {{BACKEND_PATH}} && {{TYPE_BACKEND_CMD}}
cd {{FRONTEND_PATH}} && {{LINT_FRONTEND_CMD}}
cd {{FRONTEND_PATH}} && {{TYPE_FRONTEND_CMD}}
```
Must have zero NEW errors.

## 5. Constitution Check
```bash
cd {{BACKEND_PATH}} && {{PKG_MANAGER_BACKEND}} run python scripts/check-constitution.py
```
Must pass.

## 6. PR Checklist
- [ ] Issue referenced (`closes #N`)
- [ ] Review comments resolved or replied
- [ ] No unrelated drive-by fixes bundled
- [ ] Branch will be deleted on merge

If all pass, confirm: **READY TO MERGE**.
If any fail, list specific errors and required fixes.
