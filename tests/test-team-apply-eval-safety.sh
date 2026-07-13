#!/usr/bin/env bash
# Security regression: team_runtime_capable must NOT eval an attacker-influenced
# runtime name. `rt` comes from project-editable model-profiles.yaml, so a value
# like `x}$(cmd)` must never trigger command execution.
#
# Locks: (1) no `eval` on the SFS_TEAM_FORCE_CAPABLE_ override path, (2) a
# malicious rt name runs no command and is treated as untrusted (safe pass).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
APPLY="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-team-apply.sh"
COMMON="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-common.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }

# ── static lock: the override lookup must not use eval ───────────────
if grep -nE 'eval[[:space:]]+"force=' "${APPLY}"; then
  fail "team_runtime_capable must not eval the override var (use \${!var} indirect expansion)"
fi
grep -q 'SFS_TEAM_FORCE_CAPABLE_' "${APPLY}" || fail "override probe missing (test stale?)"

# ── dynamic lock: a malicious runtime name executes nothing ──────────
TMP="$(mktemp -d "${TMPDIR:-/tmp}/sfs-team-eval.XXXXXX")"
trap 'rm -rf "${TMP}"' EXIT
marker="${TMP}/PWNED"

set +e
bash -c '
  source "'"${COMMON}"'" 2>/dev/null
  source "'"${APPLY}"'"  2>/dev/null
  team_runtime_capable "x}$(touch '"${marker}"')"
  team_runtime_capable "$(touch '"${marker}"'.2)"
  team_runtime_capable "\`touch '"${marker}"'.3\`"
' >/dev/null 2>&1
set -e

[[ ! -e "${marker}" && ! -e "${marker}.2" && ! -e "${marker}.3" ]] \
  || fail "eval-injection: a malicious runtime name executed a command"

# (Legitimate-runtime capability is already covered by test-team-runtime-ocp /
# test-team-preset-install / test-team-fallback-promotion; this test scopes to
# the eval-injection security boundary only.)

echo "test-team-apply-eval-safety: OK"
