---
name: customize-harness
description: Semantically tailor this project's already-installed AI harness to the project's domain and your personal workflow conventions. Idempotent — safe to re-run as the project evolves.
when_to_use: >
  Run right after installing the harness, and again whenever the project's
  domain, stack, or your workflow conventions change. Trigger phrases:
  "customize the harness", "tailor the rules to this project", "apply my
  workflows", "re-tailor CLAUDE.md", "personalize the harness".
user-invocable: true
---

# Customize Harness

Semantically tailor the **already-installed** harness in the current project.
Unlike the bootstrap render (string substitution only), this rewrites content to
fit the project's domain and your personal conventions. It operates **in place**
on the installed files — it needs no genesis repo or `templates/`, so it is safe
to re-run anytime. It is **idempotent**: re-running refines, it does not duplicate.

## Phase 1 — Gather context

- **Domain:** infer from `README`, `package.json` / `pyproject.toml` description,
  and the top-level module names. If unclear, ask one question.
- **Your workflows:** read `my-workflows.md` at the project root if present. Skip
  any section still left as a `<placeholder>` — treat only filled-in content as real.
- **Installed harness:** list what exists — `CLAUDE.md`, `AGENTS.md`,
  `.claude/rules/**`, `.claude/agents/**`, `.claude/commands/**`, and the
  equivalent Opencode/Copilot files.

## Phase 2 — Propose a plan (always show before editing)

Present a concise list of intended edits, grouped:

- **Domain fit:** generic example service/library names → this project's terms.
- **Criticality:** coverage tiers adjusted to the project's risk profile.
- **Your workflows:** filled-in `my-workflows.md` conventions (commit style,
  branch/PR flow, review checklist, testing stance, preferred tooling) woven into
  `CLAUDE.md` / `AGENTS.md` and the relevant rule files.
- **Trim:** articles/rules that clearly don't apply → propose removal.
- **Special infra:** add custom rule blocks for anything the stack needs.

Ask: "Apply this plan? Reply yes, or adjust." If `my-workflows.md` is absent or
entirely placeholders, say so and skip the workflow-weaving items.

## Phase 3 — Apply

- Edit the files in place, preserving their existing structure and headings.
- Weave workflow conventions into the natural section (e.g. a "Workflow" or
  "Conventions" block in `CLAUDE.md` / `AGENTS.md`), not as a dumped copy.
- Keep `my-workflows.md` as the source of truth — never delete it.
- Do not touch `templates/` or any genesis files (a target project won't have them).

## Phase 4 — Report

Summarize the edits per file. Remind the user this is re-runnable: run
`/customize-harness` again after changing `my-workflows.md` or the project's stack.

## Rules

- **Idempotent** — re-running must refine existing content, never duplicate blocks.
- **Never delete user-authored content** without explicit confirmation.
- **Placeholders are inert** — skip any `<...>` section in `my-workflows.md`.
- **In place only** — operate on installed files; do not depend on `templates/`.
