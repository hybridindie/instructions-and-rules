# Harness Evaluation

Post-bootstrap evaluation prompt. Run this after `bootstrap.sh` has rendered
the harness into a project. The agent reads the project's actual code and
dependencies, evaluates whether each rendered rule fits the project's stack,
trims what doesn't apply, and suggests rules the project needs but doesn't
have.

This is the semantic complement to bootstrap's deterministic rendering:
bootstrap does placeholder substitution and profile overlays; this does
stack-fit analysis and gap detection. Run it with `/harness-eval` or
reference this file with `@docs/harness-eval.md`.

---

## Your role

You are a harness engineer evaluating an already-installed AI harness against
the project it was installed into. The bootstrap render is deterministic — it
substitutes placeholders and applies profile overlays, but it cannot read the
project's actual code or understand semantics. You can. Your job is to close
the gap between what bootstrap rendered and what the project actually needs.

## What you have

- The project's codebase (read it — `package.json`, `pyproject.toml`, source
  files, config files, directory structure).
- The rendered harness files (`.claude/rules/`, `CLAUDE.md`, `.claude/agents/`,
  `.claude/commands/`, `.claude/skills/`, and the `.opencode/` + `.github/`
  equivalents).
- The project's `my-workflows.md` if present (user conventions).

## Phase 1 — Stack discovery

Read the project and determine the actual stack. Don't rely on what bootstrap
detected — verify against the code:

- **Backend framework**: FastAPI? Flask? MCP? Something else? Read the
  imports and entry points.
- **Frontend framework**: React+Vite? Next.js? None? Read `package.json`
  and the app directory structure.
- **Database**: Supabase? Raw PostgreSQL? Something else? Read
  `supabase/config.toml`, `docker-compose.yml`, or connection strings.
- **Package managers**: uv? pip? npm? bun? Read lockfiles.
- **Test framework**: pytest? vitest? Read test files and configs.
- **Special infra**: MLflow? LangGraph? pgvector? pgmq? Background workers?
  File uploads? Search functionality? Read deps and source.

Produce a one-paragraph stack summary. If the detected stack differs from what
the harness assumes (e.g. harness says FastAPI but the project is Flask),
flag it explicitly.

## Phase 2 — Stack-fit evaluation

For each rendered rule file in `.claude/rules/`, evaluate whether its
content matches the project's actual stack. Check:

- Does the article reference a framework the project doesn't use?
  (e.g. FastAPI-specific advice in a Flask project)
- Does the article reference infrastructure the project doesn't have?
  (e.g. supabase CLI commands in a raw-postgres project)
- Does the article reference a testing tool the project doesn't use?
  (e.g. pytest fixtures in a project that uses a different test runner)
- Is the article's `paths:` frontmatter relevant to the project's file
  structure?

Produce a stack-fit table:

```
| Article | Matches stack? | Issue | Action |
|---------|---------------|-------|--------|
| backend/api-design.md | No | References FastAPI/Pydantic; project is Flask | Replace with Flask variant or trim FastAPI sections |
| backend/architecture.md | Yes | Matches FastAPI project | Keep |
| database/sql-standards.md | No | References supabase migrations; project uses raw psql | Trim supabase-specific sections |
| frontend/conventions.md | N/A | Project is backend-only | Remove |
```

## Phase 3 — Trim

For each article that doesn't match the stack, propose one of:

- **Remove** — the article doesn't apply at all (e.g. frontend rules in a
  backend-only project). Delete the file and remove its reference from
  `CLAUDE.md`.
- **Trim** — the article is partially relevant but contains wrong sections.
  Remove the wrong sections, keep the rest. (e.g. remove supabase-specific
  migration commands from sql-standards.md, keep the general SQL rules.)
- **Replace** — a profile overlay exists but wasn't applied. Apply it
  manually (copy the overlay content over the rendered file). (e.g. if
  bootstrap didn't apply the Flask overlay, do it now.)
- **Keep** — the article matches. No change.

Present the trim plan grouped by action. Ask the user to confirm before
deleting or editing any file.

## Phase 4 — Suggest missing rules

Based on what the project actually uses (detected from code and deps),
suggest rules the project needs but the harness doesn't have:

- **Background jobs**: does the project have queue consumers, workers, or
  scheduled tasks? If so, are there rules for retry, dead-letter, idempotency?
- **Search**: does the project use pgvector, full-text search, or a search
  API? If so, are there rules for index design, query patterns, relevance?
- **File uploads**: does the project handle file uploads or S3 storage? If
  so, are there rules for signed URLs, size limits, malware scanning?
- **Multi-tenancy**: does the project have tenant isolation, RLS, or
  per-tenant schemas? If so, are there rules for tenant routing, data
  isolation?
- **Real-time**: does the project use WebSocket, SSE, or LISTEN/NOTIFY?
  If so, are there rules for connection management, reconnection?
- **API versioning**: does the project have multiple API versions or
  deprecation headers? If so, are there rules for backward compatibility?
- **Feature flags**: does the project use feature flags? If so, are there
  rules for naming, rollout, cleanup, tech debt?
- **Caching**: does the project cache data? If so, are there rules for the
  caching strategy (NOLOG tables, materialized views, HTTP cache headers)?

For each gap, suggest:
- A one-line description of the missing rule
- Which existing article it should live in (if any) or whether it needs a
  new article
- A stub of what the rule should say (2-3 bullet points)

Don't create the files yet — just list the suggestions. The user picks which
ones to implement.

## Phase 5 — Report

Produce the final report:

```
## Harness Evaluation Report

### Stack detected
<one paragraph>

### Stack-fit issues
<table from Phase 2>

### Trim actions
<list of remove/trim/replace/keep from Phase 3>

### Missing rules
<list of suggestions from Phase 4>

### Recommended next steps
1. Apply trim actions (confirm)
2. Implement missing rules (pick which ones)
3. Run /customize-harness to tailor domain examples and workflows
```

## Rules

- **Read the actual code** — don't rely on bootstrap's detection. Open
  files, read imports, check configs. The whole point is that the agent can
  do what bootstrap can't.
- **Propose, don't execute** — present the plan in Phases 2-4, confirm with
  the user, then apply in Phase 3. Never delete or edit files without
  confirmation.
- **Be specific** — don't say "this article doesn't fit." Say "this article
  references `Depends()` and `async def` handlers, but the project uses Flask
  with sync handlers and `current_app` injection."
- **Suggest, don't fabricate** — for missing rules, suggest what should
  exist. Don't invent rules that sound plausible but have no basis in the
  project's actual needs.
- **Respect the golden rule** — if editing rule content, edit the
  `.claude/rules/` files (the rendered copies in the target project). Don't
  touch `templates/` or the genesis repo.

## When to run this

- After `bootstrap.sh` renders the harness into a new project.
- After a major stack change (e.g. migrating from Vite to Next.js, adding
  Flask alongside FastAPI, switching from supabase to raw postgres).
- Before `/customize-harness` — trimming and gap-filling should happen
  before domain tailoring.
- Anytime the user asks "evaluate the harness" or "does this harness fit
  my project?"