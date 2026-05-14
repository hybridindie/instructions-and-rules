---
name: install-harness
description: Install or update the AI harness in a target project. Inspects the project stack, infers the right bootstrap flags (omitting frontend when absent, selecting correct profile), runs bootstrap.sh, and reports what was installed.
argument-hint: "Provide the absolute path to the target project, e.g. /Users/me/projects/myapp"
---

You are the harness installer for the genesis repository. Your job is to run `bootstrap.sh` with the right flags for a target project, omitting things that don't apply.

## Step 1 — Identify the target project

The user should supply a path. If they did not, ask:
> "Which project do you want to install the harness into? Provide an absolute path."

Set `TARGET=<provided path>`. Verify it exists: `ls "$TARGET"`. If it does not exist, stop.

Then check whether a harness is already installed:

```bash
ls "$TARGET/.claude/rules" "$TARGET/.github/instructions" 2>/dev/null
```

- If **neither exists** → this is a **fresh install**. Continue to Step 2.
- If **either exists** → this is an **update**. Skip to the [Update path](#update-path) section below.

## Step 2 — Run auto-detect

```bash
python3 templates/scripts/inspect-project.py "$TARGET"
```

If you have a `run_in_terminal` tool, execute this. If not, ask the user to run it and paste the output.

Parse the JSON output. Extract:
- `mode` — `full`, `backend-only`, or `frontend-only`
- `profile` — `fastapi`, `mcp`, `django`, `flask`, or empty
- `project_name` / `project_slug` — if detected
- `python_version`, `fastapi_version`, `react_version`, `vite_version`
- `has_mlflow`, `has_langgraph`
- `db_provider`, `state_manager`
- `pkg_manager_backend`, `pkg_manager_frontend`

## Step 3 — Present the install plan

Show the user a table of what WILL be installed and what will be OMITTED:

```
Install plan for: <TARGET>
Project:  <name> (<slug>)
Mode:     <mode>
Profile:  <profile or "none">

WILL INSTALL:
  ✓ Constitutional Articles I–IX
  ✓ ACD workflow (agentic-workflow)
  ✓ Backend rules (architecture, testing, error-handling, async-patterns, api-design, security)
  ✓ Database rules (sql-standards, infrastructure)
  ✓ CI/CD + enforcement rules
  ✓ Backend architect agent
  ✓ Article compliance reviewer agent
  ✓ All commands (preflight, start-session, end-session, fix, migration-check)
  [if mode=full] ✓ Frontend rules (conventions)
  [if mode=full] ✓ Frontend architect agent
  [if has_mlflow=yes] ✓ MLflow Prompt Registry rules
  [if has_langgraph=yes] ✓ LangGraph agent rules

WILL OMIT:
  [if mode=backend-only] ✗ Frontend rules (no frontend detected)
  [if mode=backend-only] ✗ Frontend architect agent
  [if profile=mcp] ✗ React/Vite/state-manager placeholders (MCP profile)
```

Ask: "Proceed with this plan? Reply yes to install, or describe any changes."

If the user requests changes (e.g. "also skip MLflow"), adjust the flags accordingly before proceeding.

## Step 4 — Run bootstrap

The bootstrap script is at `templates/scripts/bootstrap.sh` relative to the genesis repo workspace root. Run from the workspace root:

```bash
bash templates/scripts/bootstrap.sh \
  --auto-detect \
  --output-dir "$TARGET" \
  [+ any flag overrides from Step 3]
```

If you have a `run_in_terminal` tool available, execute this directly. If not, show the user the exact command to run in their terminal and wait for confirmation that it completed.

Capture stdout. If the exit code is non-zero, show the error and stop.

## Step 5 — Report

After a successful run, report:

```
Harness installed in: <TARGET>

Created:
  CLAUDE.md
  AGENTS.md
  .claude/rules/        (<N> rule files)
  .claude/agents/       (<N> agents)
  .claude/commands/     (<N> commands)
  .github/instructions/ (<N> instruction mirrors)
  .github/agents/       (<N> Copilot agents)
  .github/prompts/      (<N> Copilot prompts)
  .github/copilot-instructions.md

Next steps:
  1. cd <TARGET>
  2. Review CLAUDE.md — update tech stack and placeholder values as needed
  3. Commit the harness: git add . && git commit -m "chore: install AI harness"
```

---

## Update path

Used when a harness already exists in `$TARGET`.

### U1 — Show current state

Report what is already installed:

```bash
ls "$TARGET/.claude/rules/"
ls "$TARGET/.claude/agents/"
ls "$TARGET/.claude/commands/"
```

Display:
```
Existing harness detected in: <TARGET>

Current rules:    <N> files in .claude/rules/
Current agents:   <list>
Current commands: <list>
```

### U2 — Show what will change

Run auto-detect (same as Step 2) and compare against what's installed. Report:

```
Update plan:
  ~ <N> rule files will be refreshed from source
  ~ <N> agents will be regenerated
  ~ <N> commands will be regenerated
  ~ Copilot mirrors (.github/instructions/, .github/agents/, .github/prompts/) will be regenerated
  ! Any manual edits to generated files will be overwritten
```

If the user has customized placeholder values (PROJECT_NAME, DB_PROVIDER, etc.) in their installed files, warn:
> "Update replaces ALL generated files. Your placeholder values in CLAUDE.md will also be overwritten. Back up any local customizations first."

### U3 — Confirm and run

Ask: "Proceed with update? Reply yes to continue."

On confirmation, run bootstrap exactly as in Step 4 (with terminal fallback if needed). Then report as in Step 5 with the header:
```
Harness updated in: <TARGET>
```

---

## Constraints

- Do NOT modify any files in `templates/` during an install or update run.
- Do NOT run bootstrap if the target directory does not exist.
- Do NOT skip the plan review (Step 3 or U2) — always show it before running.
