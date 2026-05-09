#!/bin/bash
set -euo pipefail

# Harness Bootstrap Script
# Renders AI assistant harness templates for a new project.
#
# Usage:
#   bash templates/scripts/bootstrap.sh \
#     --project-name "MyProject" \
#     --project-slug "myproject" \
#     --output-dir "../myproject"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$(dirname "$SCRIPT_DIR")"

PROJECT_NAME=""
PROJECT_SLUG=""
BACKEND_PATH="backend"
FRONTEND_PATH="frontend"
REPO_ORG=""
REPO_NAME=""
DB_PROVIDER="supabase"
STATE_MANAGER="zustand"
PYTHON_VERSION="3.12"
FASTAPI_VERSION="0.119+"
REACT_VERSION="19"
TYPESCRIPT_VERSION="5.9"
VITE_VERSION="7.3"
PKG_MANAGER_BACKEND="uv"
PKG_MANAGER_FRONTEND="npm"
COVERAGE_AGGREGATE_BACKEND="70"
COVERAGE_AGGREGATE_FRONTEND="60"
CALVER_VERSION=""
ARTICLE_I_SERVICE_EXAMPLES="auth_manager, analytics_engine, content_manager"
FRONTEND_STORE_EXAMPLES="auth, analytics, content"
DB_EXTENSIONS="pgvector, pgmq, HSTORE"
HAS_MLFLOW="no"
HAS_LANGGRAPH="no"
CICD_PLATFORM="github-actions"
E2E_TOOL="playwright"
UI_LIBRARY="shadcn/ui"
TAILWIND="yes"
ZOD_VALIDATION="yes"
CUSTOM_INSTRUCTIONS=""
CUSTOM_TECH_STACK=""
OUTPUT_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-name) PROJECT_NAME="$2"; shift 2 ;;
    --project-slug) PROJECT_SLUG="$2"; shift 2 ;;
    --backend-path) BACKEND_PATH="$2"; shift 2 ;;
    --frontend-path) FRONTEND_PATH="$2"; shift 2 ;;
    --repo-org) REPO_ORG="$2"; shift 2 ;;
    --repo-name) REPO_NAME="$2"; shift 2 ;;
    --db-provider) DB_PROVIDER="$2"; shift 2 ;;
    --state-manager) STATE_MANAGER="$2"; shift 2 ;;
    --python-version) PYTHON_VERSION="$2"; shift 2 ;;
    --fastapi-version) FASTAPI_VERSION="$2"; shift 2 ;;
    --react-version) REACT_VERSION="$2"; shift 2 ;;
    --typescript-version) TYPESCRIPT_VERSION="$2"; shift 2 ;;
    --vite-version) VITE_VERSION="$2"; shift 2 ;;
    --pkg-manager-backend) PKG_MANAGER_BACKEND="$2"; shift 2 ;;
    --pkg-manager-frontend) PKG_MANAGER_FRONTEND="$2"; shift 2 ;;
    --coverage-aggregate-backend) COVERAGE_AGGREGATE_BACKEND="$2"; shift 2 ;;
    --coverage-aggregate-frontend) COVERAGE_AGGREGATE_FRONTEND="$2"; shift 2 ;;
    --calver-version) CALVER_VERSION="$2"; shift 2 ;;
    --article-i-services) ARTICLE_I_SERVICE_EXAMPLES="$2"; shift 2 ;;
    --frontend-stores) FRONTEND_STORE_EXAMPLES="$2"; shift 2 ;;
    --db-extensions) DB_EXTENSIONS="$2"; shift 2 ;;
    --has-mlflow) HAS_MLFLOW="$2"; shift 2 ;;
    --has-langgraph) HAS_LANGGRAPH="$2"; shift 2 ;;
    --cicd-platform) CICD_PLATFORM="$2"; shift 2 ;;
    --e2e-tool) E2E_TOOL="$2"; shift 2 ;;
    --ui-library) UI_LIBRARY="$2"; shift 2 ;;
    --tailwind) TAILWIND="$2"; shift 2 ;;
    --zod-validation) ZOD_VALIDATION="$2"; shift 2 ;;
    --custom-instructions) CUSTOM_INSTRUCTIONS="$2"; shift 2 ;;
    --custom-tech-stack) CUSTOM_TECH_STACK="$2"; shift 2 ;;
    --output-dir) OUTPUT_DIR="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ -z "$PROJECT_NAME" || -z "$PROJECT_SLUG" || -z "$OUTPUT_DIR" ]]; then
  echo "Usage: $0 --project-name <name> --project-slug <slug> --output-dir <dir> [options]"
  exit 1
fi

