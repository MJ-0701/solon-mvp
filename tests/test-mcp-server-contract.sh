#!/usr/bin/env bash
# Solon MCP server static contract test.
#
# The server itself runs as a separate optional Python process, so this test
# does NOT spawn it (no Python `mcp` dep required to run the test suite).
# Instead it statically verifies the server file:
#
#   1. is parseable as Python 3 (when python3 is available)
#   2. registers the MCP server under the name `solon`
#   3. declares every MVP tool the README promises
#   4. wraps `sfs` via subprocess (kernel.md SSoT requirement) and never
#      reshapes the bash adapter stdout in transit
#   5. ships a pyproject.toml with a console script entrypoint
#   6. ships a README with registration snippets for the major MCP hosts
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SERVER="${DIST_DIR}/mcp-server/solon_mcp_server.py"
PYPROJECT="${DIST_DIR}/mcp-server/pyproject.toml"
README="${DIST_DIR}/mcp-server/README.md"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

for f in "${SERVER}" "${PYPROJECT}" "${README}"; do
  [[ -f "${f}" ]] || fail "missing artifact: ${f}"
done

# ── 1) parseable as Python (when python3 is available) ──────────────
if command -v python3 >/dev/null 2>&1; then
  python3 -c "import ast, sys; ast.parse(open(sys.argv[1]).read())" "${SERVER}" \
    || fail "${SERVER} is not valid Python 3"
fi

# ── 2) registered under the name `solon` ────────────────────────────
grep -qE 'FastMCP\(\s*"solon"\s*\)' "${SERVER}" \
  || fail "${SERVER} must register the MCP server with name \"solon\""

# ── 3) every MVP tool is declared ───────────────────────────────────
expected_tools=(
  sfs_status
  sfs_version
  sfs_report
  sfs_report_bug
  sfs_flowcheck
  sfs_harness_doctor
  sfs_start
  sfs_brainstorm
  sfs_plan
  sfs_implement
  sfs_review
  sfs_retro
  sfs_decision
  sfs_capture
)
for tool in "${expected_tools[@]}"; do
  grep -qE "^def ${tool}\(" "${SERVER}" \
    || fail "${SERVER} missing tool: ${tool}"
  grep -Fq "${tool}" "${README}" \
    || fail "${README} does not document tool: ${tool}"
done

# ── 4) wraps `sfs` via subprocess and respects SSoT ─────────────────
grep -qE 'subprocess\.(run|Popen)' "${SERVER}" \
  || fail "${SERVER} must shell out to sfs via subprocess (kernel.md SSoT)"
grep -qF 'verbatim' "${SERVER}" \
  || fail "${SERVER} must explicitly document verbatim stdout forwarding"
grep -qF 'shutil.which' "${SERVER}" \
  || fail "${SERVER} must resolve sfs via shutil.which / SOLON_MCP_SFS_PATH"

# ── 5) pyproject ships a console script ─────────────────────────────
grep -qE '^\s*solon-mcp\s*=\s*"solon_mcp_server:main"' "${PYPROJECT}" \
  || fail "${PYPROJECT} must expose a solon-mcp console script"
grep -qE '^\s*"mcp>=' "${PYPROJECT}" \
  || fail "${PYPROJECT} must declare an mcp>= dependency"
grep -qE '^version\s*=\s*"0\.7\.[0-9]+"' "${PYPROJECT}" \
  || fail "${PYPROJECT} version must track the 0.7.x line"

# ── 6) README documents registration for the major hosts ────────────
for host_keyword in "Claude Desktop" "Cursor" "Claude Agent SDK" "Claude in Chrome" "Claude Code"; do
  grep -Fq "${host_keyword}" "${README}" \
    || fail "${README} must document ${host_keyword} registration"
done

# ── 7) Documents the bash-SSoT contract so future contributors don't
#       silently start reshaping output. ─────────────────────────────
grep -qF 'verbatim' "${README}" \
  || fail "${README} must state the verbatim/SSoT contract"
grep -qF 'kernel.md' "${README}" \
  || fail "${README} must cite kernel.md as the SSoT source"

echo "test-mcp-server-contract: OK"
