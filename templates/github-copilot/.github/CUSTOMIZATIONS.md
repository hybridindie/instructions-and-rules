# Customization System

This repository uses a layered customization system for Copilot behavior.

## Components

1. Global guidance
- `.github/copilot-instructions.md`

2. Scoped instruction files
- `.github/instructions/backend-python.instructions.md`
- `.github/instructions/frontend-typescript.instructions.md`
- `.github/instructions/supabase-migrations.instructions.md`
- `.github/instructions/testing-standards.instructions.md`
- `.github/instructions/privacy-auth.instructions.md`
- `.github/instructions/docs-adr.instructions.md`

3. Reusable prompt
- `.github/prompts/pre-merge-verify.prompt.md`

4. Hook policies (deterministic runtime safeguards)
- `.github/hooks/policy.json`
- `scripts/hook-pretool-policy.sh`
- `scripts/hook-pretool-refactor-policy.sh`

5. Consistency checks
- `scripts/check-instructions-drift.sh`
- `.github/workflows/instructions-drift.yml`

## How It Works

- Instructions guide behavior by scope.
- Prompt files provide repeatable workflows.
- Hook scripts enforce policy at tool-use time.
- Drift checks verify required assets and references remain aligned.

## Local Validation

Run:

```bash
./scripts/check-instructions-drift.sh --strict
```

## Updating Customization Safely

When adding or changing customization assets:
1. Update the relevant file in `.github/instructions/`, `.github/prompts/`, `.github/hooks/`, or `scripts/`.
2. Add references in `.github/copilot-instructions.md`.
3. Run strict drift check.
4. Ensure CI passes in `.github/workflows/instructions-drift.yml`.
