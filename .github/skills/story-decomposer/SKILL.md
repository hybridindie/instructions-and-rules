---
name: story-decomposer
description: 'Decomposes a ready Epic into INVEST-compliant stories with task breakdowns, AI-parallelization assessment, sprint grouping, and source traceability. Triggers: decompose epic, break down epic into stories, create stories from epic, split epic, generate backlog, story tasks.'
---

Read and follow the complete instructions at `.agents/skills/story-decomposer.md`.

Key behaviors:
- Identify spike, technical, and user story types
- Write BDD acceptance criteria (Given/When/Then)
- Apply INVEST criteria
- Break down each story into AI-executable tasks (name files, APIs, test paths)
- Assess AI-parallelization for M/L stories
- Add story-level traceability to Epic ACs and source material
- Specify feature flags and rollback approaches
- Group stories into suggested sprints (MVP first)
- Assess readiness using the story rubric

Supporting files:
- Story template: `.agents/templates/epic/story-shell.md`
- Story rubric: `.agents/evals/story-rubric.md`
- Acceptance linter: `.agents/skills/epic-acceptance-linter.md`