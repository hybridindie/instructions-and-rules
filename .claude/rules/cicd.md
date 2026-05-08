---
paths:
  - ".github/workflows/**"
  - "pyproject.toml"
  - "requirements.txt"
  - "package.json"
  - "frontend/package.json"
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

## ANTI-PATTERNS

- Skipping local test run before push
- Flaky tests unresolved > 48h
- Silent mutation of lockfiles without review
