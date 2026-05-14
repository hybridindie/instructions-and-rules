# Enforcement, Compliance & Versioning (Article IX)

This rule applies globally to all work in the project.

## Specification Enforcement

- Include per-article checklist in PR description
- Run constitution checker locally before PRs

ANTI-PATTERNS:
- Unexplained architectural deviations
- Doc drift (code changes without spec update)
- Adding/removing/renaming files without updating `STRUCTURE.md` and relevant docs

## Enforcement Gates

| Gate | Tool | Blocks Merge On |
|------|------|-----------------|
| Workflow Pipeline | `.claude/rules/workflow.md` | Skipped step (no issue, test-after-code, unaddressed PR comment, bundled drive-by fix) |
| Constitution Checker | `{{BACKEND_PATH}}/scripts/check-constitution.py` | Structure violations |
| Test Coverage | CI coverage report | Below tier minimums |
| Suite Health | `.claude/hooks/check-no-skipped-tests.sh` + CI | Any forbidden skip pattern or failing/erroring test |
| Agent/Rule Drift | `.claude/hooks/check-agent-drift.sh` + PreToolUse hook | Any stack version claim that contradicts `CLAUDE.md` |
| Type Check | pyright/mypy | New type errors |
| Lint | ruff | Lint errors |
| Security | bandit / dependency audit | High severity unresolved |
| Contracts | contract tests | Schema drift |
| Test Fidelity Agent *(planned)* | Expert validation agent (CI Stage 1) — activate after ≥20 calibration cycles | Agent-generated test code that omits edge cases or weakens assertions vs. the specification |
| Architectural Conformance Agent *(planned)* | Expert validation agent (CD Stage 1) — activate after ≥20 calibration cycles | Implementation violating feature description constraints |

## PR Acceptance Checklist

- [ ] Workflow: Issue exists and is referenced (`closes #N`); test was red before the fix; preflight clean; review comments resolved or replied to
- [ ] Article I: Library isolation (no business logic in routes)
- [ ] Article II: Services testable in isolation with DI
- [ ] Article III: Failing test first & coverage per tier
- [ ] Article III: Zero skipped, xfailed, or failing tests in the suite
- [ ] Article IV: Structured error mapping with DomainError
- [ ] Article V: Async & no blocking/global state
- [ ] Article VI: OpenAPI documented (Pydantic models)
- [ ] Article VII: Security (auth, secrets, encryption)
- [ ] Article VIII: CI green (lint, type, tests, security)
- [ ] Article IX: Spec references present
- [ ] ACD (agent-generated only): Intent description, BDD scenarios, feature description, and acceptance criteria exist and are human-approved
- [ ] ACD (agent-generated only): Commit tagged with agent identity and intent description reference (provenance)
- [ ] ACD (agent-generated only): Session scope constraint was active; no out-of-scope changes bundled

## Versioning Policy (CalVer)

Format: YYYY.MM.DD[-N]. Current version: {{CALVER_VERSION}}.
