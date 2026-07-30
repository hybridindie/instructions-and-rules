<!--
  context-discovery.md — Shared greenfield/brownfield discovery probe
  Referenced by: epic-composer Phase 0, task-decomposer Phase 1
  version: 1.0.0, owner: John D
  Single source of truth for the greenfield/brownfield detection previously
  duplicated across skills.
-->

# Context Discovery

Before synthesizing source material or decomposing work, determine whether
the project is greenfield or brownfield. The classification changes which
constraints are available.

## Classification

- If the workspace has existing code (source files, package manifests, README,
  AGENTS.md), classify as **brownfield**.
- If the workspace is empty or only has config files, classify as
  **greenfield**.

## Brownfield probes

If brownfield, read the following (where present) and record findings as
**Project Constraints**:

- `AGENTS.md` or `README.md` — conventions, architectural rules.
- Package manifest (`package.json`, `pyproject.toml`, `go.mod`, etc.) — tech
  stack and dependencies.
- Existing test files (glob) — testing conventions.
- Existing code structure — architectural constraints, patterns, and
  conventions; name the specific files, modules, and components the work will
  touch.

## Greenfield handling

If greenfield:
- Note that there are no existing constraints from the codebase.
- Rely entirely on user-provided material for constraints.
- When naming new files, components, or APIs, mark them as "(new)".

## How callers use this file

- `epic-composer` Phase 0 runs this before source synthesis and adds findings
  as Project Constraints in the synthesis output.
- `task-decomposer` Phase 1 runs this to name specific existing files and
  components in tasks (brownfield), or to mark new files "(new)" (greenfield).