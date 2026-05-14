# AI Harness Template Repository

This is the **genesis repository**. It generates AI assistant harnesses for `.claude/`, `.github/`, and `.opencode/` from a single set of shared constitutional articles.

## What it does

`templates/scripts/bootstrap.sh` reads `templates/_shared/` (canonical source) and renders three equivalent harnesses into a target project:

| Platform | Entry point | Rules location |
|----------|-------------|----------------|
| Claude Code | `CLAUDE.md` | `.claude/rules/`, `.claude/agents/`, `.claude/commands/` |
| GitHub Copilot | `.github/copilot-instructions.md` | `.github/instructions/`, `.github/agents/`, `.github/prompts/` |
| Opencode | `CLAUDE.md` | `.opencode/` |

## Install a harness into a project

```bash
# Auto-detect (recommended) — probes the target project and infers the right flags
bash templates/scripts/bootstrap.sh --auto-detect --output-dir /path/to/target/project

# Manual — supply values explicitly
bash templates/scripts/bootstrap.sh \
  --project-name "MyApp" \
  --project-slug "myapp" \
  --output-dir /path/to/target/project
```

When a project has no frontend, the bootstrap script automatically omits frontend rules, stores, and commands (`--mode backend-only`). When a project is an MCP server, it sets `--profile mcp`.

## Key flags

| Flag | Purpose |
|------|---------|
| `--auto-detect` | Inspect `--output-dir` for stack, versions, dependencies |
| `--mode backend-only` | Skip all frontend rules and placeholders |
| `--profile mcp` | MCP server profile (strips React/Vite/state-manager) |
| `--has-mlflow yes/no` | Include MLflow Prompt Registry rules |
| `--has-langgraph yes/no` | Include LangGraph agent rules |

## Source structure

```
templates/
  _shared/
    articles/      ← Constitutional rules (rendered into all three harnesses)
    agents/        ← Shared agent definitions (Claude frontmatter → Copilot transformed)
    commands/      ← Shared commands/prompts (body identical across platforms)
    database/      ← SQL and infrastructure rules
    frontend/      ← Frontend conventions
    mirror-pairs.json  ← Single source of truth for all mirror pairs
  claude-code/    ← Claude-specific harness assets (skills, hooks, scripts)
  github-copilot/ ← Copilot-specific assets (prompts that aren't mirrored commands)
  opencode/       ← Opencode-specific assets
  scripts/
    bootstrap.sh                 ← Main installer
    generate-copilot-mirrors.py  ← Transforms Claude frontmatter → Copilot frontmatter
    inspect-project.py           ← Detects project stack (used by --auto-detect)
    process-conditionals.py      ← Strips {{#FLAG}}...{{/FLAG}} blocks
```

## Working on this repo

- **Add a new article**: add `.md` to `templates/_shared/articles/`, add an entry in `mirror-pairs.json`, run bootstrap to test.
- **Add a new agent**: add `.md` to `templates/_shared/agents/`, add an `agent_entries` entry in `mirror-pairs.json`.
- **Add a new command**: add `.md` to `templates/_shared/commands/`, add a `command_entries` entry in `mirror-pairs.json`.
- **Check for drift**: `bash templates/claude-code/.claude/hooks/check-primitive-drift.sh` (must be run from repo root with a bootstrapped harness in scope).
- **Test a bootstrap**: `bash templates/scripts/bootstrap.sh --project-name Test --project-slug test --output-dir /tmp/test-harness`.

## Drift policy

`templates/_shared/` is the single source. Platform-specific files in `templates/claude-code/.claude/agents/`, `templates/claude-code/.claude/commands/`, and `templates/github-copilot/.github/agents/` + `templates/github-copilot/.github/prompts/` are **generated output** — do not edit them directly. Edit the shared source and re-run bootstrap.
