<!--
  review-checkpoint.md — Shared stakeholder-review pattern
  Referenced by: epic-composer Phase 6, story-decomposer Phase 6
  version: 1.0.0, owner: John D
  Single source of truth for the present → ask → incorporate → declare-or-loop
  pattern previously duplicated as Phase 6 in both skills.
-->

# Stakeholder Review Checkpoint

Before declaring work final, present it to the user for review. This step is
not skippable.

## The pattern

1. **Present** the artifact and its quality assessment to the user.
2. **Ask** a focused set of review questions.
3. **Incorporate** the feedback.
4. **Declare final, or loop back** to an earlier phase if the feedback
   introduces new gaps or changes.

## What to present

- The complete draft (Epic or story backlog, as applicable).
- The readiness assessment with dimension scores.
- Any remaining [PROVISIONAL] or [BLOCKED] items.
- A summary of what was inferred vs. explicitly stated in sources.

## What to ask (minimum set)

- Does the draft accurately reflect the intended scope?
- Are there corrections to the problem statement, outcomes, or stories?
- Are the acceptance criteria correct and complete?
- Are the [BLOCKED] items acceptable to defer, or must they be resolved?

A skill may add skill-specific questions on top of this minimum set.

## Loop-back rules

- If the user confirms and the readiness assessment scores ready → declare
  the final state.
- If the user's feedback introduces new gaps → loop back to the gap-closing
  phase (e.g. epic-composer Phase 3, which invokes interview mode).
- If the user requests changes to the draft → loop back to the drafting phase.

## How callers use this file

- `epic-composer` Phase 6 applies this before declaring FINAL_EPIC.
- `story-decomposer` Phase 6 applies this before declaring
  READY_FOR_IMPLEMENTATION.
- Both keep their own final-state label; the checkpoint pattern is shared.