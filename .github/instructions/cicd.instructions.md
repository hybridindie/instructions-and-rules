---
description: "Use when editing CI workflows, dependency manifests, pipeline gates, and automation integrity settings."
applyTo: ".github/workflows/**, pyproject.toml, requirements.txt, package.json, frontend/package.json"
---

# CI/CD & Automation Integrity (Article VIII)

## MUST

1. **Gate integrity** — Enforce CI gates in this order: lint → type check → tests → coverage → security scan → dependency audit. All gates must pass before merge.
2. **Coverage** — Fail pipeline on coverage regression; post a coverage diff per PR (line + branch for changed files).
3. **Security** — Fail pipeline on any CVE with a CVSS score of 7.0 or higher.
4. **Reproducibility** — Deterministic build artifacts: pin dependencies and commit lockfiles.

## SHOULD

- Parallelize independent test categories (contract, integration, e2e)
- Cache dependencies and virtualenv between runs
- Machine-readable test reports (JUnit/coverage XML)

## ANTI-PATTERNS

- Skipping local test run before push
- Flaky tests unresolved > 48h
- Silent mutation of lockfiles without review
