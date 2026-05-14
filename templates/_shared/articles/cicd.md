---
paths:
  - ".github/workflows/**"
  - "pyproject.toml"
  - "requirements.txt"
  - "package.json"
  - "{{FRONTEND_PATH}}/package.json"
---

# CI/CD & Automation Integrity (Article VIII)

## MUST

- Enforce CI gates: lint, type check, tests, coverage, security scan, dependency audit
- Fail pipeline on coverage regression or high severity CVE
- Deterministic build artifacts (pin dependencies / lockfiles committed)
- Coverage diff per PR (line + branch for changed files)

## SHOULD

- Parallelize independent test categories (contract, integration, e2e)
- Cache dependencies and virtualenv between runs
- Machine-readable test reports (JUnit/coverage XML)

## ACD Pipeline Stage Mapping

For agent-generated changes, each pipeline stage enforces a specific ACD constraint:

| Stage | Gate | ACD Constraint Enforced |
|-------|------|-------------------------|
| Pre-commit | Lint, type check, secret scan, SAST | Mechanical errors: style violations, type mismatches, embedded secrets |
| CI Stage 1 | Build + unit tests | Acceptance criteria — if human-defined tests fail, the implementation is wrong regardless of how plausible the code looks |
| CD Stage 1 | Contract + schema tests | System constraints — agent-generated code is especially prone to breaking implicit contracts between modules or services |
| CD Stage 2 | Mutation testing, performance benchmarks, security integration tests | Subtle correctness issues: code that passes tests but violates non-functional requirements or leaves untested edge cases |
| Acceptance | BDD scenario tests in production-like environment | User-facing behavior — where BDD scenarios become automated verification |
| Production | Canary deployment, health checks, SLO monitors with auto-rollback | Final safety net — if agent-generated code degrades production metrics, it rolls back automatically |

**Constraint 8:** While the pipeline is red, agents may only generate changes restoring pipeline health. No feature work until green is restored.

## Expert Validation Agents as Pipeline Gates *(planned — activate after ≥20 calibration cycles)*

Standard tooling covers mechanical checks. Expert validation agents handle what static analysis cannot. These are aspirational gates — run each in parallel with human review for ≥20 cycles and confirm ≥90% agreement before replacing human review.

| Agent | Pipeline Stage | Purpose |
|-------|---------------|---------|
| Test fidelity | CI Stage 1 | Verify test code faithfully implements the human-defined specification; catch omitted edge cases |
| Implementation coupling | CI Stage 1 | Verify tests check observable behavior, not internal details |
| Architectural conformance | CD Stage 1 | Verify implementation follows feature description constraints |
| Intent alignment | CD Stage 2 | Verify the change addresses the problem stated in the intent description |
| Constraint compliance | CD Stage 2 | Verify compliance with system constraints static analysis cannot check |

## ANTI-PATTERNS

- Skipping local test run before push
- Flaky tests unresolved > 48h
- Silent mutation of lockfiles without review
- Deploying expert validation agents and immediately removing human review (calibrate first)
- Feature work while the pipeline is red (constraint 8: restore-only work until green)
