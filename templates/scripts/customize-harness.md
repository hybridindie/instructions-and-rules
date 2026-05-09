# AI Harness Customization Skill

## Purpose

Semantically tailor the constitutional template system to a specific project. Unlike the bootstrap script (which only does string substitution), this skill:

1. Removes irrelevant articles based on project needs
2. Adjusts coverage tiers based on criticality
3. Rewrites example library/service names to match the domain
4. Adds custom rules blocks for special infrastructure
5. Suggests additional agents, hooks, or skills
6. Outputs a fully rendered, project-specific harness

## Invocation

```bash
# As a skill prompt
/customize-harness \
  --project-name "NomikaiList" \
  --project-slug "nomikailist" \
  --domain "anime & manga discovery with AI recommendations" \
  --backend-path "backend" \
  --frontend-path "frontend" \
  --db-provider "supabase" \
  --state-manager "zustand" \
  --special-infra "langgraph, supabase-auth" \
  --tier-adjustments "security:90, business:68, ml:50" \
  --custom-rules "GDPR-first privacy, Anime genre ontology, Explainable AI" \
  --output-dir "../nomikailist"
```

## Steps

### Step 1: Read Templates

Load all template files from `templates/`:
- `_shared/articles/*.md` — Constitutional Articles I–IX
- `_shared/database/*.md` — SQL standards and infrastructure
- `_shared/frontend/*.md` — Frontend conventions
- `github-copilot/.github/*` — Copilot harness
- `claude-code/.claude/*` — Claude harness
- `opencode/.opencode/*` — Opencode harness

### Step 2: Determine Relevance Matrix

Based on `--special-infra` and `--domain`, decide which articles to keep, trim, or expand:

| Flag | Effect |
|------|--------|
| `mlflow` | Keep MLflow Prompt Registry section in architecture.md |
| `langgraph` | Add LangGraph agent development section; keep ML tier at 50%+ |
| `supabase-auth` | Expand security.md JWT/RLS sections |
| `gdpr` | Add privacy article (data retention, right-to-deletion) |
| `payments` | Set revenue-critical tier to 85%+ |
| `realtime` | Expand LISTEN/NOTIFY and websocket sections |
| `mobile-app` | Add React Native / Capacitor frontend variant |

Articles to **remove** if not applicable:
- MLflow section → if no `mlflow` flag
- LangGraph section → if no `langgraph` flag
- Mobile-specific rules → if no `mobile-app` flag
- Payment-specific rules → if no `payments` flag

### Step 3: Adjust Coverage Tiers

Parse `--tier-adjustments` and rewrite the coverage table in `testing.md`:

```markdown
| Component Type | Minimum |
|----------------|---------|
| Security-critical | 90%+ |
| Revenue-critical | {{REVENUE_TIER}}%+ |
| Business logic | {{BUSINESS_TIER}}%+ |
| AI/ML services | {{ML_TIER}}%+ |
| Utilities & helpers | 50%+ |
```

### Step 4: Domain-Specific Examples

Replace generic example names with domain-appropriate ones:

| Generic | Anime Domain | Finance Domain |
|---------|--------------|----------------|
| `auth_manager` | `user_manager` | `account_manager` |
| `analytics_engine` | `recommendation_engine` | `risk_engine` |
| `content_manager` | `anime_catalog_manager` | `portfolio_manager` |
| `auth, analytics, content` | `auth, catalog, recommendations` | `auth, portfolio, trading` |

### Step 5: Custom Rules Block

Append `--custom-rules` as a new section in:
- `copilot-instructions.md` → Section 20: Custom Rules
- `CLAUDE.md` → Under "Project" → "Custom Rules"
- `AGENTS.md` → Under "Final Principle"

Format:
```markdown
## Custom Rules (Project-Specific)

- GDPR-first privacy: all user data paths auditable, deletable within 30 days
- Anime genre ontology: use canonical genre IDs from AniDB/MAL; no free-text genres
- Explainable AI: every recommendation must include reasoning trace
```

### Step 6: Suggest Additional Agents/Skills

Based on domain, suggest new files:

| Domain | Suggested Agent | Suggested Skill |
|--------|-----------------|-----------------|
| Anime/Manga | `anime-catalog-reviewer.agent.md` | `anime-ontology-validator` |
| Finance | `compliance-reviewer.agent.md` | `audit-trail-generator` |
| Healthcare | `hipaa-compliance-reviewer.agent.md` | `phi-scanner` |
| E-commerce | `inventory-sync-reviewer.agent.md` | `order-flow-test-generator` |

If suggested, generate skeleton files in the appropriate harness directory.

### Step 7: Render Output

For each of the three harnesses (Copilot, Claude, Opencode):
1. Substitute all `{{PLACEHOLDER}}` values
2. Remove conditional blocks (`{{#FLAG}}...{{/FLAG}}`) that don't match
3. Insert custom rules block
4. Write to `--output-dir`

### Step 8: Post-Render Validation

Run these checks on the rendered output:
1. **Mirror sync**: Every `.claude/rules/*.md` has a matching `.github/instructions/*.instructions.md` with identical body
2. **Path consistency**: All `paths:` frontmatter entries use the rendered `{{BACKEND_PATH}}` and `{{FRONTEND_PATH}}`
3. **No orphaned placeholders**: `grep -r '{{[A-Z_]*}}' output/` must be empty (except intentional examples in comments)
4. **Hook executability**: All `.sh` files have `#!/bin/bash` and `set -euo pipefail`

## Output

Report:
```
=== Harness Customization Complete ===
Project: {{PROJECT_NAME}}
Domain: {{DOMAIN}}
Output: {{OUTPUT_DIR}}

Articles kept: I, II, III, IV, V, VI, VII, VIII, IX
Sections removed: MLflow Prompt Registry (no mlflow flag)
Coverage tiers: Security 90%, Business {{BUSINESS_TIER}}%, ML {{ML_TIER}}%
Custom rules: 3 items added
Suggested agents: {{AGENT_LIST}}
Suggested skills: {{SKILL_LIST}}

Next steps:
  1. cd {{OUTPUT_DIR}}
  2. Review rendered files
  3. Run: bash .claude/hooks/check-primitive-drift.sh
  4. Commit harness
```

## Rules

- Never remove Articles I–IX entirely — they are constitutional.
- Only remove optional sub-sections (MLflow, LangGraph, mobile variants).
- Always preserve the enforcement.md PR checklist unchanged.
- Always preserve the error-handling.md DomainError mapping unchanged.
- If `--tier-adjustments` lowers a tier below project risk, emit a WARNING.
