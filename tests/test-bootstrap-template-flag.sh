#!/usr/bin/env bash
# `sfs bootstrap --template <name>` flag — 0.7.5 contract test.
#
# 0.7.0 added templates/claude-agent-sdk-zero/ but sfs-bootstrap.sh only
# knew about templates/spring-kotlin-zero/. 0.7.5 generalized the
# bootstrap path so any directory under templates/<name>/ can be
# scaffolded with the always-on placeholder substitutions
# (<PROJECT-NAME>, <DATE>, <DOMAIN>) and without the Spring-specific
# flags being required.
#
# This test materializes a scaffold via the new flag, verifies the
# substitutions landed, and locks the generic-template path against
# regression into the Spring-only branch.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BOOTSTRAP="${DIST_DIR}/scripts/sfs-bootstrap.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -x "${BOOTSTRAP}" ]] || fail "missing or non-executable sfs-bootstrap.sh"

# ── 1) Help text advertises the new flag and the generic-template mode. ─
help_text="$(bash "${BOOTSTRAP}" --help 2>&1 || true)"
grep -qF -- '--template <name>' <<<"${help_text}" \
  || fail "bootstrap --help must document --template <name>"
grep -qF -- 'Generic template mode' <<<"${help_text}" \
  || fail "bootstrap --help must label the generic-template mode"

# ── 2) Scaffold claude-agent-sdk-zero via --template. ───────────────
tmp="$(mktemp -d "${TMPDIR:-/tmp}/sfs-bootstrap-template.XXXXXX")"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT

cd "${tmp}"
SFS_DIST_DIR="${DIST_DIR}" bash "${BOOTSTRAP}" \
  --experimental --template claude-agent-sdk-zero my-test-agent \
  >/dev/null 2>"${tmp}/stderr"

grep -qF '[bootstrap] my-test-agent created (template=claude-agent-sdk-zero)' "${tmp}/stderr" \
  || fail "bootstrap stderr must announce template-based creation"

# ── 3) Expected scaffold files are present. ─────────────────────────
expected_files=(
  "my-test-agent/README.md"
  "my-test-agent/pyproject.toml"
  "my-test-agent/.gitignore"
  "my-test-agent/agent.py"
  "my-test-agent/system_prompt.md"
  "my-test-agent/solon-safe-permissions.yaml"
  "my-test-agent/tests/test_agent_smoke.py"
)
for f in "${expected_files[@]}"; do
  [[ -f "${f}" ]] || fail "scaffold missing expected file: ${f}"
done

# ── 4) Placeholders were substituted (no <PROJECT-NAME> / <DATE> / <DOMAIN>
#       left). Use a fixed pattern list so a future placeholder addition
#       does not silently drift. ───────────────────────────────────────
for placeholder in '<PROJECT-NAME>' '<DATE>' '<DOMAIN>'; do
  if grep -RIn -F -- "${placeholder}" my-test-agent 2>/dev/null; then
    fail "scaffold still contains unsubstituted placeholder: ${placeholder}"
  fi
done

# ── 5) The project name actually substituted (positive check). ──────
grep -qF 'PROJECT_NAME = "my-test-agent"' my-test-agent/agent.py \
  || fail "agent.py PROJECT_NAME constant should be substituted to 'my-test-agent'"
grep -qE '^name = "my-test-agent"' my-test-agent/pyproject.toml \
  || fail "pyproject.toml [project].name should be substituted to 'my-test-agent'"

# ── 6) Spring-specific flags are NOT required for --template mode.
#       (We confirmed step 2 succeeded without --java-version etc.) ──
#       Also confirm Spring tokens are absent from the generic template
#       so we did not accidentally pull in the Spring substitution path.
for spring_token in '<JAVA-VERSION>' '<SPRING-BOOT-VERSION>' '<PACKAGE>' '<PACKAGE_PATH>'; do
  if grep -RIn -F -- "${spring_token}" my-test-agent 2>/dev/null; then
    fail "generic-template scaffold should not carry Spring placeholder: ${spring_token}"
  fi
done

# ── 7) Bad template path is rejected with a clear error. ────────────
cd "${tmp}"
set +e
SFS_DIST_DIR="${DIST_DIR}" bash "${BOOTSTRAP}" \
  --experimental --template ../escape attacker-attempt >/dev/null 2>"${tmp}/bad.err"
bad_rc=$?
set -e
[[ "${bad_rc}" -ne 0 ]] || fail "--template with .. should be rejected"
grep -qF 'must be a directory name under templates/' "${tmp}/bad.err" \
  || fail "bad --template error message must explain the constraint"

echo "test-bootstrap-template-flag: OK"
