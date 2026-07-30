# Epic Scoping Skills — Workflow

On-demand section — read when running the epic/story pipeline.

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