if [[ -z "$REPO_ORG" ]]; then REPO_ORG="$PROJECT_SLUG"; fi
if [[ -z "$REPO_NAME" ]]; then REPO_NAME="$PROJECT_SLUG"; fi
if [[ -z "$CALVER_VERSION" ]]; then CALVER_VERSION="$(date +%Y.%m.%d)"; fi

if [[ "$PKG_MANAGER_BACKEND" == "uv" ]]; then
  TEST_BACKEND_CMD="uv run pytest"
  LINT_BACKEND_CMD="uv run ruff check ."
  TYPE_BACKEND_CMD="uv run mypy src/"
else
  TEST_BACKEND_CMD="pytest"
  LINT_BACKEND_CMD="ruff check ."
  TYPE_BACKEND_CMD="mypy src/"
fi

if [[ "$PKG_MANAGER_FRONTEND" == "npm" ]]; then
  TEST_FRONTEND_CMD="npx vitest run"
  LINT_FRONTEND_CMD="npm run lint"
  TYPE_FRONTEND_CMD="npm run type-check"
else
  TEST_FRONTEND_CMD="vitest run"
  LINT_FRONTEND_CMD="npm run lint"
  TYPE_FRONTEND_CMD="npm run type-check"
fi

substitute_placeholders() {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"
  sed \
    -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
    -e "s|{{PROJECT_SLUG}}|$PROJECT_SLUG|g" \
    -e "s|{{BACKEND_PATH}}|$BACKEND_PATH|g" \
    -e "s|{{FRONTEND_PATH}}|$FRONTEND_PATH|g" \
    -e "s|{{REPO_ORG}}|$REPO_ORG|g" \
    -e "s|{{REPO_NAME}}|$REPO_NAME|g" \
    -e "s|{{PYTHON_VERSION}}|$PYTHON_VERSION|g" \
    -e "s|{{FASTAPI_VERSION}}|$FASTAPI_VERSION|g" \
    -e "s|{{REACT_VERSION}}|$REACT_VERSION|g" \
    -e "s|{{TYPESCRIPT_VERSION}}|$TYPESCRIPT_VERSION|g" \
    -e "s|{{VITE_VERSION}}|$VITE_VERSION|g" \
    -e "s|{{DB_PROVIDER}}|$DB_PROVIDER|g" \
    -e "s|{{STATE_MANAGER}}|$STATE_MANAGER|g" \
    -e "s|{{TEST_BACKEND_CMD}}|$TEST_BACKEND_CMD|g" \
    -e "s|{{TEST_FRONTEND_CMD}}|$TEST_FRONTEND_CMD|g" \
    -e "s|{{LINT_BACKEND_CMD}}|$LINT_BACKEND_CMD|g" \
    -e "s|{{LINT_FRONTEND_CMD}}|$LINT_FRONTEND_CMD|g" \
    -e "s|{{TYPE_BACKEND_CMD}}|$TYPE_BACKEND_CMD|g" \
    -e "s|{{TYPE_FRONTEND_CMD}}|$TYPE_FRONTEND_CMD|g" \
    -e "s|{{PKG_MANAGER_BACKEND}}|$PKG_MANAGER_BACKEND|g" \
    -e "s|{{PKG_MANAGER_FRONTEND}}|$PKG_MANAGER_FRONTEND|g" \
    -e "s|{{COVERAGE_AGGREGATE_BACKEND}}|$COVERAGE_AGGREGATE_BACKEND|g" \
    -e "s|{{COVERAGE_AGGREGATE_FRONTEND}}|$COVERAGE_AGGREGATE_FRONTEND|g" \
    -e "s|{{CALVER_VERSION}}|$CALVER_VERSION|g" \
    -e "s|{{ARTICLE_I_SERVICE_EXAMPLES}}|$ARTICLE_I_SERVICE_EXAMPLES|g" \
    -e "s|{{FRONTEND_STORE_EXAMPLES}}|$FRONTEND_STORE_EXAMPLES|g" \
    -e "s|{{DB_EXTENSIONS}}|$DB_EXTENSIONS|g" \
    -e "s|{{HAS_MLFLOW}}|$HAS_MLFLOW|g" \
    -e "s|{{HAS_LANGGRAPH}}|$HAS_LANGGRAPH|g" \
    -e "s|{{CICD_PLATFORM}}|$CICD_PLATFORM|g" \
    -e "s|{{E2E_TOOL}}|$E2E_TOOL|g" \
    -e "s|{{UI_LIBRARY}}|$UI_LIBRARY|g" \
    -e "s|{{TAILWIND}}|$TAILWIND|g" \
    -e "s|{{ZOD_VALIDATION}}|$ZOD_VALIDATION|g" \
    -e "s|{{CUSTOM_INSTRUCTIONS}}|$CUSTOM_INSTRUCTIONS|g" \
    -e "s|{{CUSTOM_TECH_STACK}}|$CUSTOM_TECH_STACK|g" \
    "$src" > "$dst"
}

