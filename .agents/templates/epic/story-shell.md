<!--
  story-shell.md — Story backlog structural skeleton
  Referenced by: .agents/skills/story-decomposer.md (Phase 3)
  version: 2.1.0, owner: John D
-->

# Story Backlog: [Epic Title]

## Epic Reference
- Epic: [title]
- Readiness: Ready for Decomposition
- Epic ACs: AC1, AC2, AC3, ...
- Epic NFRs: [list relevant NFRs]
- Epic traceability map: [reference or inline]

## Coverage Matrix

| AC / Constraint | Stories | Type | Strategy used |
|-----------------|---------|------|---------------|
| AC1 | Story 1 | user | Workflow steps |
| AC2 | Story 2, Story 3 | user | Data variations |
| NFR: performance | Story 4 | technical | Enablement |
| Unknown: PDF lib | Story 0 | spike | Research |

## Execution Sequence

Stories are grouped into parallel execution waves. Within each wave,
stories can be dispatched to AI agents simultaneously. Waves are
sequential — Wave N+1 depends on Wave N completing.

### Wave 1 (parallel — no dependencies)
- Story 0: [title]
- Story 4: [title]

### Wave 2 (parallel — depends on Wave 1)
- Story 1: [title]
- Story 5: [title]
  → Shared contract: [API spec / type / file format]

### Wave 3 (sequential — depends on Wave 2)
- Story 2: [title]
- Story 3: [title]

## Sprint Plan

| Sprint | Wave(s) | Stories | Total effort | Theme |
|--------|---------|---------|-------------|-------|
| 0 | 1 | Story 0, Story 4 | S + S | De-risk + infra |
| 1 | 2 | Story 1, Story 5 | S + M | MVP core (parallel) |
| 2 | 3 | Story 2, Story 3 | M + S | MVP complete |

## Backlog Order

| Order | Wave | Story | Type | Estimate | Sprint | Blocked by | Parallel with |
|-------|------|-------|------|----------|--------|------------|---------------|
| 1 | 1 | Story 0: [title] | spike | S | 0 | — | Story 4 |
| 2 | 1 | Story 4: [title] | tech | S | 0 | — | Story 0 |
| 3 | 2 | Story 1: [title] | user | S | 1 | Story 0, 4 | Story 5 |
| ... | ... | ... | ... | ... | ... | ... | ... |

---

## Story 0: [Spike Title] (example spike)

**Epic:** [Epic Title]
**Type:** spike
**As a** team,
**I want** to evaluate PDF generation libraries,
**so that** we can choose one that meets our < 10s p95 NFR.

**Epic constraints covered:** NFR: performance, Unknown: PDF library
**Dependencies:** None — parallel-safe, can start immediately
**Parallelizable with:** Story 4 (Set up PDF infra)
**Estimate:** S
**Sprint:** 0
**Feature flag:** N/A
**Rollback:** N/A

### Acceptance Criteria
- **Given** three candidate libraries, **when** each is benchmarked with
  a 500-row report, **then** the results document generation time, memory
  usage, and bundle size for each.

### Output
- A findings document with a recommended library and rationale.

### Tasks
(Task breakdown is added by the task-decomposer skill.)

### AI-Parallelization Assessment
(Added by the task-decomposer skill.)

---

## Story 1: [Title] (example user story)

**Epic:** [Epic Title]
**Type:** user
**As a** report viewer,
**I want** to export a report as PDF,
**so that** I can share it with stakeholders who don't have dashboard
access.

**Epic ACs covered:** AC1
**Dependencies:** Blocked by Story 0 (spike), Story 4 (infra)
**Parallelizable with:** Story 5 (Export UI controls) — shared contract:
  `POST /api/reports/{id}/export` returns `{ jobId, status, downloadUrl }`
**Estimate:** S
**Sprint:** 1
**Feature flag:** `pdf_export_enabled`
**Rollback:** Disable flag. No data migration required.

### Acceptance Criteria (BDD format)
- **Given** a report under 500 rows exists, **when** the user clicks
  "Export as PDF", **then** the system generates and downloads a PDF
  within 10 seconds, so that the user doesn't wait or retry.
- **Given** the PDF service is unavailable, **when** the user clicks
  "Export as PDF", **then** the system shows an error message with a
  retry button, so that the user can recover without losing context.

### Traceability
| Claim | Epic AC | Source | Type |
|-------|---------|--------|------|
| PDF export for small reports | AC1 | Meeting transcript 2024-01-15, L34 | explicit |
| < 10s generation time | AC1 NFR | Inferred from "slow export" complaint | inferred |

### Risks and Assumptions
- Risk: PDF library may not handle complex report layouts (tables with
  merged cells). Impact: export may produce broken PDFs for some reports.
- Assumption: Reports under 500 rows fit in memory for PDF generation.
  If not, Story 3 will address streaming/large reports.

### Tasks
(Task breakdown is added by the task-decomposer skill. Invoke
`.agents/skills/task-decomposer.md` on this story to generate tasks.)

### AI-Parallelization Assessment
(Added by the task-decomposer skill along with the task breakdown.)

### Notes
- See Epic NFR: performance < 10s p95 for reports under 500 rows.
- See Epic constraint: must use existing auth middleware.

---

[Continue for each story...]

---

## Story Readiness Assessment

### INVEST Compliance
| Story | Type | Independent | Negotiable | Valuable | Estimable | Small | Testable |
|-------|------|-------------|------------|----------|-----------|-------|----------|
| 0 | spike | Y | Y | Y | Y | Y | Y |
| 1 | user | Y | Y | Y | Y | Y | Y |
| ... | ... | ... | ... | ... | ... | ... | ... |

### Coverage Check
- [ ] All Epic ACs covered by at least one user story
- [ ] All Epic constraints/dependencies have technical or spike stories if needed
- [ ] No stories cover scope outside Epic ACs
- [ ] NFRs referenced by applicable stories

### Sizing Check
- [ ] All stories sized S, M, or L
- [ ] No story exceeds 3 days for a single developer
- [ ] All stories have task breakdowns
- [ ] All tasks are specific enough for an AI agent to execute

### AI-Parallelization Check
- [ ] All M and L stories have parallelization assessments
- [ ] Parallelizable stories have defined shared contracts
- [ ] Parallel tracks have clear merge strategies

### Dependency Check
- [ ] No circular dependencies
- [ ] Critical path identified
- [ ] Execution sequence defines parallel waves and sequential gates
- [ ] Every story has a "Parallelizable with" or "sequential" annotation
- [ ] Sprint assignments respect wave ordering

### Epic Back-Link Check
- [ ] Every story includes an "Epic: [title]" back-link field
- [ ] Every story's "Epic ACs covered" field traces to a real Epic AC
- [ ] Technical/spike stories trace to Epic constraints or dependencies

### Traceability Check
- [ ] All user stories trace to at least one Epic AC
- [ ] All technical/spike stories trace to Epic constraints or dependencies
- [ ] Source material referenced in traceability table per story

### Feature Flag / Rollback Check
- [ ] Stories modifying existing behavior have feature flags
- [ ] All stories have a rollback approach (even if "N/A — additive only")

### Readiness Level
Draft | Needs Revision | Ready for Implementation