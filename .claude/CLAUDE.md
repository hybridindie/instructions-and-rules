@../AGENTS.md

# Claude Code — Epic Scoping Skills

## Skills available

Skills are in `.claude/skills/<name>/SKILL.md` with Claude Code frontmatter.
Each wrapper references the shared content in `.agents/skills/<name>.md` and
accepts `$ARGUMENTS` for user-provided input. Invoke with `/epic-composer`,
`/epic-acceptance-linter`, `/epic-interview`, `/story-decomposer`,
`/task-decomposer`, or let Claude load them when relevant.

## Shared asset store

All editable content lives under `.agents/`. **Edit content in `.agents/`,
edit frontmatter in the harness wrappers.** Skills, templates, rubrics,
and prompts are referenced by path from the skills — the model reads them
on demand when a skill is invoked.