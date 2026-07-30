# AI Harness Template Repository

This is the **genesis repository**. It generates AI assistant harnesses for
`.claude/`, `.github/`, and `.opencode/` from a single set of shared
constitutional articles. It also hosts the **Epic Scoping Skills** as its own
installed harness.

## Architecture (summary)

Two systems share the same single-source/thin-wrapper pattern:

- **Genesis harness**: `templates/_shared/` → rendered into target projects by `bootstrap.sh`. Constitutional articles, agents, commands, doctrine, and shippable skills.
- **Epic Scoping Skills**: `.agents/` → thin wrappers in `.claude/`, `.opencode/`, `.github/`. Skills, doctrine, templates, evals.

**Golden rule:** Edit content in `.agents/` (epic skills) or `templates/_shared/` (genesis). Edit frontmatter in the harness wrappers. Never duplicate content into a wrapper. Shared rules referenced by multiple files live in a `doctrine/` layer — reference, don't restate.

## On-demand reference sections

Read these when you need the detail — they are not auto-loaded:

| Section | File | Read when |
|---|---|---|
| What it does / Install / Key flags | [`docs/agents-sections/genesis-overview.md`](docs/agents-sections/genesis-overview.md) | Installing or bootstrapping a harness |
| Source structure (file tree) | [`docs/agents-sections/source-structure.md`](docs/agents-sections/source-structure.md) | Editing the genesis repo structure |
| Epic skills architecture | [`docs/agents-sections/architecture.md`](docs/agents-sections/architecture.md) | Understanding the `.agents/` layout |
| Workflow (pipeline diagram) | [`docs/agents-sections/workflow.md`](docs/agents-sections/workflow.md) | Running the epic → story → task pipeline |
| Skills, templates, evals, doctrine, wrappers, response states | [`docs/agents-sections/skills-and-references.md`](docs/agents-sections/skills-and-references.md) | Invoking a skill or checking references |
| Full usage guide | [`prompts-skills.md`](prompts-skills.md) | Per-harness setup, hooks table, worked examples |
| Editing contract (versioning, drift, hooks) | [`CONTRIBUTING-HARNESS.md`](CONTRIBUTING-HARNESS.md) | Editing this repo |

## Skills at a glance

| Skill | Invoke | Shared content |
|---|---|---|
| epic-composer | `/epic-composer` | `.agents/skills/epic-composer.md` |
| epic-interview | `/epic-interview` | `.agents/skills/epic-interview.md` |
| epic-acceptance-linter | `/epic-acceptance-linter` | `.agents/skills/epic-acceptance-linter.md` |
| story-decomposer | `/story-decomposer` | `.agents/skills/story-decomposer.md` |
| task-decomposer | `/task-decomposer` | `.agents/skills/task-decomposer.md` |
| bootstrap-harness | `/bootstrap-harness` | `.agents/skills/bootstrap-harness.md` |

Each skill wrapper is a thin pointer; the model reads the `.agents/` body
on-demand when the skill is invoked. Doctrine files (`.agents/doctrine/`) are
read on-demand when a skill references them.