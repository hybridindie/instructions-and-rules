<!--
  acd-spec-rules.md — Shared ACD (Agent-Generated Change) spec doctrine
  Referenced by: backend-architect.md (response format),
                 frontend-architect.md (response format),
                 enforcement.md (PR acceptance checklist ACD items)
  Rendered into target projects at .claude/rules/doctrine/acd-spec-rules.md
  version: 1.0.0, owner: John D
  Single source of truth for the four-field ACD artifact definition.
-->

# ACD Spec Rules

For agent-generated changes (ACD), the four spec artifacts that must exist
and be human-approved before code is generated. Both architect agents and
the enforcement checklist reference this file instead of restating the
list.

## The four ACD spec artifacts

1. **Intent description** — the problem the change addresses.
2. **BDD scenarios** — Given/When/Then for the behavior.
3. **Feature description** — the ACD artifact with Musts / Must Nots /
   Preferences / Escalation Triggers (the architect agents' response
   format produces this).
4. **Acceptance criteria** — observable, testable outcomes.

All four must be human-approved before any code is generated.

## ACD provenance rules (enforcement checklist)

- Commit tagged with agent identity and intent description reference.
- Session scope constraint was active; no out-of-scope changes bundled.

## ACD pipeline constraint

While the pipeline is red, agents may only generate changes restoring
pipeline health (Constraint 8 — see `ci-enforcement-rules.md`).

## How callers use this file

- `backend-architect.md` and `frontend-architect.md` reference this for
  the response-format spec definition (their response format produces the
  Feature Description artifact).
- `enforcement.md` references this for the ACD checklist items instead of
  restating them.