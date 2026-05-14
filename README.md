# AI Harness Templates

**Constitutional AI instruction templates for Python (FastAPI, MCP, Django, Flask) and optional TypeScript/React projects.**

Generate equivalent instruction harnesses for GitHub Copilot, Claude Code, and Opencode with a single command. These templates codify Articles I–IX (library-first architecture, TDD mandate, structured errors, async-first, API contracts, security, CI integrity, enforcement) along with PostgreSQL schema standards, frontend conventions, and a complete workflow pipeline.

## Install with AI (recommended)

Clone this repo once. Then use the `install-harness` agent from any project:

**Claude Code:**
```
# Open this genesis repo in Claude Code, then:
@install-harness /absolute/path/to/your-project
```

**GitHub Copilot:**
```
# Open this genesis repo in VS Code, then use the install-harness agent:
@install-harness /absolute/path/to/your-project
```

The agent will:
1. Inspect the target project (stack, language, versions, dependencies)
2. Show an **install plan** — what will be included and what will be omitted (e.g. no frontend rules if there is no frontend)
3. Ask for confirmation before running
4. Run bootstrap and report what was created

## Quick Start (CLI)

```bash
# 1. Auto-detect (recommended) — probes project, infers mode/profile, asks only unknowns
cd your-project
bash /path/to/genesis/templates/scripts/bootstrap.sh --auto-detect --output-dir .

# 2. Manual CLI (supply all values)
bash /path/to/genesis/templates/scripts/bootstrap.sh \
  --project-name "YourProject" \
  --project-slug "yourproject" \
  --mode "full" \
  --profile "fastapi" \
  --has-mlflow "no" \
  --has-langgraph "no" \
  --output-dir "."
```

Both approaches produce:
- `.claude/rules/` — Constitutional Articles I–IX (source of truth)
- `.github/instructions/` — Auto-mirrored Copilot instructions
- `.github/copilot-instructions.md` — Repo-wide Copilot guidance
- `CLAUDE.md` + `AGENTS.md` — Master context files
- `.opencode/` — Equivalent skills, commands, agents, plugins

## Architecture

### Shared Source of Truth

The `_shared/` directory contains the constitutional rules that are rendered into **all three harnesses**:

