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

Generate a complete AI assistant harness for a TypeScript/React + Python/FastAPI project.

## Phase 1 — Discovery

Probe the project silently:

```bash
# Project name
jq -r '.name' package.json 2>/dev/null || \
  grep -m1 '^name' pyproject.toml 2>/dev/null | cut -d= -f2 | tr -d ' "' || \
  basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# Backend
python3 --version
cat pyproject.toml 2>/dev/null | grep -i fastapi

# Frontend
cat package.json 2>/dev/null | jq '{react: .dependencies.react, typescript: .devDependencies.typescript, vite: .devDependencies.vite}'

# State manager
grep -rn "zustand\|redux\|mobx" package.json src/ 2>/dev/null | head -3

# Database
ls supabase/config.toml 2>/dev/null && echo "supabase"

# Package managers
ls uv.lock 2>/dev/null && echo "uv"
ls package-lock.json 2>/dev/null && echo "npm"

# Tests
ls vitest.config.* 2>/dev/null && echo "vitest"
ls playwright.config.* 2>/dev/null && echo "playwright"

# UI
grep -n "shadcn\|tailwind" package.json 2>/dev/null | head -3

# Special infra
grep -rn "mlflow\|langgraph\|langchain" pyproject.toml backend/ 2>/dev/null | head -3
```

## Phase 2 — Interview

Present discovery summary. Ask only unresolved questions:

- Project domain? (e.g., "SaaS analytics", "social media")
- Custom compliance rules? (GDPR, HIPAA, SOC2)
- Confirm coverage tiers?

## Phase 3 — Render

```bash
bash templates/scripts/bootstrap.sh \
  --project-name "${PROJECT_NAME}" \
  --project-slug "${PROJECT_SLUG}" \
  --backend-path "${BACKEND_PATH}" \
  --frontend-path "${FRONTEND_PATH}" \
  --db-provider "${DB_PROVIDER}" \
  --state-manager "${STATE_MANAGER}" \
  --python-version "${PYTHON_VERSION}" \
  --fastapi-version "${FASTAPI_VERSION}" \
  --react-version "${REACT_VERSION}" \
  --typescript-version "${TYPESCRIPT_VERSION}" \
  --vite-version "${VITE_VERSION}" \
  --pkg-manager-backend "${PKG_MANAGER_BACKEND}" \
  --pkg-manager-frontend "${PKG_MANAGER_FRONTEND}" \
  --coverage-aggregate-backend "${COVERAGE_AGGREGATE_BACKEND}" \
  --coverage-aggregate-frontend "${COVERAGE_AGGREGATE_FRONTEND}" \
  --calver-version "$(date +%Y.%m.%d)" \
  --article-i-services "${ARTICLE_I_SERVICES}" \
  --frontend-stores "${FRONTEND_STORES}" \
  --db-extensions "${DB_EXTENSIONS}" \
  --has-mlflow "${HAS_MLFLOW}" \
  --has-langgraph "${HAS_LANGGRAPH}" \
  --cicd-platform "${CICD_PLATFORM}" \
  --e2e-tool "${E2E_TOOL}" \
  --ui-library "${UI_LIBRARY}" \
  --tailwind "${TAILWIND}" \
  --zod-validation "${ZOD_VALIDATION}" \
  --custom-instructions "${CUSTOM_INSTRUCTIONS}" \
  --custom-tech-stack "${CUSTOM_TECH_STACK}" \
  --output-dir "${OUTPUT_DIR}"
```

## Phase 4 — Validation

```bash
grep -ro '{{[A-Z_]*}}' "${OUTPUT_DIR}" | wc -l   # must be 0
python3 templates/scripts/generate-copilot-mirrors.py "${OUTPUT_DIR}"
find "${OUTPUT_DIR}/.claude/hooks" -name '*.sh' -exec bash -n {} \;
test -f "${OUTPUT_DIR}/CLAUDE.md"
test -f "${OUTPUT_DIR}/AGENTS.md"
test -f "${OUTPUT_DIR}/.github/copilot-instructions.md"
test -d "${OUTPUT_DIR}/.claude/rules/backend"
test -d "${OUTPUT_DIR}/.opencode/skills"
```

## Rules

- Never overwrite existing files without asking.
- Use defaults for blank answers.
- Be concise — only ask genuinely ambiguous questions.
- The bootstrap script handles both placeholder substitution and conditional block processing (`{{#FLAG}}...{{/FLAG}}` strips when flag is `no`).
