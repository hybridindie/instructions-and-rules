# AGENTS.md - Copilot Agent Context for {{PROJECT_NAME}}

Purpose: This file gives GitHub Copilot agents a concise operating context for this repository.

Scope: Copilot-facing guidance only. The constitutional source of truth remains in .claude/rules and .github/instructions.

## Project Overview

{{PROJECT_NAME}} is a SaaS platform.

Core infrastructure direction: PostgreSQL-only backend architecture.

## Authoritative References

Do not duplicate rule content in this file. Use these as the source of truth:

- `.claude/rules/` - Constitutional guardrails (Articles I-IX), coverage tiers, enforcement gates, glossary, versioning policy
- `.github/instructions/*.instructions.md` - Copilot file-scoped and domain guidance
- `.github/copilot-instructions.md` - Repo-wide Copilot behavior and architecture guidance
- `{{BACKEND_PATH}}/docs/DATABASE_ARCHITECTURE.md` - {{DB_PROVIDER}}-first data access and repository patterns
- `{{BACKEND_PATH}}/docs/STRUCTURE.md` - Backend directory organization
- `docs/architecture/{{PROJECT_SLUG}}_prd.md` - Product requirements
- `docs/deploy/` - Deployment, environment, rollback, and incident response docs
- `docs/plans/` - Design and implementation plans

## Tech Stack

### Backend

- Python {{PYTHON_VERSION}}
- FastAPI {{FASTAPI_VERSION}}
- PostgreSQL 17 ({{DB_EXTENSIONS}})
- {{DB_PROVIDER}} client for DB access (no SQLAlchemy)
{{#HAS_MLFLOW}}- MLflow for LLM observability and prompt registry{{/HAS_MLFLOW}}
- Pytest, HTTPX, Pydantic

### Frontend

- React {{REACT_VERSION}}
- TypeScript {{TYPESCRIPT_VERSION}}
- Vite {{VITE_VERSION}}
- {{STATE_MANAGER}} state management
- Vitest + MSW + React Testing Library
- {{E2E_TOOL}} E2E
- {{UI_LIBRARY}}

### Local Data Environment

{{DB_PROVIDER}} local stack in supabase/config.toml:

- API: 54321
- DB: 54322
- Studio: 54323
- Inbucket: 54324

## Architectural Guardrails

- Business logic belongs in {{BACKEND_PATH}}/src/libs/<service_name>, not in FastAPI route handlers.
- {{BACKEND_PATH}}/app is a thin API boundary: request parsing, dependency wiring, error mapping, and delegation.
- Library code under {{BACKEND_PATH}}/src/libs must not import from app.*.
- Async-first for backend I/O with explicit timeouts and dependency injection.
- Domain failures should use structured DomainError patterns with stable codes.
- Use explicit response models and endpoint documentation at API boundaries.
- Security defaults apply: OAuth2/JWT validation, secret hygiene, and redacted logs.

{{#HAS_MLFLOW}}
## Prompt and AI Runtime Notes

- MLflow Prompt Registry is the runtime source of truth for prompts.
- Prompt updates must be published to MLflow Prompt Registry before rollout.
- Python constants are seed values and degraded-state fallback only (not normal operation).
- Prompt reads should go through the prompt loader service.
{{/HAS_MLFLOW}}

## Development Workflow

Use TDD order from constitutional guidance:

1. Contract tests
2. Integration tests
3. E2E tests
4. Unit tests

Default cycle:

1. Write a failing test
2. Implement minimal change
3. Refactor
4. Re-run checks

## Key Commands

- python scripts/check-constitution.py
- {{TEST_BACKEND_CMD}} --cov={{BACKEND_PATH}}/src/libs --cov-report=term-missing
- cd {{FRONTEND_PATH}} && {{TEST_FRONTEND_CMD}}
- supabase start
- supabase db push

## GitHub Project Context

At session start, review current work context:

- Use GitHub MCP server tools for all GitHub interactions.
- Do not use `gh` CLI for issues, pull requests, branches, commits, labels, or reviews.
- Retrieve equivalent context through MCP issue/PR listing and search tools.

Conventions:

- Issues reference parent epic
- PRs reference closing issue
- Critical issue title prefix: [P0]
- Branch naming: feature/issue-description

## Quality Gates Before PR

- Constitution checker passes
- Lint/type/test/security checks pass
- Coverage meets tier thresholds
- No structural drift against documented rules

## Updating Guidance

When guidance changes, update in this order:

1. `.claude/rules/`
2. matching `.github/instructions/*.instructions.md`
3. `.github/copilot-instructions.md`
4. `AGENTS.md` (this file) if shared Copilot agent context needs adjustment

## Final Principle

Favor changes that reduce future refactor cost while improving reliability, clarity, and testability.
