# Customization System

This repository uses a layered customization system for Copilot behavior.

## Components

1. Global guidance
- `.github/copilot-instructions.md`

2. Scoped instruction files (auto-mirrored from `.claude/rules/`)
- `.github/instructions/backend-architecture.instructions.md`
- `.github/instructions/backend-testing.instructions.md`
- `.github/instructions/backend-error-handling.instructions.md`
- `.github/instructions/backend-async-patterns.instructions.md`
- `.github/instructions/backend-api-design.instructions.md`
- `.github/instructions/backend-security.instructions.md`
- `.github/instructions/cicd.instructions.md`
- `.github/instructions/enforcement.instructions.md`
- `.github/instructions/workflow.instructions.md`
- `.github/instructions/database-sql-standards.instructions.md`
- `.github/instructions/database-infrastructure.instructions.md`
- `.github/instructions/frontend-conventions.instructions.md`
- `.github/instructions/privacy-gdpr.instructions.md`
- `.github/instructions/rate-limiting.instructions.md`
- `.github/instructions/input-security.instructions.md`
- `.github/instructions/production-safety.instructions.md`
- `.github/instructions/dependency-security.instructions.md`
- `.github/instructions/logging-observability.instructions.md`
- `.github/instructions/health-endpoints.instructions.md`
- `.github/instructions/documentation-standards.instructions.md`
- `.github/instructions/performance-budgets.instructions.md`
- `.github/instructions/error-budgets.instructions.md`

3. Agents
- `.github/agents/backend-architect.agent.md`
- `.github/agents/frontend-architect.agent.md`
- `.github/agents/article-compliance-reviewer.agent.md`

4. Reusable prompts (skills)
- `.github/prompts/bootstrap-harness.prompt.md`
- `.github/prompts/gen-contract-test.prompt.md`
- `.github/prompts/create-migration.prompt.md`
- `.github/prompts/test-hygiene-scan.prompt.md`
- `.github/prompts/e2e-assertion-audit.prompt.md`
- `.github/prompts/pre-merge-verify.prompt.md`

5. Hook policies (deterministic runtime safeguards)
- `.github/hooks/policy.json`

6. Consistency checks
- `scripts/check-instructions-drift.sh`

## How It Works

- Instructions guide behavior by scope.
- Prompt files provide repeatable workflows.
- Hook scripts enforce policy at tool-use time.
- Drift checks verify required assets and references remain aligned.

## Local Validation

Run:

```bash
bash scripts/check-instructions-drift.sh --strict
```

## Updating Customization Safely

When adding or changing customization assets:
1. Update the relevant file in `.github/instructions/`, `.github/prompts/`, `.github/agents/`, or `.github/hooks/`.
2. Add references in `.github/copilot-instructions.md`.
3. Run strict drift check.
4. Ensure CI passes in `.github/workflows/validate-templates.yml`.
