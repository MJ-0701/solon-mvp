#!/usr/bin/env bash
# Static contract test for templates/mcp-tool-zero/ (B4).
#
# The template is a scaffold consumers materialize via `sfs bootstrap`, so we
# statically verify the shipped shape rather than run the generated project.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TPL_DIR="${DIST_DIR}/templates/mcp-tool-zero"

fail() { echo "FAIL: $*" >&2; exit 1; }

# ── 1) Required files present. ──────────────────────────────────────
required=(
  "${TPL_DIR}/README.md"
  "${TPL_DIR}/pyproject.toml"
  "${TPL_DIR}/.gitignore"
  "${TPL_DIR}/server.py"
  "${TPL_DIR}/solon-safe-permissions.yaml"
  "${TPL_DIR}/tests/test_tool_smoke.py"
)
for f in "${required[@]}"; do
  [[ -f "${f}" ]] || fail "missing template artifact: ${f}"
done

# ── 2) Placeholders present (template, not pre-substituted). ────────
for f in "${TPL_DIR}/README.md" "${TPL_DIR}/pyproject.toml" "${TPL_DIR}/server.py"; do
  grep -qF '<PROJECT-NAME>' "${f}" || fail "${f} missing <PROJECT-NAME> placeholder"
  grep -qF '<DOMAIN>' "${f}" || fail "${f} missing <DOMAIN> placeholder"
done
grep -qF '<TOOL-NAME>' "${TPL_DIR}/README.md" || fail "README missing <TOOL-NAME> placeholder"

# ── 3) server.py is valid Python and is a single-narrow-tool MCP server. ─
if command -v python3 >/dev/null 2>&1; then
  python3 -c "import ast, sys; ast.parse(open(sys.argv[1]).read())" "${TPL_DIR}/server.py" \
    || fail "server.py is not valid Python 3"
fi
[[ "$(grep -c '@mcp.tool()' "${TPL_DIR}/server.py")" -eq 1 ]] \
  || fail "server.py must declare exactly one @mcp.tool() (narrow surface)"
for need in 'from mcp.server.fastmcp import FastMCP' 'def load_permissions' 'transport="stdio"' 'sub-agent capsule'; do
  grep -qF -- "${need}" "${TPL_DIR}/server.py" || fail "server.py missing: ${need}"
done

# ── 4) pyproject pins MCP + yaml deps. ──────────────────────────────
for need in 'mcp>=' 'pyyaml'; do
  grep -qF -- "${need}" "${TPL_DIR}/pyproject.toml" || fail "pyproject.toml missing dep: ${need}"
done

# ── 5) Permission preset keeps load-bearing default-deny rules. ─────
for need in 'version: "0.7.' '"bash:git push*"' '"bash:rm -rf *"' 'mainline_first: true' 'require_gate_6: true' 'handoff_is_stop_contract: true'; do
  grep -qF -- "${need}" "${TPL_DIR}/solon-safe-permissions.yaml" \
    || fail "template preset missing load-bearing rule: ${need}"
done

# ── 6) Smoke pytest is parseable + asserts the expected contracts. ──
if command -v python3 >/dev/null 2>&1; then
  python3 -c "import ast, sys; ast.parse(open(sys.argv[1]).read())" "${TPL_DIR}/tests/test_tool_smoke.py" \
    || fail "tests/test_tool_smoke.py is not valid Python 3"
fi
for assertion in \
  'test_server_declares_single_narrow_tool' \
  'test_tool_input_is_typed_and_bounded' \
  'test_permission_preset_parses_and_denies_auto_push' \
  'test_no_secrets_committed'
do
  grep -qF -- "${assertion}" "${TPL_DIR}/tests/test_tool_smoke.py" \
    || fail "smoke pytest missing assertion: ${assertion}"
done

# ── 7) No secret material committed. ────────────────────────────────
for marker in sk-ant- sk-proj- ghp_ AIzaSy; do
  if grep -RIn -F -- "${marker}" "${TPL_DIR}" 2>/dev/null; then
    fail "possible secret committed: ${marker}"
  fi
done

echo "test-mcp-tool-zero-template: OK"
