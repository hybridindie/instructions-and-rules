---
description: "Use when editing rule files in .claude/rules/ or instruction files in .github/instructions/ — warns when the corresponding mirror file has drifted and needs updating."
applyTo: ".claude/rules/**, .github/instructions/**"
---

# Primitive Drift: Rule/Instruction Mirror Sync

`.claude/rules/` (Claude Code) and `.github/instructions/` (GitHub Copilot) are mirrors of the same rules. They intentionally have different frontmatter — Claude uses `paths:`, Copilot uses `applyTo:` — but the **body content must be identical**.

## Mirror Pairs

| Claude (`/.claude/rules/`) | Copilot (`/.github/instructions/`) |
|---|---|
| `cicd.md` | `cicd.instructions.md` |
| `enforcement.md` | `enforcement.instructions.md` |
| `backend/api-design.md` | `backend-api-design.instructions.md` |
| `backend/architecture.md` | `backend-architecture.instructions.md` |
| `backend/async-patterns.md` | `backend-async-patterns.instructions.md` |
| `backend/error-handling.md` | `backend-error-handling.instructions.md` |
| `backend/security.md` | `backend-security.instructions.md` |
| `backend/testing.md` | `backend-testing.instructions.md` |
| `database/infrastructure.md` | `database-infrastructure.instructions.md` |
| `database/sql-standards.md` | `database-sql-standards.instructions.md` |
| `frontend/conventions.md` | `frontend-conventions.instructions.md` |

`workflow.md` has no Copilot mirror — global guidance lives in `.github/copilot-instructions.md`.

## When You Edit One File

When editing either file in a mirror pair, follow these steps in order:

1. **Update the body** — Edit the body content (all text, formatting, and comments after the closing `---` of the frontmatter block) so it is character-for-character identical in both files.
2. **Leave frontmatter unchanged** — Do not modify the frontmatter of the mirror file; only the body must match.
3. **Warn on detected drift** — If the bodies have already diverged, warn before proceeding:

> **PRIMITIVE-DRIFT**: `<file>` and its mirror `<mirror>` have diverged. Update both to match before proceeding.

To verify sync manually:
```bash
bash .claude/hooks/check-primitive-drift.sh
```
