# Claude Code Context - {{PROJECT_NAME}}

## Project Overview

{{PROJECT_NAME}} — SaaS platform. PostgreSQL-only infrastructure.

## Test Suite Invariants (BLOCKING)

The test suite is a binary signal. Either it is fully green and trusted, or it is a liar. The full rules live in `.claude/rules/backend/testing.md` and `.claude/rules/frontend/conventions.md` — the short version:

- **Zero failing tests may be checked in.** `{{TEST_BACKEND_CMD}}` (backend) AND `{{TEST_FRONTEND_CMD}}` (frontend) MUST exit zero on a clean checkout.
- **Zero unconditional skips may be checked in.** `@pytest.mark.skip`, `@pytest.mark.xfail`, `it.skip`, `test.skip`, `describe.skip`, `.todo`, `xit`, `xdescribe` are forbidden. `@pytest.mark.skipif(<bool>, reason=...)` gated on a real environmental precondition is the only permitted form.
- **Test drift is a bug.** When you change a route, component, store, schema, service, or API contract, update the co-owning tests in the same commit.
- **Determinism is mandatory.** Inject `Clock`, `RandomProvider`, `respx`, `vi.useFakeTimers()`, or MSW. Never depend on wall-clock `Date.now()` comparisons with hardcoded ISO strings.
- **Before claiming work is done**, run `bash .claude/hooks/check-no-skipped-tests.sh` AND the relevant test suite.
- **Never use `--no-verify`, `--no-gpg-sign`, or any other hook-bypass flag.** Fix the failing hook instead.

## Authoritative References

These documents are the source of truth. Do NOT duplicate their content here:

- `/.claude/rules/` - Development guardrails (Articles I-IX), coverage tiers, error mapping, acceptance checklist, glossary, versioning policy
- `/{{BACKEND_PATH}}/docs/DATABASE_ARCHITECTURE.md` - {{DB_PROVIDER}}-first database access patterns, repositories, migrations
- `/{{BACKEND_PATH}}/docs/STRUCTURE.md` - Backend directory organization
- `/docs/architecture/{{PROJECT_SLUG}}_prd.md` - Product requirements
- `/docs/deploy/` - Deployment docs, env vars, migrations, rollback, incident response
- `/docs/plans/` - Design docs and implementation plans

## Tech Stack

### Backend

