---
paths:
  - "{{BACKEND_PATH}}/**/*.py"
---

# Testing: TDD Mandate (Article III)

Code is only written after failing tests are defined. Add regression tests for any bug found.

## Tiered Coverage Requirements

| Component Type | Minimum |
|----------------|---------|
| Security-critical (auth, OAuth, encryption, tokens) | 90%+ |
| Revenue-critical (payments, conversions, subscriptions) | 85%+ |
| Business logic | 70%+ |
| AI/ML services | 50%+ |
| Utilities & helpers | 50%+ |
| Security tests (CSRF, XSS, injection, rate limiting) | Dedicated suite required |

Aggregate: {{COVERAGE_AGGREGATE_BACKEND}}% across `{{BACKEND_PATH}}/src/libs/`, 60% across `app/`.

## MUST

- Write failing contract test before implementing public API shape
- Achieve minimum coverage per tier for EACH library under `{{BACKEND_PATH}}/src/libs/<service>`
- Include contract, integration, and E2E tests before merge
- Regression test for each defect before the fix commit
- Branch coverage for error paths — every exception path tested
- Security/revenue-critical components MUST NOT merge below tier minimums

## Test Authoring Order

Contract -> Integration -> E2E -> Unit

| Layer | Purpose | Directory |
|-------|---------|-----------|
| Contract | Schema/interface expectations | `tests/contract/` |
| Integration | Real DB/cache/infra | `tests/integration/` |
| E2E | Full user flows via HTTPX | `tests/e2e/` |
| Unit | Isolated logic branches | `tests/unit/` |

## Suite Health (BLOCKING — no exceptions)

The test suite is a binary signal. Either it is green and trusted, or it is a liar. A partially-green suite is worse than no suite at all because it normalises broken state. These rules exist to keep the signal trustworthy.

- **Zero failing or erroring tests may be checked in**, ever. Running the full suite (`{{TEST_BACKEND_CMD}} tests/`) on a clean checkout of the merged branch MUST exit zero. "Pre-existing failure" is not a defence — fix or delete.
- **Zero unconditional skips may be checked in**. Specifically forbidden:
  - `@pytest.mark.skip(reason=...)` — always an anti-pattern. Delete the test if its premise is invalid; fix it if the code drifted; rewrite it against the current architecture.
  - `@pytest.mark.xfail` — if the test is expected to fail, fix the code or delete the test. No dormant failures.
  - A bare `pytest.skip("not implemented")` or `pytest.skip("needs setup")` at the top of a test body is just an unconditional skip in disguise.
- **Conditional skips are permitted only when genuinely environmental.** Use `@pytest.mark.skipif(<bool_expr>, reason=...)` gated on a real precondition. Runtime `pytest.skip(...)` inside a test body is permitted only inside an explicit `if <env-precondition>:` guard.
- **Test drift is a bug, not a placeholder.** When you change a route, component, store, schema, service, or contract, the co-owning tests MUST be updated in the same commit.
- **Determinism is mandatory.** Any test that depends on wall-clock time, randomness, or external I/O must inject a deterministic provider (`Clock`, `RandomProvider`, `respx`, etc.). A passing-95%-of-the-time test is a failing test with extra steps.
- **Fixtures must match the domain they mock.** When a Pydantic model or schema grows a new required field, every test fixture that constructs it must be updated.
- **Mock shapes must match real library shapes.** Prefer `respx` over hand-rolled httpx patches. Prefer `MagicMock` for library objects where methods aren't truly async.
- **Assert on the canonical error envelope.** API errors land as `{"error": {"code": ..., "message": ..., "context": {...}}}` per Article IV. Tests asserting on legacy `{"detail": ...}` shapes are bugs.
- **Cross-tier-safe fixture cleanup.** An `autouse=True` conftest that truncates tables shared across test tiers is a cross-tier time bomb. Drop `autouse`, gate on foreign-tier detection, or scope to tier-private tables only.
- **Tests must be hermetic against process-global singletons.** Module-level caches live for the lifetime of the worker process. Tests relying on specific cache states must explicitly patch or reset singletons.

## ANTI-PATTERNS

- Retrofitting tests post-implementation
- Excessive mocking hiding integration risk
- Ignoring uncovered error path branches
- Trivial assertions that don't validate behavior
- `asyncio.sleep()` in tests — use deterministic waits or condition polling
- `assert "detail" in error_data` against this platform's API
- `autouse=True` conftest fixtures that truncate cross-tier-shared tables
- Tests that read process-global singletons without explicitly patching them
