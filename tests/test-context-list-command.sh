#!/usr/bin/env bash
# Contract test for `sfs context list` (0.7.1).
#
# The list subcommand is a discoverability helper: an agent can call it to
# learn which routed modules exist without grepping `_INDEX.md`. The test
# locks the basic shape (top-level / commands / policies sections) and
# confirms that load-bearing modules introduced in 0.7.0 (agent-build
# review lens) and earlier (division council, plan, review) are findable.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"

fail() { echo "FAIL: $*" >&2; exit 1; }

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-context-list.XXXXXX")"
cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

cd "${TMP_DIR}"
git init -q
git config user.email "ctx-list@solon.invalid"
git config user.name "Solon Context List Test"
printf '# ctx list\n' > README.md
git add . && git commit -qm "init"
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1

# ── 1) bare `list` prints all three sections in stable order. ───────
out="$(SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" context list 2>&1)"
for header in '# top-level' '# commands' '# policies'; do
  grep -qF "${header}" <<<"${out}" \
    || fail "context list missing section header: ${header}"
done
grep -qE '^  kernel$' <<<"${out}" || fail "context list missing kernel"
grep -qE '^  index$' <<<"${out}" || fail "context list missing index"
grep -qE '^  commands/plan$' <<<"${out}" || fail "context list missing commands/plan"
grep -qE '^  commands/review$' <<<"${out}" || fail "context list missing commands/review"
grep -qE '^  commands/healthcheck$' <<<"${out}" || fail "context list missing commands/healthcheck"

# ── 2) `list policies` prints policies only. ────────────────────────
out_pol="$(SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" context list policies 2>&1)"
grep -qF '# policies' <<<"${out_pol}" || fail "list policies missing header"
grep -qF '# commands' <<<"${out_pol}" \
  && fail "list policies should not include commands section"
grep -qE '^  policies/agent-build-review-lens$' <<<"${out_pol}" \
  || fail "list policies missing 0.7.0 agent-build-review-lens"
grep -qE '^  policies/division-subagent-council$' <<<"${out_pol}" \
  || fail "list policies missing division-subagent-council"
grep -qE '^  policies/enterprise-plan-council-pack$' <<<"${out_pol}" \
  || fail "list policies missing enterprise-plan-council-pack"

# ── 3) `list commands` prints commands only. ────────────────────────
out_cmd="$(SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" context list commands 2>&1)"
grep -qF '# commands' <<<"${out_cmd}" || fail "list commands missing header"
grep -qF '# policies' <<<"${out_cmd}" \
  && fail "list commands should not include policies section"

# ── 4) bad scope is rejected. ───────────────────────────────────────
set +e
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" context list bogus >/dev/null 2>"${TMP_DIR}/err"
rc=$?
set -e
[[ "${rc}" -ne 0 ]] || fail "context list bogus should exit non-zero"
grep -qF 'unknown context list scope' "${TMP_DIR}/err" \
  || fail "context list bogus must surface a clear error"

# ── 5) usage banner mentions the list subcommand. ───────────────────
usage="$(SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" context 2>&1)"
grep -qF 'sfs context list' <<<"${usage}" \
  || fail "context usage must document the list subcommand"

echo "test-context-list-command: OK"