render_harness() {
  local harness_dir="$1"
  local target_dir="$2"
  echo "Rendering $harness_dir -> $target_dir"
  find "$harness_dir" -type f | while read -r src; do
    rel="${src#$harness_dir/}"
    dst="$target_dir/$rel"
    substitute_placeholders "$src" "$dst"
  done
}

mkdir -p "$OUTPUT_DIR"

echo "=== Rendering Shared Articles ==="
for shared in "$TEMPLATES_DIR/_shared/articles/"*.md; do
  [[ -f "$shared" ]] || continue
  fname=$(basename "$shared")
  case "$fname" in
    architecture.md)        dst_dir="$OUTPUT_DIR/.claude/rules/backend" ;;
    testing.md)             dst_dir="$OUTPUT_DIR/.claude/rules/backend" ;;
    error-handling.md)      dst_dir="$OUTPUT_DIR/.claude/rules/backend" ;;
    async-patterns.md)      dst_dir="$OUTPUT_DIR/.claude/rules/backend" ;;
    api-design.md)          dst_dir="$OUTPUT_DIR/.claude/rules/backend" ;;
    security.md)            dst_dir="$OUTPUT_DIR/.claude/rules/backend" ;;
    cicd.md)                dst_dir="$OUTPUT_DIR/.claude/rules" ;;
    enforcement.md)         dst_dir="$OUTPUT_DIR/.claude/rules" ;;
    primitive-drift.md)     dst_dir="$OUTPUT_DIR/.github/instructions" ;;
    *) echo "Unhandled shared article: $fname"; continue ;;
  esac
  substitute_placeholders "$shared" "$dst_dir/$fname"
done

for shared in "$TEMPLATES_DIR/_shared/database/"*.md; do
  [[ -f "$shared" ]] || continue
  fname=$(basename "$shared")
  case "$fname" in
    sql-standards.md)       dst_dir="$OUTPUT_DIR/.claude/rules/database" ;;
    infrastructure.md)      dst_dir="$OUTPUT_DIR/.claude/rules/database" ;;
    *) echo "Unhandled shared database: $fname"; continue ;;
  esac
  substitute_placeholders "$shared" "$dst_dir/$fname"
done

for shared in "$TEMPLATES_DIR/_shared/frontend/"*.md; do
  [[ -f "$shared" ]] || continue
  fname=$(basename "$shared")
  case "$fname" in
    conventions.md)         dst_dir="$OUTPUT_DIR/.claude/rules/frontend" ;;
    *) echo "Unhandled shared frontend: $fname"; continue ;;
  esac
  substitute_placeholders "$shared" "$dst_dir/$fname"
done

echo "=== Mirroring Claude Rules to Copilot Instructions ==="
python3 "$SCRIPT_DIR/generate-copilot-mirrors.py" "$OUTPUT_DIR"

echo "=== Rendering GitHub Copilot Harness ==="
render_harness "$TEMPLATES_DIR/github-copilot/.github" "$OUTPUT_DIR/.github"

echo "=== Rendering Claude Code Harness ==="
render_harness "$TEMPLATES_DIR/claude-code/.claude" "$OUTPUT_DIR/.claude"
substitute_placeholders "$TEMPLATES_DIR/claude-code/CLAUDE.md" "$OUTPUT_DIR/CLAUDE.md"
substitute_placeholders "$TEMPLATES_DIR/claude-code/AGENTS.md" "$OUTPUT_DIR/AGENTS.md"

echo "=== Rendering Opencode Harness ==="
render_harness "$TEMPLATES_DIR/opencode/.opencode" "$OUTPUT_DIR/.opencode"

echo "=== Processing Conditional Blocks ==="
python3 "$SCRIPT_DIR/process-conditionals.py" "$OUTPUT_DIR" \
  "HAS_MLFLOW=$HAS_MLFLOW" \
  "HAS_LANGGRAPH=$HAS_LANGGRAPH" \
  "TAILWIND=$TAILWIND" \
  "ZOD_VALIDATION=$ZOD_VALIDATION"

echo ""
echo "=== Bootstrap Complete ==="
echo "Project: $PROJECT_NAME"
echo "Output:  $OUTPUT_DIR"
echo ""
echo "Next steps:"
echo "  1. cd $OUTPUT_DIR"
echo "  2. Review and customize rendered files"
echo "  3. Run drift checker: bash .claude/hooks/check-primitive-drift.sh"
echo "  4. Commit the harness"
