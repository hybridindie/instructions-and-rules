---
paths:
  - "README.md"
  - "docs/**/*.md"
  - "{{BACKEND_PATH}}/docs/**/*.md"
  - "docs/adr/**/*.md"
---

# Documentation Standards

## MUST

### README Requirements
Every repository MUST have a root `README.md` containing:

1. **Project overview** (one sentence): what it does and for whom
2. **Quick start**: copy-paste commands to get running locally (≤5 steps)
3. **Tech stack**: concise table of backend, frontend, database, runtime
4. **Architecture**: one diagram or description of the main data flow
5. **Key commands**: test, lint, type-check, start dev, deploy commands
6. **Environment variables**: required env vars with descriptions (no values)
7. **Link to detailed docs**: `docs/architecture/`, `docs/deploy/`, `docs/adr/`
8. **License**: one-line SPDX identifier

### API Documentation
- Every FastAPI endpoint MUST have OpenAPI auto-documentation enabled
- Public endpoints MUST have `summary`, `description`, and `response_model`
- Complex request/response models MUST include JSON schema examples (`model_config = {"json_schema_extra": {"examples": [...]}}`)
- API changelog for public-facing changes: document breaking vs non-breaking changes

### Architecture Decision Records (ADR)
- Every significant architectural decision MUST have an ADR in `docs/adr/`
- ADR format: Numbered, `YYYY-MM-DD-title.md`, following the template below
- ADR status: `Proposed`, `Accepted`, `Deprecated`, `Superseded`
- Minimum sections: Context, Decision, Consequences, Alternatives Considered, Status

```markdown
# ADR-001: Supabase-first Database Access

## Status
Accepted (2026-03-15)

## Context
We needed a unified database access layer...

## Decision
Use Supabase client for all DB operations...

## Consequences
- Positive: Single abstraction, real-time subscriptions
- Negative: Vendor lock-in

## Alternatives Considered
- SQLAlchemy: rejected due to ORM complexity
- Raw psycopg: rejected due to connection management burden

## Related
- Supersedes: ADR-000 (Local SQLite)
```

### Code Documentation
- Public functions (exported from modules): Google-style docstrings (`Args:`, `Returns:`, `Raises:`)
- Complex algorithms or business rules: inline comment explaining WHY, not WHAT
- Non-obvious type signatures: comment explaining design rationale
- Constants and configuration: comment explaining business meaning (not just restating the variable name)

## SHOULD

- Runbook templates: onboarding, incident response, database recovery, rollback
- Auto-generated API docs published (Redoc, Swagger UI, or ReadMe)
- Architecture diagrams kept in `docs/architecture/` and updated when code changes
- Changelog (`CHANGELOG.md`) following Keep a Changelog format
- CONTRIBUTING.md for open-source or team standards

## ANTI-PATTERNS (BLOCKING)

- README that only says "This is the backend repository" with no further detail
- API documentation that is auto-generated but inaccurate (models out of sync with code)
- ADRs that describe the decision but omit the context or alternatives
- Comments that restate the obvious: `# Increment counter by 1` on `counter += 1`
- Documentation in a separate system (Confluence, Notion) without links from the repo
- "TODO" or "FIXME" comments that are never addressed (if it exists in main, it needs an issue)

## Enforcement Checklist

- [ ] Root README.md has all 8 required sections
- [ ] Every public API endpoint has OpenAPI docs with examples
- [ ] ADR directory exists with at least one ADR per major architectural decision
- [ ] Code comments explain WHY for non-obvious logic
- [ ] No orphan TODO/FIXME comments without linked issues
