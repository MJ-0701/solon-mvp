#!/usr/bin/env bash
# Canonical PR quality-gate invocation + maintenance-doc policy lock.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORKFLOW="${DIST_DIR}/.github/workflows/sfs-pr-check.yml"
CONTRIB="${DIST_DIR}/docs/maintenance/contributing.md"
RELPOL="${DIST_DIR}/docs/maintenance/release-policy.md"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

assert_contains "${WORKFLOW}" "sfs-quality-gate.sh --root . --mode pr" "workflow canonical wrapper invocation"
if grep -Fq 'bash tests/test-hash-parity.sh' "${WORKFLOW}"; then
  fail "workflow must not inline hash-parity after quality-gate canonicalization"
fi
if grep -Fq 'bash scripts/sfs-storage-precommit.sh --root . --strict' "${WORKFLOW}"; then
  fail "workflow must not inline storage-precommit after quality-gate canonicalization"
fi
if grep -Fq 'bash scripts/sfs-pr-review-flow-check.sh --root .' "${WORKFLOW}"; then
  fail "workflow must not inline review-flow after quality-gate canonicalization"
fi

assert_contains "${CONTRIB}" "scripts/sfs-quality-gate.sh --root . --mode pr" "contributing canonical PR command"
assert_contains "${CONTRIB}" '`pr` 는 현재 PR CI baseline' "contributing pr mode"
assert_contains "${CONTRIB}" "tests/test-sfs-quality-gate.sh" "contributing wrapper contract coverage"
assert_contains "${CONTRIB}" "tests/test-aws-agent-toolkit-setup-policy.sh" "contributing AWS policy coverage"
assert_contains "${CONTRIB}" '`full` 은 `pr` + `bash tests/run-all.sh`' "contributing full mode"
assert_contains "${CONTRIB}" '`release` 는 `full` + `bash scripts/verify-product-release.sh --version X.Y.Z`' "contributing release mode"
assert_contains "${CONTRIB}" "risk-triggered escalation" "contributing deep-review escalation policy"
assert_contains "${CONTRIB}" "documented SKIP" "contributing skip contract"

assert_contains "${RELPOL}" "scripts/sfs-quality-gate.sh --mode pr" "release policy canonical entry"
assert_contains "${RELPOL}" "risk-triggered" "release policy risk-triggered framing"
assert_contains "${RELPOL}" "product-bearing PR" "release policy product-bearing trigger"
assert_contains "${RELPOL}" '`full` / `release`' "release policy heavier modes"

echo "test-quality-gate-policy: OK"
