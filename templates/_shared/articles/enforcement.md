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

Applies `.claude/rules/doctrine/ci-enforcement-rules.md` for the gates
table. The gates include: Workflow Pipeline, Constitution Checker, Test
Coverage, Suite Health, Agent/Rule Drift, Type Check, Lint, Security,
Contracts, and the planned Test Fidelity and Architectural Conformance
validation agents.

## PR Acceptance Checklist

- [ ] Workflow: Issue exists and is referenced (`closes #N`); test was red before the fix; preflight clean; review comments resolved or replied to
- [ ] Article I: Library isolation (no business logic in routes)
- [ ] Article II: Services testable in isolation with DI
- [ ] Article III: Failing test first & coverage per tier — applies `.claude/rules/doctrine/test-discipline-rules.md` (zero skips/xfail/failures; coverage minimums)
- [ ] Article IV: Structured error mapping with DomainError
- [ ] Article V: Async & no blocking/global state
- [ ] Article VI: OpenAPI documented (Pydantic models)
- [ ] Article VII: Security (auth, secrets, encryption)
- [ ] Article VIII: CI green (lint, type, tests, security) — applies `.claude/rules/doctrine/ci-enforcement-rules.md`
- [ ] Article IX: Spec references present
- [ ] ACD (agent-generated only): the four spec artifacts (intent, BDD scenarios, feature description, acceptance criteria) exist and are human-approved — applies `.claude/rules/doctrine/acd-spec-rules.md`
- [ ] ACD (agent-generated only): Commit tagged with agent identity and intent description reference (provenance)
- [ ] ACD (agent-generated only): Session scope constraint was active; no out-of-scope changes bundled

## Versioning Policy (CalVer)

Format: YYYY.MM.DD[-N]. Current version: {{CALVER_VERSION}}.
