# Workflow Pipeline (canonical)

This rule applies globally to every change made to InfluencerSync. The
pipeline is the same for a one-line bug fix and a multi-week epic — only
the size of each step varies, never the order.

If you skip a step, you must name which one and why, in the same turn.

## The pipeline

```
1. Issue exists      →  GitHub issue tracking the work (one issue per merge)
2. Failing test      →  Red test that pins the new behavior or repros the bug
3. Green code        →  Minimal implementation that makes the red test pass
4. Preflight clean   →  pytest / vitest / skip-scan / type / lint all green
5. PR opened         →  Branch pushed, PR description references the issue
6. Comments addressed →  Every PR review comment resolved or replied to
7. Merge             →  Only after preflight green AND comments resolved
```

Each step gates the next. You do not start step N until step N-1 is done.

## MUST

### Step 1 — Issue exists

- Every change in `main` traces to a GitHub issue. If you find a bug, a
  latent defect, a missing test, or a refactor target while working on
  something else, **open an issue first** before fixing it. Don't bury
  fixes inside an unrelated PR.
- The issue is the unit of merge. One issue, one PR, one focused commit
  history. Combine only if the work is structurally inseparable.

### Step 2 — Failing test (TDD per Article III)

- Write the failing test **before** the implementation. The test must
  fail for the right reason (asserts the new behavior or repros the bug),
  not because the file doesn't compile.
- Test authoring order: **Contract → Integration → E2E → Unit**.
- For a bug, write a regression test that fails on `main` and passes
  with the fix. Commit the test and the fix together — never the fix
  alone.
- Run the new test and confirm it fails before writing implementation.
  "It will fail, trust me" is not evidence.

### Step 3 — Green code

- Write the minimum code that turns the red test green. Resist the urge
  to refactor or generalize during this step.
- Refactors happen in a separate step (or PR) once green is locked in.

### Step 4 — Preflight clean

Before pushing, on a clean checkout:

- `bash .claude/hooks/check-no-skipped-tests.sh` — zero skips
- Backend touched: `cd backend && uv run pytest tests/contract tests/unit -n auto --no-cov` (and the integration / e2e tiers if relevant)
- Frontend touched: `cd frontend && npx vitest run`
- Type / lint clean for changed files
- `cd backend && uv run python scripts/check-constitution.py` if backend structure changed

A push with a known-failing test is checked-in debt. Fix it before
pushing, not after.

### Step 5 — PR opened

- PR title format: `<type>(<scope>): <imperative summary> (closes #N)`
  matching recent commit history (e.g. `refactor(frontend): ...`).
- PR body includes: summary bullets, the issue's acceptance criteria as
  a checklist (with status), and a Test plan section.
- Draft PRs are fine for in-progress work — but do not request review
  until preflight is clean.

### Step 6 — Comments addressed

- Every PR review comment gets either a code change or a written reply
  explaining why no change is needed. Silence is not an answer.
- After pushing fixes, leave a one-line summary on the PR pointing to
  the commit that addresses the comments.
- If a comment surfaces a separate concern that doesn't belong in this
  PR, **open a follow-up issue and link it** — then resolve the comment
  with a pointer to the new issue.

#### Auto-review hook

`.claude/hooks/check-pr-create-reminder.sh` (wired as a PostToolUse Bash
hook) fires after every `gh pr create` and emits a reminder to schedule
a follow-up review of PR comments via the `/schedule` skill. Suggested
cadence is +30 min (catches Copilot/CI feedback) and +6 h (catches
human reviewers).

Override the hook for low-risk / experimental PRs:

- **Env var**: `INFLUENCERSYNC_SKIP_AUTO_REVIEW=1 gh pr create …`
- **PR title token**: include `[no-review]` anywhere in `--title`

Either makes the hook silently exit. Use the override sparingly — the
purpose of Step 6 is "no comment goes unaddressed," and the hook
exists precisely because that gets forgotten without a nudge.

#### Graph-staleness hook

The knowledge graphs at `frontend/src/graphify-out/` and
`backend/src/graphify-out/` (built by `/graphify`) are authoritative for
structural recommendations only when they're current.
`.claude/hooks/check-graph-staleness.sh` (wired as a PreToolUse Bash
hook) fires before every `git push` and emits a soft warning if the
unpushed commits include graph-relevant code changes but no
`graphify-out/` rebuild in the same range.

Graph-relevant path patterns:

- `frontend/src/services/**`
- `frontend/src/stores/**`
- `frontend/src/contracts/**`
- `frontend/src/types/contracts/**`
- `frontend/src/hooks/**`
- `backend/src/libs/**`
- `backend/app/**`

The hook **warns**, never blocks (always exits 0). A missed graph
rebuild isn't a correctness bug; it's a future-readability one. To
clear the warning, run `/graphify frontend/src --update` (or
`backend/src`) and include the regenerated artifacts in the same push.

Override (silent exit): include `[no-graph-rebuild]` in any unpushed
commit message. The override is range-wide — any commit in the
about-to-push range carrying the marker silences the warning for the
whole batch. Use sparingly for trivial refactors or for PRs where the
graph rebuild is intentionally a follow-up.

### Step 7 — Merge

- Merge only when: CI green, preflight green, all review comments
  resolved, and the PR's Test plan checkboxes are checked.
- Use the merge style consistent with recent history (squash, by default,
  matching the repo's existing pattern).
- Delete the branch on merge.

#### Exception — CI infrastructure failure (e.g., Actions billing block)

If CI cannot run because of an infrastructure issue outside the code's
control — GitHub Actions billing block, runner outage, GitHub-side
incident — the **CI green** gate is satisfied by a clean local
preflight on the merge commit's HEAD (Step 4: vitest, pytest,
skip-scan, type/lint).

This exception is for *not started* / *infra error* states only. A
CI run that started and produced real failures still blocks merge —
fix the failures, don't claim this exception.

When you use this exception:
- Note it in the merge commit body or PR description (e.g.,
  `CI infra block — Actions billing; local preflight: vitest 4004/4004
  green, skip-scan clean`) so the trail is auditable.
- Re-trigger CI as soon as infrastructure is restored, even on a
  merged PR — a green run after the fact closes the audit loop.

## ANTI-PATTERNS

- **Tests written after the implementation passes.** This is not TDD —
  the test loses its design pressure and often ends up rubber-stamping
  whatever the code happened to do.
- **Bug fixes without a regression test.** The bug came back once; a
  test is the only thing that prevents take 3.
- **"I'll open the issue later."** Issues opened after the PR are
  retrofitted to match what was already done. Open the issue first.
- **Bundling unrelated drive-by fixes into a feature PR.** Each
  unrelated fix is its own issue + PR, even if it's two lines.
- **Pushing with a failing test "to get CI to run it."** Run it locally.
  CI is a backstop, not a remote test runner.
- **Closing a review comment without a code change AND without a
  reply.** The reviewer can't tell whether you saw it.
- **Merging while a comment is still unresolved** because "it's a nit."
  Either fix the nit or reply explaining why you're declining.

## Self-check before each step

State, in one line, which step you are on and what evidence shows the
previous step is done. Examples:

- "Step 2 — failing test added at `tests/unit/foo_test.py:42`,
  confirmed red via `pytest tests/unit/foo_test.py::test_bar`."
- "Step 4 — preflight: vitest 4004/4004 green, skip-scan clean,
  changed-file tsc clean."
- "Step 5 — PR #954 opened, acceptance criteria checklist mirrored
  from issue #925."

If you cannot produce that line, you are not ready for the next step.
