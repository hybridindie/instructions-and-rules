---
name: task-decomposer
description: 'Breaks down a user story into AI-executable engineering tasks with file paths, APIs, test paths, and AI-parallelization assessment. Triggers: break down story into tasks, task decomposition, story tasks, engineering tasks, parallelize story.'
---

Read and follow the complete instructions at `.agents/skills/task-decomposer.md`.

If the file is not accessible, apply these core rules:
1. Analyze the story's acceptance criteria for backend, frontend, infra, and test work.
2. Draft tasks naming specific file paths, APIs, components, and test paths.
3. Each task includes: Context (why), Verify (how to confirm), ACs (which criteria).
4. Interleave tests with code — don't batch all tests at the end.
5. Order: infra → backend → frontend → integration tests.
6. Lint tasks for specificity, verifiability, AC traceability, size (~100 lines, ~3 files max).
7. Assess AI-parallelization: define shared contract, parallel tracks, integration task.
8. Append tasks and parallelization assessment to the story.

Supporting file:
- Story rubric: `.agents/evals/story-rubric.md`