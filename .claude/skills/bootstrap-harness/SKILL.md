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

This skill:
1. **Probes** the project to discover its tech stack automatically.
2. **Interviews** the user about anything it can't infer.
3. **Renders** templates from `templates/` into the target directory.
4. **Auto-mirrors** Claude rules to Copilot instructions.
5. **Validates** the output (zero orphaned placeholders, executable hooks).

## Phase 1 — Discovery

Run these probes silently (don't show the user the raw output, just record findings).

### 1.1 Determine project name and slug

```bash
# Try package.json, pyproject.toml, or git remote
jq -r '.name' package.json 2>/dev/null || \
  grep -m1 '^name' pyproject.toml 2>/dev/null | cut -d= -f2 | tr -d ' "' || \
  basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
```

- Record as `PROJECT_NAME` (human-readable) and `PROJECT_SLUG` (URL-safe, from basename or package name).

### 1.2 Determine backend framework and Python version

```bash
# Check pyproject.toml, requirements.txt, setup.py
cat pyproject.toml 2>/dev/null | grep -i 'fastapi\|flask\|django\|dependencies'
python3 --version 2>/dev/null || python --version
```

- If `pyproject.toml` mentions `fastapi`, set `FRAMEWORK=fastapi`.
- If `requirements.txt` exists, grep for framework name.
- Python version: extract minor (e.g., `3.12`).

### 1.3 Determine frontend framework and versions

```bash
cat package.json 2>/dev/null | jq '{react: .dependencies.react, typescript: .devDependencies.typescript, vite: .devDependencies.vite}'
```

- Extract React, TypeScript, Vite versions.
- If `next` is in dependencies, note: "Next.js detected — confirm if this should use Next.js conventions instead of Vite."

### 1.4 Determine state manager

```bash
grep -rn "zustand\|redux\|mobx\|recoil\|jotai" package.json src/ 2>/dev/null | head -5
```

- If multiple found, note all and ask user to confirm.

### 1.5 Determine database provider

```bash
# Check for Supabase config, SQLAlchemy, Prisma, etc.
ls supabase/config.toml 2>/dev/null && echo "supabase"
grep -rn "supabase\|sqlalchemy\|prisma\|psycopg" pyproject.toml backend/ 2>/dev/null | head -5
```

- If `supabase/config.toml` exists → `supabase`.
- If `psycopg` or `sqlalchemy` → `postgres` (warn: SQLAlchemy is discouraged by the constitutional template).

### 1.6 Determine package managers

```bash
ls uv.lock 2>/dev/null && echo "uv"
ls package-lock.json 2>/dev/null && echo "npm"
ls yarn.lock 2>/dev/null && echo "yarn"
ls pnpm-lock.yaml 2>/dev/null && echo "pnpm"
```

### 1.7 Determine test runners

```bash
grep -n "vitest\|jest\|playwright\|cypress" package.json 2>/dev/null
ls vitest.config.* 2>/dev/null && echo "vitest"
ls playwright.config.* 2>/dev/null && echo "playwright"
```

### 1.8 Determine UI library

```bash
grep -n "shadcn\|tailwind\|mui\|antd\|chakra" package.json 2>/dev/null | head -5
```

### 1.9 Check for special infrastructure

```bash
grep -rn "mlflow\|langgraph\|langchain\|celery\|redis" pyproject.toml backend/ 2>/dev/null | head -5
```

- If `mlflow` found → set `HAS_MLFLOW=yes`.
- If `langgraph` or `langchain` found → set `HAS_LANGGRAPH=yes`.

### 1.10 Determine backend/frontend paths

```bash
ls backend/src/ frontend/src/ 2>/dev/null && echo "backend frontend"
ls src/ app/ 2>/dev/null && echo "monorepo or nested"
```

- If `backend/` and `frontend/` exist separately → use those.
- If only `src/` exists → ask: "Is this a monorepo or single-stack project?"

---

## Phase 2 — Interview

Present a concise summary of what was discovered, then ask only the **unresolved** questions.

**Example output to user:**

```
🔍 Discovery Results
━━━━━━━━━━━━━━━━━━
Project:      MyProject (slug: myproject)
Backend:      Python 3.12 + FastAPI (uv)
Frontend:     React 19 + TypeScript 5.9 + Vite 7.3 (npm)
State:        zustand (detected in package.json)
Database:     supabase (config.toml found)
Tests:        vitest + playwright
UI:           shadcn/ui + tailwind
Special:      langgraph detected

❓ Unresolved
1. What is the project domain? (e.g., "SaaS analytics", "social media", "e-commerce")
2. Any custom compliance rules? (GDPR, HIPAA, SOC2, etc.)
3. Confirm coverage tiers — current defaults:
   - Security-critical: 90%
   - Business logic: 70%
   - AI/ML: 50%
```

**Only ask questions the probes couldn't answer.** If the probes were fully conclusive, skip to Phase 3.

---

## Phase 3 — Render

```bash
bash templates/scripts/bootstrap.sh \
  --project-name "${PROJECT_NAME}" \
  ...
  --has-mlflow "${HAS_MLFLOW}" \
  --has-langgraph "${HAS_LANGGRAPH}" \
  --tailwind "${TAILWIND}" \
  --zod-validation "${ZOD_VALIDATION}" \
  --custom-instructions "${CUSTOM_INSTRUCTIONS}" \
  --custom-tech-stack "${CUSTOM_TECH_STACK}" \
  --output-dir "${OUTPUT_DIR}"
```

The script performs placeholder substitution, then runs `process-conditionals.py` to strip `{{#FLAG}}...{{/FLAG}}` blocks when a flag is `no`.

**If any `--arg` is empty**, omit it entirely (let the script use defaults).

---

## Phase 4 — Validation

After rendering, run these checks:

1. **Zero orphaned placeholders**
   ```bash
   grep -ro '{{[A-Z_]*}}' "${OUTPUT_DIR}" | wc -l
   ```
   Must be `0`. If not, list the files and the missing substitutions — this is a bug in the skill or template.

2. **Mirror sync**
   ```bash
   python3 templates/scripts/generate-copilot-mirrors.py "${OUTPUT_DIR}"
   ```
   Verify that `.github/instructions/*.instructions.md` files exist and have Copilot frontmatter.

3. **Hook executability**
   ```bash
   find "${OUTPUT_DIR}/.claude/hooks" -name '*.sh' -exec bash -n {} \;
   ```
   Must parse without syntax errors.

4. **Key files present**
   ```bash
   test -f "${OUTPUT_DIR}/CLAUDE.md"
   test -f "${OUTPUT_DIR}/AGENTS.md"
   test -f "${OUTPUT_DIR}/.github/copilot-instructions.md"
   test -d "${OUTPUT_DIR}/.claude/rules/backend"
   test -d "${OUTPUT_DIR}/.opencode/skills"
   ```

---

## Phase 5 — Report

Present a clean summary:

```
✅ Harness Generated for MyProject
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Output:  ./.claude/  ./.github/  ./.opencode/  CLAUDE.md  AGENTS.md

Files:   53 files rendered
Mirrors: 12 Copilot instructions auto-generated
Checks:  ✅ Zero placeholders  ✅ Hooks valid  ✅ Mirrors synced

📋 Next Steps
1. Review .github/copilot-instructions.md for project-specific tweaks
2. Edit CLAUDE.md "Project" section with your domain description
3. Run: bash .claude/hooks/check-primitive-drift.sh
4. Commit the harness: git add .claude/ .github/ .opencode/ CLAUDE.md AGENTS.md
```

---

## Rules

- **Never overwrite existing files** without asking the user first. If a file already exists (e.g., `CLAUDE.md`), show a diff and ask for confirmation.
- **Use defaults** for anything the user leaves blank. The defaults are tuned for a standard TS/React + Python/FastAPI + Supabase + Zustand stack.
- **Be concise** in the interview — only ask genuinely ambiguous questions.
- **If the user says "just use defaults,"** skip Phase 2 entirely and render immediately.
