---
description: "Use when validating constitutional compliance, PR acceptance criteria, enforcement gates, and CalVer policy."
---
# Enforcement, Compliance & Versioning (Article IX)

This rule applies globally to all work in the project.

## Specification Enforcement

- Include per-article checklist in PR description
- Run `cd backend && uv run python scripts/check-constitution.py` locally before PRs

ANTI-PATTERNS:
- Unexplained architectural deviations
- Doc drift (code changes without spec update)
- Adding/removing/renaming files without updating `STRUCTURE.md` and relevant docs (#334)

## Enforcement Gates

| Gate | Tool | Blocks Merge On |
|------|------|-----------------|
| Workflow Pipeline | `.claude/rules/workflow.md` | Skipped step (no associated GitHub issue exists, test-after-code, unaddressed PR comment, bundled drive-by fix) |
| Constitution Checker | `backend/scripts/check-constitution.py` | Structure violations |
| Test Coverage | CI coverage report | Below tier minimums |
| Suite Health | `.claude/hooks/check-no-skipped-tests.sh` + CI | Any `@pytest.mark.skip`, `xfail`, `it.skip`, `test.skip`, `describe.skip`, `.todo`, `xit`, `xdescribe`, or failing/erroring test in Vitest or pytest |
| Agent/Rule Drift | `.claude/hooks/check-agent-drift.sh` + PreToolUse hook | Any `.claude/agents|skills|commands|rules/*.md` stack version claim that contradicts `CLAUDE.md` (Python/FastAPI/PostgreSQL/React/TypeScript/Vite) |
| Type Check | pyright/mypy | New type errors |
| Lint | ruff | Lint errors |
| Security | bandit / dependency audit | High severity unresolved |
| Contracts | contract tests | Schema drift |

## PR Acceptance Checklist

> **Priority groups** (resolve blockers in order):
> 1. **Suite health** — zero failures, zero unconditional skips (Articles III, VIII)
> 2. **Architecture** — library isolation, DI, async (Articles I, II, V)
> 3. **Quality** — coverage tiers, structured errors, OpenAPI docs (Articles III, IV, VI)
> 4. **Security & CI** — auth, secrets, lint, type check (Articles VII, VIII)
> 5. **Traceability** — spec references, issue linked (Articles IX, Workflow)

- [ ] Workflow: Issue exists and is referenced (`closes #N`); test was
      red before the fix; preflight clean; review comments resolved or
      replied to (see `.claude/rules/workflow.md`)
- [ ] Article I: Library isolation (no business logic in routes)
- [ ] Article II: Services testable in isolation with DI
- [ ] Article III: Failing test first & coverage per tier
- [ ] Article III: Zero unconditional skips (no `@pytest.mark.skip`, `xfail`, or equivalent), zero failing tests. Conditional skips (`skipif` gated on a real environmental precondition) are permitted; placeholder skips for 'not implemented' are not. Backend `pytest` AND frontend `vitest` must be fully green.
- [ ] Article IV: Structured error mapping with DomainError
- [ ] Article V: Async & no blocking/global state
- [ ] Article VI: OpenAPI documented (Pydantic models)
- [ ] Article VII: Security (auth, secrets, encryption)
- [ ] Article VIII: CI green (lint, type, tests, security)
- [ ] Article IX: Spec references present

## Versioning Policy (CalVer)

Format: YYYY.MM.DD[-N]. Current version: 2026.04.03.

## Glossary

- **DomainError**: Structured base exception with stable `code` for clients
- **Contract Test**: Validates externally visible interface/schema boundary
- **Deterministic**: Same input -> same output (time/randomness controlled)
- **Idempotent**: Multiple identical invocations produce same final state
- **Envelope**: JSON wrapper: `{"data": ...}` or `{"error": ...}`
