---
name: bootstrap-harness
description: Scan a project, interview the user about unknowns, and generate a complete AI harness (Copilot + Claude + Opencode) with Constitutional Articles I–IX
user-invocable: true
disable-model-invocation: true
arguments:
  - name: output-dir
    description: "Directory to write the harness into (default: current directory)"
    required: false
---

# Bootstrap Harness

Generate a complete AI assistant harness for any Python/TypeScript project.

This skill:
1. **Introspects** the project using `inspect-project.py` to auto-detect stack, mode, and profile.
2. **Interviews** the user about anything the probes can't infer.
3. **Renders** templates from `templates/` into the target directory.
4. **Auto-mirrors** Claude rules to Copilot instructions.
5. **Validates** the output (zero orphaned placeholders, executable hooks, cross-harness sync).

Supports:
- Full-stack (FastAPI + React)
- Backend-only (FastAPI / MCP / Django / Flask)
- Future: frontend-only, micro-library

## Phase 1 — Project Introspection

Run the unified inspector on the project root. Do NOT show raw JSON to the user.

```bash
python3 templates/scripts/inspect-project.py "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
```

This single command returns a JSON blob with everything inferable:
- `mode`: `full` | `backend-only`
- `profile`: `fastapi` | `mcp` | `django` | `flask` | `generic-python`
- `project_name`, `project_slug`
- Python / FastAPI / React / TypeScript / Vite versions
- `db_provider`, `state_manager`, `pkg_manager_backend`
- `has_mlflow`, `has_langgraph`, `tailwind`, `zod_validation`
- `cicd_platform`, `e2e_tool`, `confidence`

If confidence is `medium`, ask about the ambiguous items. If `high`, proceed.

---

## Phase 2 — Interview (Unanswered Only)

Present a concise summary of discovered values, then ask only **genuinely unresolved** questions.

**Example output to user:**

```
🔍 Discovery Results
━━━━━━━━━━━━━━━━━━
Project:      Weather MCP (slug: weather-mcp)
Mode:         backend-only
Profile:      mcp (detected via pyproject.toml deps)
Python:       3.12 (uv)
Backend:      MCP server (no FastAPI)
Tests:        pytest
CI:           github-actions

❓ Unresolved
1. What is the project domain? (e.g., "weather data", "analytics", "content management")
2. Custom compliance rules? (GDPR, HIPAA, SOC2, etc.)
3. Coverage tiers confirm — default for backend-only: security 90%, business 70%, utils 50%
```

**Only ask what inspect-project.py didn't already resolve.**

---

## Phase 3 — Render (Two Paths)

### Path A: Auto-detect (Recommended)

```bash
bash templates/scripts/bootstrap.sh \
  --auto-detect \
  --output-dir "${OUTPUT_DIR}"
```

This consumes the inspector JSON directly, sets mode/profile, skips frontend rendering when appropriate, and suppresses irrelevant placeholders automatically.

### Path B: Manual Override

If the user overrides any detected values, use:

```bash
bash templates/scripts/bootstrap.sh \
  --project-name "${PROJECT_NAME}" \
  --project-slug "${PROJECT_SLUG}" \
  --python-version "${PYTHON_VERSION}" \
  --mode "${MODE}" \
  --profile "${PROFILE}" \
  --db-provider "${DB_PROVIDER}" \
  --has-mlflow "${HAS_MLFLOW}" \
  --has-langgraph "${HAS_LANGGRAPH}" \
  --custom-instructions "${CUSTOM_INSTRUCTIONS}" \
  --custom-tech-stack "${CUSTOM_TECH_STACK}" \
  --output-dir "${OUTPUT_DIR}"
```

The script performs placeholder substitution, overlays profile-specific files (e.g. `profiles/mcp/overlays/backend/architecture.md`), then runs `process-conditionals.py` to strip irrelevant blocks.

---

## Phase 4 — Validation

After rendering, run these checks:

1. **Zero orphaned placeholders**
   ```bash
   grep -ro '{{[A-Z_]*}}' "${OUTPUT_DIR}" | wc -l
   ```
   Must be `0`.

2. **Mirror sync**
   ```bash
   python3 templates/scripts/generate-copilot-mirrors.py "${OUTPUT_DIR}"
   ```

3. **Hook executability**
   ```bash
   find "${OUTPUT_DIR}/.claude/hooks" -name '*.sh' -exec bash -n {} \;
   ```

4. **Cross-harness sync**
   ```bash
   python3 templates/scripts/check-harness-sync.py templates "${OUTPUT_DIR}"
   ```

5. **Key files present**
   ```bash
   test -f "${OUTPUT_DIR}/CLAUDE.md"
   test -f "${OUTPUT_DIR}/AGENTS.md"
   test -f "${OUTPUT_DIR}/.github/copilot-instructions.md"
   test -d "${OUTPUT_DIR}/.claude/rules"
   test -d "${OUTPUT_DIR}/.opencode/skills"
   ```

---

## Phase 5 — Report

```
✅ Harness Generated for ${PROJECT_NAME}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Mode:    ${MODE}  (profile: ${PROFILE})
Output:  ./.claude/  ./.github/  ./.opencode/  CLAUDE.md  AGENTS.md
Files:   $(find "${OUTPUT_DIR}" -type f | wc -l) rendered
Mirrors: $(find "${OUTPUT_DIR}/.github/instructions" -type f 2>/dev/null | wc -l) Copilot instructions
Checks:  ✅ Placeholders  ✅ Hooks  ✅ Mirrors  ✅ Cross-harness

📋 Next Steps
1. Review .github/copilot-instructions.md for project-specific tweaks
2. Edit CLAUDE.md "Project" section with your domain description
3. Run: bash .claude/hooks/check-primitive-drift.sh
4. Commit the harness: git add .claude/ .github/ .opencode/ CLAUDE.md AGENTS.md
```

---

## Rules

- **Never overwrite existing files** without asking the user first.
- **Use defaults** for anything the user leaves blank.
- **Be concise** in the interview — only ask genuinely ambiguous questions.
- **If the user says "just use defaults,"** skip Phase 2 entirely and render immediately.
- **Mode `backend-only`** suppresses all frontend rules, placeholders, and hooks automatically.
- **Profile `mcp`** replaces FastAPI architecture overlays with MCP server guidance.
