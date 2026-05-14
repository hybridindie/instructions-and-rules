## AGENTS.md - Copilot Agent Context for {{PROJECT_NAME}}

Purpose: This file gives GitHub Copilot agents a **concise** operating context. It intentionally omits rules that are in `CLAUDE.md` or `.claude/rules/` — those are the source of truth.

Scope: Copilot-facing guidance only. Do not duplicate content from `CLAUDE.md`.

## Where to Find Rules

- `.claude/rules/` — Constitutional guardrails (Articles I-IX)
- `.github/instructions/*.instructions.md` — File-scoped guidance
- `.github/copilot-instructions.md` — Repo-wide behavior
- `CLAUDE.md` — Tech stack, commands, workflow

## Copilot-Specific Context

### Agent Delegation

Copilot agents in this repo:
- `backend-architect` — for service design, API routes, repository patterns
- `frontend-architect` — for components, stores, typed services
- `article-compliance-reviewer` — PR checklist verification

### Prompts Available

- `/bootstrap-harness` — Auto-detect + render harness for new projects
- `/gen-contract-test` — Scaffold contract tests per Article III
- `/create-migration` — Supabase SQL migration scaffolding
- `/migration-check` — Validate a migration file against sql-standards before committing
- `/test-hygiene-scan` — Find hardcoded dates, AsyncMock misuse
- `/e2e-assertion-audit` — Flag no-op assertions
- `/pre-merge-verify` — Run all quality gates before merging a PR
- `/start-session` — Initialize an ACD implementation session (validate spec artifacts, set scope)
- `/end-session` — Close a session (validate gates, write context summary, commit)
- `/fix` — Restore pipeline health when red before resuming feature work

### Updating Guidance

When rules change, update in this order:
1. `.claude/rules/` (source of truth)
2. `.github/instructions/*.instructions.md` (mirrors)
3. `.github/copilot-instructions.md` (repo-wide)
4. `AGENTS.md` (this file) only if Copilot context needs adjustment

## Final Principle

Favor changes that reduce future refactor cost while improving reliability, clarity, and testability.
