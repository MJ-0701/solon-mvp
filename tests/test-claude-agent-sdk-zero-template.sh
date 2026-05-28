#!/usr/bin/env bash
# Static contract test for templates/claude-agent-sdk-zero/.
#
# The template is a scaffold consumers materialize via `sfs bootstrap`,
# so we don't run the generated project's Python tests here (no API key,
# no SDK installed in the test environment). Instead we statically
# verify the shape of the shipped template files: each required file
# exists, placeholders are present (not pre-substituted), permission
# preset stays in sync with the upstream, and no secret material was
# committed by accident.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TPL_DIR="${DIST_DIR}/templates/claude-agent-sdk-zero"
UPSTREAM_PRESET="${DIST_DIR}/templates/.sfs-local-template/presets/solon-safe-permissions.yaml"

fail() { echo "FAIL: $*" >&2; exit 1; }

# ── 1) Required files all present. ──────────────────────────────────
required=(
  "${TPL_DIR}/README.md"
  "${TPL_DIR}/pyproject.toml"
  "${TPL_DIR}/.gitignore"
  "${TPL_DIR}/agent.py"
  "${TPL_DIR}/system_prompt.md"
  "${TPL_DIR}/solon-safe-permissions.yaml"
  "${TPL_DIR}/tests/test_agent_smoke.py"
)
for f in "${required[@]}"; do
  [[ -f "${f}" ]] || fail "missing template artifact: ${f}"
done

# ── 2) Placeholders are present (template, not pre-substituted). ────
for f in \
  "${TPL_DIR}/README.md" \
  "${TPL_DIR}/pyproject.toml" \
  "${TPL_DIR}/agent.py" \
  "${TPL_DIR}/system_prompt.md"
do
  grep -qF '<PROJECT-NAME>' "${f}" \
    || fail "${f} missing <PROJECT-NAME> placeholder"
done
for f in \
  "${TPL_DIR}/pyproject.toml" \
  "${TPL_DIR}/agent.py" \
  "${TPL_DIR}/system_prompt.md"
do
  grep -qF '<DOMAIN>' "${f}" \
    || fail "${f} missing <DOMAIN> placeholder"
done

# ── 3) agent.py is valid Python and references the Agent SDK + MCP. ─
if command -v python3 >/dev/null 2>&1; then
  python3 -c "import ast, sys; ast.parse(open(sys.argv[1]).read())" "${TPL_DIR}/agent.py" \
    || fail "${TPL_DIR}/agent.py is not valid Python 3"
fi
for need in \
  'from claude_agent_sdk' \
  'load_system_prompt' \
  'load_permissions' \
  '"solon"' \
  '"command": "solon-mcp"' \
  '"transport": "stdio"'
do
  grep -qF -- "${need}" "${TPL_DIR}/agent.py" \
    || fail "agent.py missing: ${need}"
done

# ── 4) pyproject.toml pins the right runtime deps. ──────────────────
for need in 'claude-agent-sdk' 'solon-mcp' 'pyyaml'; do
  grep -qF -- "${need}" "${TPL_DIR}/pyproject.toml" \
    || fail "pyproject.toml missing dep: ${need}"
done

# ── 5) The template's solon-safe-permissions.yaml mirrors the upstream
#       shape (version, denied auto-push, mainline_first, require_gate_6).
#       It is INTENDED to drift after scaffolding, so we only check the
#       load-bearing rules — not byte equality. ────────────────────
for need in \
  'version: "0.7.' \
  '"bash:git push*"' \
  '"bash:rm -rf *"' \
  'mainline_first: true' \
  'require_gate_6: true' \
  'handoff_is_stop_contract: true'
do
  grep -qF -- "${need}" "${TPL_DIR}/solon-safe-permissions.yaml" \
    || fail "template preset missing load-bearing rule: ${need}"
done

# Upstream preset must also still have the same rules — drift signal.
for need in \
  'mainline_first: true' \
  'require_gate_6: true' \
  '"bash:git push*"'
do
  grep -qF -- "${need}" "${UPSTREAM_PRESET}" \
    || fail "upstream preset drifted from template's load-bearing rules: ${need}"
done

# ── 6) System prompt embeds the Solon principles a template user
#       would otherwise have to copy from kernel.md. ──────────────────
for principle in \
  'Bash adapter SSoT' \
  'Mainline-first' \
  'Gate 6 before merge' \
  'Korean-first projects' \
  'stop contract'
do
  grep -qF -- "${principle}" "${TPL_DIR}/system_prompt.md" \
    || fail "system_prompt.md missing principle: ${principle}"
done

# ── 7) No secret material committed by accident. ────────────────────
for marker in sk-ant- sk-proj- ghp_ AIzaSy; do
  if grep -RIn -F -- "${marker}" "${TPL_DIR}" 2>/dev/null; then
    fail "possible secret committed: ${marker}"
  fi
done

# ── 8) Smoke pytest file is parseable Python and asserts the expected
#       smoke contracts. ────────────────────────────────────────────
if command -v python3 >/dev/null 2>&1; then
  python3 -c "import ast, sys; ast.parse(open(sys.argv[1]).read())" "${TPL_DIR}/tests/test_agent_smoke.py" \
    || fail "tests/test_agent_smoke.py is not valid Python 3"
fi
for assertion in \
  'test_system_prompt_nonempty_and_solon_aware' \
  'test_permission_preset_parses_and_denies_auto_push' \
  'test_mcp_server_registration_shape' \
  'test_no_secrets_committed'
do
  grep -qF -- "${assertion}" "${TPL_DIR}/tests/test_agent_smoke.py" \
    || fail "smoke pytest missing assertion: ${assertion}"
done

echo "test-claude-agent-sdk-zero-template: OK"
