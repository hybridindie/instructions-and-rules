---
description: "Bootstrap a complete AI instruction harness for this project. Auto-detects stack and mode."
---

# Bootstrap Harness

Generate a complete AI assistant harness for this project using the template system.

## Pre-requisites

This repository must have `templates/scripts/bootstrap.sh` and `templates/scripts/inspect-project.py` available (either cloned locally or referenced via a template repo).

## Steps

1. **Auto-detect project stack**
   ```bash
   python3 templates/scripts/inspect-project.py "$(pwd)"
   ```
   Record `mode`, `profile`, `project_name`, `python_version`, `pkg_manager_backend`, `db_provider`.

2. **Render harness**
   ```bash
   bash templates/scripts/bootstrap.sh \
     --auto-detect \
     --output-dir "."
   ```
   If auto-detect confidence is medium, review the inferred values before proceeding.

3. **Verify output**
   - `CLAUDE.md` exists
   - `AGENTS.md` exists
   - `.github/copilot-instructions.md` exists
   - `.claude/rules/` has articles I–IX
   - `.github/instructions/` has mirrored instruction files
   - `.opencode/skills/` has equivalent skills

4. **Run validation**
   ```bash
   python3 templates/scripts/check-harness-sync.py templates .
   ```
   Must report PASS.

## Rules

- Do not overwrite existing files without confirmation.
- If the project is backend-only (no package.json, no frontend directory), `--auto-detect` will set `mode=backend-only` and suppress frontend rules.
- If the project uses MCP (detected via `mcp` in pyproject.toml deps), profile will be `mcp` and overlays will replace FastAPI guidance with MCP server patterns.
