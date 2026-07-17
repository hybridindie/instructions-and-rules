<!--
  story-rubric.md — Readiness rubric for story backlog
  Referenced by: .agents/skills/story-decomposer.md (Phase 5)
  Input format: story backlog follows .agents/templates/epic/story-shell.md
  version: 2.1.0, owner: John D
-->

# Story Readiness Rubric

Use this rubric to assess whether a story backlog is ready for
implementation by AI coding agents.

## Input format

The story backlog should follow the structure in
`.agents/templates/epic/story-shell.md`.

## Dimensions

### INVEST Criteria (critical — must pass)
1. **INVEST: Independent** — Can each story be completed without waiting
   on another (except for explicitly mapped dependencies)?
2. **INVEST: Negotiable** — Is the story a starting point for
   conversation, not a fixed contract? Does it leave room for
   implementation decisions?
3. **INVEST: Valuable** — Does each story deliver measurable value to a
   user, the business, or the team (for spikes/technical stories)?
4. **INVEST: Estimable** — Can a developer or AI agent reasonably
   estimate the effort? Are the scope and complexity clear enough?
5. **INVEST: Small** — Is each story completable in 1-3 days by a single
   developer?
6. **INVEST: Testable** — Does each story have BDD acceptance criteria
   that can be verified with a pass/fail test?

### Quality Criteria (non-critical — minor gaps allowed)
7. **Vertical slicing** — Does each user story deliver end-to-end value
   (not a horizontal layer like "database" or "API only")? Are technical
   stories used only for genuine prerequisites?
8. **Epic coverage** — Is every Epic acceptance criterion covered by at
   least one user story? Are Epic constraints covered by technical or
   spike stories?
9. **Scope discipline** — Do all stories fall within the Epic's in-scope
   items? Are no out-of-scope items introduced?
10. **NFR traceability** — Do stories that touch performance, security,
    accessibility, or compliance paths reference the relevant Epic NFRs?
11. **Dependency ordering and execution sequence** — Is there a clear,
    acyclic dependency graph with an explicit execution sequence grouped
    into parallel waves? Are sequential gates minimized? Does every
    story have a "Parallelizable with" or "sequential" annotation? Are
    sprint assignments consistent with wave ordering?
12. **Epic back-link** — Does every story include an "Epic: [title]"
    back-link field? Does every story's "Epic ACs covered" trace to a
    real Epic AC? Do technical/spike stories trace to Epic constraints?
13. **Acceptance criteria quality** — Do all story acceptance criteria
    pass the linting rules (observability, testability, specificity,
    outcome focus, non-conflict, coverage)?

### AI-Readiness Criteria (non-critical — minor gaps allowed)
14. **Task breakdown** — Does every story include a task breakdown where
    each task is specific enough for an AI coding agent to execute
    without asking clarifying questions? Are file paths, component names,
    and API endpoints named where known?
15. **AI-parallelization structure** — Do all M and L stories have
    tasks structured as parallel tracks (shared contract → parallel
    tracks → integration)? Is the parallel structure determined before
    task drafting, not as an afterthought?
16. **Story traceability** — Does every story trace back to Epic ACs
    and, through the Epic's traceability map, to original source
    material? Is the source type (explicit/inferred/unresolved) noted?
17. **Risk and assumption surfacing** — Does every story list
    story-specific risks (with impact) and assumptions (with consequence
    if wrong)?
18. **Feature flag and rollback** — Do stories that modify existing
    behavior specify a feature flag? Does every story specify a rollback
    approach?
19. **AI-readable language** — Are stories and tasks written with
    specific component/file/API names, clear distinction between existing
    vs. new code, and no ambiguous pronouns? Could an AI agent implement
    the story without re-interpreting requirements?

## Readiness levels

Assign a readiness level based on the number and criticality of gaps:

- **Ready for Implementation** — 0 gaps in INVEST dimensions (1-6), and at
  most 3 gaps in non-critical dimensions (7-19), each explicitly noted and
  non-blocking. Stories are INVEST-compliant with BDD acceptance criteria,
  task breakdowns, Epic back-links, and source traceability.
- **Needs Revision** — 4+ gaps in non-critical dimensions (7-19), with all
  INVEST dimensions (1-6) Pass.
- **Draft** — Any gap in INVEST dimensions (1-6).

### Critical vs non-critical dimensions
- **Critical (must pass)**: 1-6 (all INVEST criteria)
- **Non-critical (can have minor gaps)**: 7-13 (quality criteria),
  14-19 (AI-readiness criteria)

## Checklist
- Is each story independent (except mapped dependencies)?
- Is each story negotiable (not a fixed implementation contract)?
- Does each story deliver user/business/team value?
- Can each story be estimated?
- Is each story completable in 1-3 days?
- Does each story have BDD acceptance criteria?
- Are user stories vertically sliced? Are technical stories justified?
- Is every Epic AC covered? Are constraints covered by tech/spike stories?
- Do all stories stay within Epic scope?
- Do stories reference applicable Epic NFRs?
- Is the execution sequence grouped into parallel waves with minimal sequential gates?
- Does every story have an Epic back-link and trace to real Epic ACs?
- Do all story acceptance criteria pass the linter?
- Does every story have specific, AI-executable tasks?
- Are M/L story tasks structured as parallel tracks (contract → tracks → integration)?
- Does every story trace to Epic ACs and source material?
- Does every story list risks and assumptions?
- Do risky stories have feature flags? Does every story have a rollback plan?
- Are stories written in AI-readable language (specific names, no ambiguity)?

## Output format

Produce the following structure:

```
## Story Readiness Assessment

### Dimension Scores
State the evidence in Notes first, then assign Status.

| # | Dimension | Notes (evidence) | Status |
|---|-----------|------------------|--------|
| 1 | INVEST: Independent | ... | Pass / Gap |
| 2 | INVEST: Negotiable | ... | Pass / Gap |
| 3 | INVEST: Valuable | ... | Pass / Gap |
| 4 | INVEST: Estimable | ... | Pass / Gap |
| 5 | INVEST: Small | ... | Pass / Gap |
| 6 | INVEST: Testable | ... | Pass / Gap |
| 7 | Vertical slicing | ... | Pass / Gap |
| 8 | Epic coverage | ... | Pass / Gap |
| 9 | Scope discipline | ... | Pass / Gap |
| 10 | NFR traceability | ... | Pass / Gap |
| 11 | Dependency ordering + execution sequence | ... | Pass / Gap |
| 12 | Epic back-link | ... | Pass / Gap |
| 13 | Acceptance criteria quality | ... | Pass / Gap |
| 14 | Task breakdown | ... | Pass / Gap |
| 15 | AI-parallelization structure | ... | Pass / Gap |
| 16 | Story traceability | ... | Pass / Gap |
| 17 | Risk/assumption surfacing | ... | Pass / Gap |
| 18 | Feature flag / rollback | ... | Pass / Gap |
| 19 | AI-readable language | ... | Pass / Gap |

### Readiness Level
Ready for Implementation | Needs Revision | Draft

### Quality Gaps
- (list each gap with the dimension it affects and what is needed to close it)

### Recommendation
Proceed to implementation / Return to decomposition / Needs story revision
```