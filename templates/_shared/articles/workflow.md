---
paths:
  - "**/*"
---

# Workflow Pipeline (canonical)

This rule applies globally to every change made to {{PROJECT_NAME}}. The pipeline is the same for a one-line bug fix and a multi-week epic — only the size of each step varies, never the order.

If you skip a step, you must name which one and why, in the same turn.

## The pipeline

```
1. Issue exists      →  GitHub issue tracking the work (one issue per merge)
2. Failing test      →  Red test that pins the new behavior or repros the bug
3. Green code        →  Minimal implementation that makes the red test pass
4. Preflight clean   →  {{TEST_BACKEND_CMD}} / {{TEST_FRONTEND_CMD}} / skip-scan / type / lint all green
5. PR opened         →  Branch pushed, PR description references the issue
6. Comments addressed →  Every PR review comment resolved or replied to
7. Merge             →  Only after preflight green AND comments resolved
```

Each step gates the next. You do not start step N until step N-1 is done.

## MUST

### Step 1 — Issue exists

- Every change in `main` traces to a GitHub issue. If you find a bug, a latent defect, a missing test, or a refactor target while working on something else, **open an issue first** before fixing it. Don't bury fixes inside an unrelated PR.
- The issue is the unit of merge. One issue, one PR, one focused commit history. Combine only if the work is structurally inseparable.

### Step 2 — Failing test (TDD per Article III)

- Write the failing test **before** the implementation. The test must fail for the right reason (asserts the new behavior or repros the bug), not because the file doesn't compile.
- Test authoring order: **Contract → Integration → E2E → Unit**.
- For a bug, write a regression test that fails on `main` and passes with the fix. Commit the test and the fix together — never the fix alone.
- Run the new test and confirm it fails before writing implementation. "It will fail, trust me" is not evidence.

### Step 3 — Green code

- Write the minimum code that turns the red test green. Resist the urge to refactor or generalize during this step.
- Refactors happen in a separate step (or PR) once green is locked in.

### Step 4 — Preflight clean

Before pushing, on a clean checkout:

- `bash .claude/hooks/check-no-skipped-tests.sh` — zero skips
- Backend touched: `cd {{BACKEND_PATH}} && {{TEST_BACKEND_CMD}} tests/contract tests/unit -n auto --no-cov` (and integration / e2e if relevant)
- Frontend touched: `cd {{FRONTEND_PATH}} && {{TEST_FRONTEND_CMD}}`
- Type / lint clean for changed files
- `cd {{BACKEND_PATH}} && {{PKG_MANAGER_BACKEND}} run python scripts/check-constitution.py` if backend changed

### Step 5 — PR opened

- PR title format: `<type>(<scope>): <imperative summary> (closes #N)`
- PR body: summary bullets, acceptance criteria checklist, Test plan section
- Draft PRs are fine — but do not request review until preflight clean

### Step 6 — Comments addressed

- Every PR review comment gets a code change or a written reply. Silence is not an answer.
- After fixes, leave a one-line summary pointing to the commit.
- If a comment surfaces a separate concern, **open a follow-up issue** and link it.

### Step 7 — Merge

- Merge only when: CI green, preflight green, comments resolved, Test plan checked.
- Use squash by default (matching repo pattern).
- Delete branch on merge.

## ANTI-PATTERNS

- Tests written after the implementation passes.
- Bug fixes without a regression test.
- "I'll open the issue later."
- Bundling unrelated drive-by fixes into a feature PR.
- Pushing with a failing test "to get CI to run it."
- Closing a review comment without a code change AND without a reply.
- Merging while a comment is still unresolved because "it's a nit."

## Self-check before each step

State, in one line, which step you are on and what evidence shows the previous step is done.
