---
paths:
  - "pyproject.toml"
  - "requirements.txt"
  - "package.json"
  - "package-lock.json"
  - ".github/dependabot.yml"
  - ".github/workflows/**"
---

# Dependency Security & Supply Chain Management

## MUST

### Automated Updates
- Dependabot or Renovate MUST be configured for both Python and Node.js dependencies
- Update PRs must pass the full CI pipeline (tests, type checks, lint) before merging
- Security updates (CVE patches) have a 48-hour SLA for review and merge

### Lockfile Hygiene
- `uv.lock` and `package-lock.json` MUST be committed to version control
- Lockfiles MUST NOT be silently mutated without review
- CI MUST verify lockfile consistency: `uv sync --locked` or `npm ci` must pass

### Vulnerability Scanning
- CI pipeline MUST run dependency vulnerability scans on every PR
- Python: `pip-audit` or `safety check`
- Node.js: `npm audit`
- Fail CI on any HIGH or CRITICAL severity CVE that has a patched version available
- Suppressed CVEs require: documented risk acceptance, expiration date, and security team sign-off

### SBOM
- Generate a Software Bill of Materials (SBOM) for every release
- Include direct and transitive dependencies with exact versions and license identifiers
- Store SBOM alongside release artifacts

## SHOULD

- Pin all production dependencies to exact versions or tight ranges (~major.minor)
- Separate dev dependencies from production dependencies (production Docker images exclude dev)
- Container image scanning (Trivy, Snyk, or Clair) for CVEs in OS packages
- Dependency review on PR: bot comment with added/removed packages and their risk scores
- Periodic manual audit of top-level dependencies (quarterly)

## ANTI-PATTERNS (BLOCKING)

- Merging dependency update PRs without reviewing the changelog or running tests
- Using `pip install` or `npm install` in production Dockerfiles (bypasses lockfile)
- Ignoring CVEs because "we don't use that feature" (defense in depth)
- Manual requirement file edits that bypass lockfile regeneration
- Using abandoned or unmaintained packages without a replacement plan

## Enforcement Checklist

- [ ] Dependabot/Renovate configured for Python and Node.js
- [ ] Lockfile committed and CI enforces `--locked` / `npm ci`
- [ ] Vulnerability scan in CI (HIGH/CRITICAL blocks merge)
- [ ] SBOM generated per release
- [ ] Security update SLA documented and tracked
- [ ] No suppressed CVEs without documented risk acceptance