| File | Article | Topic |
|------|---------|-------|
| `articles/architecture.md` | I & II | Library-first, service isolation |
| `articles/testing.md` | III | TDD mandate, tiered coverage |
| `articles/error-handling.md` | IV | Structured errors, DomainError envelope |
| `articles/async-patterns.md` | V | Async-first, concurrency, atomicity |
| `articles/api-design.md` | VI | OpenAPI, Pydantic models, route delegation |
| `articles/security.md` | VII | OAuth2/JWT, AES-256, secret hygiene |
| `articles/cicd.md` | VIII | CI gates, deterministic builds |
| `articles/enforcement.md` | IX | PR checklist, enforcement gates, versioning |
| `articles/workflow.md` | — | Step-by-step workflow pipeline (#1–7) |
| `database/sql-standards.md` | — | PostgreSQL schema conventions |
| `database/infrastructure.md` | — | PostgreSQL-only infrastructure |
| `frontend/conventions.md` | — | React/TypeScript/Vite conventions |

### Mirror System

`.claude/rules/*.md` (Claude) and `.github/instructions/*.instructions.md` (Copilot) are **body-identical mirrors**. They share the same content but have different frontmatter:

- **Claude**: `paths:` globs (file-scoped rules)
- **Copilot**: `description:` + `applyTo:` (scope + context hints)

The `generate-copilot-mirrors.py` script creates Copilot mirrors automatically from Claude rules. Drift between mirrors is detected by `check-primitive-drift.sh`.

```text
Claude rules              Copilot instructions
├── backend/
│   ├── architecture.md →   backend-architecture.instructions.md
│   ├── testing.md      →   backend-testing.instructions.md
│   └── ...
├── database/
│   ├── sql-standards.md→   database-sql-standards.instructions.md
│   └── ...
├── frontend/
│   └── conventions.md  →   frontend-conventions.instructions.md
└── enforcement.md      →   enforcement.instructions.md
```

### Three Equivalent Harnesses

Each platform receives the **same rules** but in its own format:

| Platform | Entry Files | Ecosystem |
|----------|-------------|-----------|
| **Claude Code** | `CLAUDE.md`, `AGENTS.md` | `.claude/rules/`, `.claude/commands/`, `.claude/agents/`, `.claude/skills/`, `.claude/hooks/`, `.claude/scripts/` |
| **GitHub Copilot** | `.github/copilot-instructions.md` | `.github/instructions/`, `.github/rules/`, `.github/agents/`, `.github/prompts/` |
| **Opencode** | `CLAUDE.md`, `AGENTS.md` | `.opencode/skills/`, `.opencode/commands/`, `.opencode/agents/`, `.opencode/plugins/` |

## Placeholder Schema

Templates use `{{PLACEHOLDER}}` syntax with `{{#FLAG}}...{{/FLAG}}` conditional blocks:

| Placeholder | Default | Description |
|-------------|---------|-------------|
| `{{PROJECT_NAME}}` | — | Human-readable project name |
| `{{PROJECT_SLUG}}` | — | URL-safe slug |
| `{{BACKEND_PATH}}` | `backend` | Backend directory name |
| `{{FRONTEND_PATH}}` | `frontend` | Frontend directory name |
| `{{PYTHON_VERSION}}` | `3.12` | Python minor version |
| `{{FASTAPI_VERSION}}` | `0.119+` | FastAPI version |
| `{{REACT_VERSION}}` | `19` | React major version |
| `{{STATE_MANAGER}}` | `zustand` | Frontend state manager |
| `{{DB_PROVIDER}}` | `supabase` | Database provider |
| `{{HAS_MLFLOW}}` | `no` | Include MLflow Prompt Registry rules |
| `{{HAS_LANGGRAPH}}` | `no` | Include LangGraph agent rules |
| `{{COVERAGE_AGGREGATE_BACKEND}}` | `70` | Aggregate backend coverage target |
| `{{CALVER_VERSION}}` | today's date | Initial CalVer version |

When a flag is `no`, `process-conditionals.py` strips the entire `{{#FLAG}}...{{/FLAG}}` block.

## Built-in Skills

| Skill | Platforms | Purpose |
|-------|-----------|---------|
| `bootstrap-harness` | Claude, Opencode | Interactive project scanner + renderer |
| `gen-contract-test` | Claude, Opencode | Scaffold contract tests (TDD Article III) |
| `create-migration` | Claude, Opencode | Validate/supabase-migration scaffolding |
| `test-hygiene-scanner` | Claude, Opencode | Find hardcoded dates, AsyncMock misuse, cross-tier truncates |
| `e2e-assertion-audit` | Claude, Opencode | Flag no-op assertions in E2E tests |

## Workflow Pipeline

Every project using these templates follows the 7-step pipeline:

```
1. Issue exists      →  GitHub issue tracking the work
2. Failing test      →  Red test before implementation (TDD Article III)
3. Green code        →  Minimal fix that makes test pass
4. Preflight clean   →  lint / type / test all green
5. PR opened         →  Reference issue, include checklist
6. Comments addressed →  Every review comment resolved or replied
7. Merge             →  Only after green preflight + resolved comments
```

Each step gates the next. No step may be skipped without explanation.

## Pre-commit Hooks

| Hook | Command | Blocks? |
|------|---------|---------|
| `check-no-skipped-tests.sh` | `bash .claude/hooks/check-no-skipped-tests.sh` | Yes — exits non-zero on skip/xfail |
| `check-primitive-drift.sh` | `bash .claude/hooks/check-primitive-drift.sh` | Yes — exits non-zero on mirror mismatch |
| `check-agent-drift.sh` | `bash .claude/hooks/check-agent-drift.sh` | Yes — exits non-zero on version contradictions |

## Tech Stack Assumptions

These templates support multiple stack profiles. Auto-detection selects the correct one:

| Profile | Backend | Frontend | Database | Detected By |
|---------|---------|----------|----------|-------------|
| `fastapi+react` (default) | FastAPI, Pydantic | React 19, TypeScript, Vite | PostgreSQL / Supabase | `pyproject.toml` + `package.json` |
| `fastapi` | FastAPI, Pydantic | None | PostgreSQL / Supabase | `pyproject.toml` only |
| `mcp` | MCP server, Pydantic | None | None (stateless) | `mcp` in `pyproject.toml` deps |
| `django` | Django | Optional | PostgreSQL | `django` in deps |
| `flask` | Flask | Optional | PostgreSQL | `flask` in deps |

Default stack (when auto-detect yields no clear signal):
- **Backend**: Python 3.12, FastAPI, Pydantic, async/await, `uv`
- **Frontend**: React 19, TypeScript, Vite, Vitest, shadcn/ui, Tailwind CSS
- **Database**: PostgreSQL (Supabase-first), no SQLAlchemy
- **State**: Zustand (≤ 300 lines per store), typed service modules
- **Tests**: pytest (backend) + vitest (frontend), contract → integration → e2e → unit

## DRY Principle

This system eliminates duplication by design:

- **Single source of truth**: `_shared/articles/*.md` are rendered into all three harnesses
- **Auto-generated mirrors**: Copilot instructions are never hand-edited; they are generated from Claude rules
- **Conditional blocks**: `{{#HAS_MLFLOW}}...{{/HAS_MLFLOW}}` appears once per rule and is stripped when not applicable
- **Snippet includes**: Shared fragments (error envelopes, PR checklists) are defined once and referenced

## Customization

### Semantic Tailoring

For projects with special infrastructure (MLflow, LangGraph, payments, HIPAA), use the AI customization prompt:

```bash
# Use templates/scripts/customize-harness.md as a skill prompt
customize-harness \
  --project "MyProject: AI-powered analytics" \
  --special-infra "mlflow, langgraph" \
  --tier-adjustments "security:90, business:80, ml:60"
```

This removes irrelevant sections, adjusts coverage tiers, and suggests domain-specific agents.

### Post-Customization Drift Checks

After rendering into a project:

```bash
bash .claude/hooks/check-primitive-drift.sh   # mirror sync
bash .claude/hooks/check-agent-drift.sh        # version consistency
bash .claude/hooks/check-no-skipped-tests.sh   # hook syntax
```

## Updating Templates

When a rule changes across all projects:

1. Edit `_shared/articles/*.md` (the source of truth)
2. Re-render into all projects with `bootstrap.sh`
3. Run `check-primitive-drift.sh` to verify mirrors

## Related Work

This approach synthesizes production patterns distilled over many iterations. The result is a battle-tested, self-validating instruction system that adapts to diverse stacks while remaining maintainable.

## Versioning

Templates follow CalVer: `YYYY.MM.DD[-N]`.

Current: tracked by `templates/_shared/articles/enforcement.md`.
