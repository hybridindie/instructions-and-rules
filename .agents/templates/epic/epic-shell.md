<!--
  epic-shell.md — Epic structural skeleton
  Referenced by: .agents/skills/epic-composer.md (Phase 4)
  version: 3.1.0, owner: John D
-->

# Epic Title

## Epic Summary
A 2-3 sentence overview of what this Epic delivers and why.

## Problem Statement
### Current State
What is broken, missing, or painful today? Describe the specific problem
users or the business faces. Ground this in source material, not assumptions.

### Desired Future State
What does the world look like after this Epic is delivered? Describe the
outcome, not the implementation.

## Users / Stakeholders
- Primary users: (who directly uses the feature)
- Secondary users: (who is affected but not the primary actor)
- Impacted teams: (engineering, support, operations, etc.)
- Decision owners: (who signs off on scope and acceptance)

### User Context
What are primary users trying to accomplish when they hit this problem?
What is their current workaround? What pain does it cause?

## Business / User Value
What measurable value does delivering this Epic create? Tie to business
goals or user outcomes, not implementation milestones.

## Scope
### In Scope — Must Have (MVP)
- (core items required for the Epic to deliver value)

### In Scope — Should Have (Phase 2)
- (valuable but not blocking for initial delivery)

### Out of Scope
- (explicitly excluded items, with brief rationale)

## Constraints and Dependencies
- Technical constraints
- Policy/compliance constraints
- Upstream/downstream dependencies
- Required integrations or operational dependencies

## Non-Functional Requirements
- Performance: (response time, throughput, load expectations)
- Security: (auth, authz, data protection, audit needs)
- Accessibility: (WCAG level, specific accommodations)
- Observability: (logging, metrics, alerting requirements)
- Compliance: (regulatory, contractual, organizational)
- (Mark any NFR as [UNKNOWN] if not established by source material)

## Source Alignment Notes
- Confirmed across multiple sources
- Present in one source only
- Conflicting across sources

## Assumptions
- ...

## Risks
- ...

## Edge Cases and Validation Considerations
- unhappy paths
- empty states
- invalid inputs
- duplicate actions
- partial completion
- authorization/permission issues
- data quality problems
- concurrency or race conditions where relevant
- migration or backward compatibility where relevant

## Acceptance Criteria
Write each criterion using the outcome pattern: "When [trigger], then
[observable behavior], so that [user/business value]." Story decomposition
later refines each Epic AC into concrete Given/When/Then scenarios; write the
outcome so it survives that translation.

Example:
- When a support agent handling 3 concurrent chats escalates to a supervisor,
  then the supervisor receives the full chat history without the agent losing
  context, so that the handoff takes under 30 seconds and requires no
  re-typing.

- When a user exports a report, then the system produces a PDF within 10
  seconds for reports under 500 rows, so that the user does not wait or
  retry.

Number each criterion (AC1, AC2, ...) for traceability.

1. AC1: ...
2. AC2: ...
3. AC3: ...

## Success Measures
- Outcome metric: (what you measure to know the Epic worked)
- Leading indicator: (early signal you're on the right track)
- Operational quality signal: (error rate, latency, support tickets)
- Baseline known? yes / no (if no, establishing the baseline is a prerequisite)
- Target known? yes / no (if no, defining the target is a prerequisite)

## Open Questions
- ...

## Definition of Done
The Epic is done when:
- [ ] All acceptance criteria are met or explicitly descoped with rationale
- [ ] Traceability is complete for all scope items and acceptance criteria
- [ ] All contradictions are resolved or explicitly deferred with owner and date
- [ ] NFRs are addressed or marked [UNKNOWN] with a plan to resolve
- [ ] Success measures have baselines and targets (or a plan to establish them)
- [ ] The Epic has been reviewed by at least one stakeholder outside the author
- [ ] Readiness rubric scores "Ready for Decomposition"

## Readiness Assessment
- Draft | Needs Clarification | Ready for Decomposition

## Traceability Map
- Use `.agents/templates/epic/traceability-template.md` for the table format.
- Include inline or link to a separate traceability document.