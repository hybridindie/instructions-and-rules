# AI Harness Template Repository

This is the **genesis repository**. It generates AI assistant harnesses for `.claude/`, `.github/`, and `.opencode/` from a single set of shared constitutional articles. It also hosts the **Epic Scoping Skills** (documented further below) as its own installed harness.

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
    skills/        ← Shared shippable skills (rendered into target .claude/ + .opencode/)
    my-workflows.md ← Your cross-project conventions; shipped into each project and
                      applied by the customize-harness skill (edit once, all installs inherit)
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

## Working on the genesis repo

- **Add a new article**: add `.md` to `templates/_shared/articles/`, add an entry in `mirror-pairs.json`, run bootstrap to test.
- **Add a new agent**: add `.md` to `templates/_shared/agents/`, add an `agent_entries` entry in `mirror-pairs.json`.
- **Add a new command**: add `.md` to `templates/_shared/commands/`, add a `command_entries` entry in `mirror-pairs.json`.
- **Check for drift**: `bash templates/claude-code/.claude/hooks/check-primitive-drift.sh` (must be run from repo root with a bootstrapped harness in scope).
- **Test a bootstrap**: `bash templates/scripts/bootstrap.sh --project-name Test --project-slug test --output-dir /tmp/test-harness`.

## Drift policy

`templates/_shared/` is the single source. Platform-specific files in `templates/claude-code/.claude/agents/`, `templates/claude-code/.claude/commands/`, and `templates/github-copilot/.github/agents/` + `templates/github-copilot/.github/prompts/` are **generated output** — do not edit them directly. Edit the shared source and re-run bootstrap.

---

# Epic Scoping Skills

Reusable skills, templates, and eval rubrics for building solid epics when
scoping new work. Targets three AI coding harnesses: Opencode, Claude Code,
and GitHub Copilot.

## Architecture

Shared content lives in `.agents/` as plain markdown — no frontmatter, no
harness-specific fields. Each harness has its own thin wrapper files with
only the frontmatter that harness recognizes. The wrappers reference the
shared content by path.

```
.agents/   Shared content — skills, templates, evals   (EDIT HERE)
   │  ├── skills/     epic-* skills + bootstrap-harness (the harness install/tailor flow)
   │  ├── templates/  epic/story/traceability shells
   │  └── evals/      readiness rubrics
   │
   │  wrapped by thin, frontmatter-only pointers per harness:
   ├── Opencode        .opencode/skills/<name>/SKILL.md   + opencode.json commands
   ├── Claude Code     .claude/skills/<name>/SKILL.md     (skills double as /commands)
   │                   .claude/agents/<name>.md           (agents point at the same bodies)
   └── GitHub Copilot  .github/skills/<name>/SKILL.md
                       .github/agents/<name>.agent.md     (agents point at the same bodies)
```

Both the epic-scoping skills **and** the genesis meta-flow follow this rule.
`bootstrap-harness` is the single canonical body for installing/tailoring a
harness; the `install-harness` agent (Claude Code / Copilot) is just another
thin entry point pointing at that same file. Only genesis template *output*
under `.github/instructions/`, `.github/copilot-instructions.md`, etc. is exempt
— that is deduped by `templates/_shared/`, not `.agents/`.

**Golden rule:** Edit content in `.agents/`. Edit frontmatter in the harness
wrappers. Never duplicate content into a wrapper.

## Workflow

```
Phase 1: Epic Creation
──────────────────────
Source material (transcripts, docs, notes, existing codebase)
  |
  v
epic-composer  -- Phase 0: Context Discovery (greenfield vs brownfield)
  |            -- Phase 1: Source Synthesis
  |            -- Phase 2: Contradiction & Completeness Review
  |            -- Phase 3: Guided Interview (invokes epic-interview, waves)
  |            -- Phase 4: Epic Draft (epic-shell + linter + traceability)
  v
epic-composer  -- Phase 5: Readiness Assessment (applies epic-rubric)
  |
  v
epic-composer  -- Phase 6: Stakeholder Review Checkpoint
  |
  v
Ready Epic artifact + traceability map + readiness level

Phase 2: Story Decomposition
─────────────────────────────
story-decomposer -- Phase 1: Epic Validation
  |              -- Phase 2: Decomposition Planning (coverage matrix)
  |              -- Phase 3: Story Drafting (story-shell + BDD + INVEST + linter)
  v
story-decomposer -- Phase 4: Dependency Mapping (ordered backlog)
  |
  v
story-decomposer -- Phase 5: Story Readiness Assessment (story-rubric)
  |
  v
story-decomposer -- Phase 6: Stakeholder Review Checkpoint
  |
  v
Ready story backlog with INVEST-compliant stories + BDD acceptance criteria
```