- Python {{PYTHON_VERSION}}, FastAPI {{FASTAPI_VERSION}}
- PostgreSQL 17 ({{DB_EXTENSIONS}})
- {{DB_PROVIDER}} client for all DB operations (no SQLAlchemy)
- Docker Compose containerization
{{#HAS_MLFLOW}}- MLflow (LLM observability, prompt versioning via Prompt Registry){{/HAS_MLFLOW}}
{{#HAS_LANGGRAPH}}- LangGraph 1.0 (agent orchestration){{/HAS_LANGGRAPH}}
- Testing: pytest, httpx, Pydantic

### Frontend

- React {{REACT_VERSION}}, TypeScript {{TYPESCRIPT_VERSION}}, Vite {{VITE_VERSION}}
- {{STATE_MANAGER}} stores ({{FRONTEND_STORE_EXAMPLES}})
- Vitest + MSW + React Testing Library
- {{E2E_TOOL}} E2E, {{UI_LIBRARY}} components

### Local Development

- {{DB_PROVIDER}} CLI for local PostgreSQL instance (`supabase/config.toml`)
  - API: port 54321, DB: port 54322, Studio: port 54323
  - Migrations in `supabase/migrations/`, seeds in `supabase/seed.sql`
- `supabase start` / `supabase stop` to manage local instance
- `supabase db push` to apply migrations to remote

## GitHub Project Context

At the start of any session, check current work context with GitHub MCP tools:

- List open epic issues
- List open critical (P0) and high (P1) issues
- List open pull requests
- List recently merged pull requests

Use GitHub MCP tools (not `gh` CLI) for issues, PRs, and project management.

### Label System

- **Priority**: `priority:critical` (P0), `priority:high` (P1), `priority:medium` (P2), `priority:low` (P3)
- **Type**: `type:epic`, `type:story`, `type:task`, `type:bug`, `type:spike`

### Conventions

- Issues reference their parent epic
- PRs reference the issue they close (e.g., "Closes #321")
- P0 issues in title format: `[P0] Description`
- Branch naming: `feature/<issue>-<description>`

## Development Workflow

Follow TDD per Article III (`.claude/rules/backend/testing.md`):

1. Write failing test first (contract tests before implementation)
2. Implement minimal code to pass
3. Refactor if needed
4. Run constitution checker before PRs

Test authoring order: Contract -> Integration -> E2E -> Unit

## Key Commands

```bash
# Constitution compliance
cd {{BACKEND_PATH}} && {{PKG_MANAGER_BACKEND}} run python scripts/check-constitution.py

# Backend tests
cd {{BACKEND_PATH}} && {{TEST_BACKEND_CMD}} tests/contract tests/unit -n auto --no-cov
cd {{BACKEND_PATH}} && {{TEST_BACKEND_CMD}} tests/integration -n auto --dist=loadgroup --no-cov
cd {{BACKEND_PATH}} && {{TEST_BACKEND_CMD}} tests/e2e -p no:xdist --no-cov

# Frontend tests
cd {{FRONTEND_PATH}} && {{TEST_FRONTEND_CMD}}

# Database
supabase start
supabase db push
```

{{CUSTOM_TECH_STACK}}

## Available MCP Servers

### Context7 — Library Documentation

Fetches up-to-date docs and code examples for any library. Use `resolve-library-id` first, then `query-docs`. Useful for FastAPI, {{DB_PROVIDER}}, React, {{STATE_MANAGER}}, {{E2E_TOOL}}, Pydantic, and any other dependency.

### {{UI_LIBRARY}} — Component Registry

Connected to component registry. Search components, view examples, get install commands. Always check the registry before building UI components from scratch.

### {{E2E_TOOL}} — Browser Automation

Full browser control for E2E testing, debugging OAuth flows, and visual verification.

## Knowledge Graphs

Architecture knowledge graphs built with graphify. Read the relevant report **before** making structural recommendations, planning new libraries, or tracing data flows in that area.

| Graph | Report | When to read |
|-------|--------|--------------|
| Backend app | `{{BACKEND_PATH}}/src/graphify-out/GRAPH_REPORT.md` | Adding/changing a lib, tracing service dependencies, DI wiring |
| Frontend app | `{{FRONTEND_PATH}}/src/graphify-out/GRAPH_REPORT.md` | Store topology, component ownership, service wiring |

### Building the graphs

```bash
/graphify {{BACKEND_PATH}}/src             # full extract
/graphify {{BACKEND_PATH}}/src --update    # incremental
/graphify {{FRONTEND_PATH}}/src --update   # incremental
```

## Project

{{CUSTOM_INSTRUCTIONS}}

### Constraints

- **Architecture**: Must follow constitutional articles I-IX (library-first, DI, TDD, DomainError, async, Pydantic, security, CI)
- **Database**: {{DB_PROVIDER}}-only (no SQLAlchemy), TEXT+CHECK over ENUMs, FK indexes, migrations via {{DB_PROVIDER}} CLI
{{#HAS_MLFLOW}}- **AI Prompts**: All prompts through MLflow Prompt Registry (no hardcoded inline prompts){{/HAS_MLFLOW}}
- **Testing**: TDD per Article III, tiered coverage, zero skips, zero failures
- **Frontend**: {{STATE_MANAGER}} stores (300 line max), {{UI_LIBRARY}} components, typed service modules

## Skills

Invoke with `/skill-name`. All skills live in `.claude/skills/`.

| Skill | When |
|-------|------|
| `brainstorming` | Before any new feature — structured design before code |
| `writing-plans` | After design approval — bite-sized TDD implementation plan |
| `subagent-driven-development` | Execute plans with parallel subagents + 2-stage review |
| `finishing-a-development-branch` | PR creation, merge, cleanup |
| `test-driven-development` | Any feature/bugfix — red-green-refactor |
| `systematic-debugging` | Any bug or test failure |
| `requesting-code-review` | After implementation, before merge |
| `verification-before-completion` | Evidence-based completion claims |
| `frontend-design` | UI components and pages |
| `dispatching-parallel-agents` | 2+ independent tasks |
| `create-migration` | Scaffold a {{DB_PROVIDER}} SQL migration (sql-standards.md compliant) |
| `e2e-assertion-audit` | Scan E2E tests for no-op assertions and overly permissive checks |
| `gen-contract-test` | Generate a contract test skeleton (TDD Article III) |
| `test-hygiene-scanner` | Triage hardcoded dates and AsyncMock misuse in the test suite |
| `clock-injection-audit` | Scan all service files for bare `datetime.now()` without Clock injection |
| `graph-query` | Query the graphify knowledge graphs |

## Architecture Milestones

These are permanent architectural decisions — not a changelog. Check merged PRs for recent work.

{{CUSTOM_TECH_STACK}}