## Skills

| Skill | Shared content | Purpose |
|---|---|---|
| epic-composer | `.agents/skills/epic-composer.md` | Transforms source material into a complete Epic |
| epic-acceptance-linter | `.agents/skills/epic-acceptance-linter.md` | Lints acceptance criteria quality |
| epic-interview | `.agents/skills/epic-interview.md` | Guided interview to close gaps |
| story-decomposer | `.agents/skills/story-decomposer.md` | Decomposes a ready Epic into INVEST-compliant stories |
| task-decomposer | `.agents/skills/task-decomposer.md` | Breaks down stories into AI-executable tasks with parallelization assessment |
| bootstrap-harness | `.agents/skills/bootstrap-harness.md` | The install/tailor flow: fetch genesis → detect stack → plan review → render via `bootstrap.sh` → validate → report. Also exposed as the `install-harness` agent and the `install.sh` shortcut. |

## Templates and evals

- Epic skeleton: `.agents/templates/epic/epic-shell.md`
- Story backlog: `.agents/templates/epic/story-shell.md`
- Traceability table: `.agents/templates/epic/traceability-template.md`
- Epic readiness rubric: `.agents/evals/epic-rubric.md`
- Story readiness rubric: `.agents/evals/story-rubric.md`

## Harness-specific wrappers

| Harness | Skill location | Commands | Hooks | Frontmatter fields |
|---|---|---|---|---|
| Opencode | `.opencode/skills/<name>/SKILL.md` | `opencode.json` command entries: `/epic-composer`, `/epic-interview`, `/epic-acceptance-linter`, `/story-decomposer`, `/task-decomposer` | `.opencode/plugins/*.ts` | `name`, `description` |
| Claude Code | `.claude/skills/<name>/SKILL.md` | skills double as `/epic-composer`, `/epic-acceptance-linter`, `/epic-interview`, `/story-decomposer`, `/task-decomposer` (accept `$ARGUMENTS`) | `.claude/hooks/*.sh` | `name`, `description`, `when_to_use` |
| GitHub Copilot | `.github/skills/<name>/SKILL.md` | skills appear in the Copilot Chat `/` menu under the same names | `.github/hooks/*.json` + `scripts/` | `name`, `description` |

The command names are identical across harnesses (the skill names). Each skill
wrapper is a one-line body referencing `.agents/skills/<name>.md`; the Opencode
and Claude Code wrappers also take `$ARGUMENTS` for user-provided input.

## Response states

Each skill labels its output with one of these states (`→` marks a progression;
`/` marks alternatives):

- **epic-composer:** `SYNTHESIS_ONLY` → `INTERVIEW_REQUIRED` → `PARTIAL_EPIC` → `FINAL_EPIC`
- **epic-acceptance-linter:** `PASS` / `NEEDS_REVISION` / `BLOCKED`
- **epic-interview:** `QUESTIONS_PENDING` / `PARTIALLY_RESOLVED` / `RESOLVED`
- **story-decomposer:** `EPIC_NOT_READY` / `DECOMPOSITION_PLANNED` / `STORIES_DRAFTED` / `TASKS_ADDED` / `READY_FOR_IMPLEMENTATION` / `NEEDS_REVISION` / `REFINEMENT_IN_PROGRESS`
- **task-decomposer:** `NEEDS_ACCEPTANCE_CRITERIA` / `PARALLELIZATION_PLANNED` / `TASKS_DRAFTED` / `TASKS_LINTED` / `READY`

## Hooks

The hooks matter only when **editing** this content — they don't affect using
the skills. Each harness ships a non-blocking "pointer-edit" guardrail: editing
a thin wrapper instead of the canonical `.agents/` content fires a reminder (it
warns, never blocks). Configs: `.opencode/plugins/warn-pointer-edit.ts`,
`.claude/hooks/warn-pointer-edit.sh`, `.github/hooks/warn-pointer-edit.json`.

## Full usage guide

See [`prompts-skills.md`](prompts-skills.md) for the complete guide: annotated
layout, per-harness setup with docs links, the hooks table, and worked
end-to-end example workflows for each command.