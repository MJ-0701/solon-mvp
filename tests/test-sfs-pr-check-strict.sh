#!/usr/bin/env bash
# tests/test-sfs-pr-check-strict.sh — G6.1 F2 regression.
#
# Contract:
#   1) .github/workflows/sfs-pr-check.yml MUST invoke sfs-storage-precommit.sh in
#      --strict mode (Option A — fail PR on storage validator violations).
#   2) The --advisory invocation in that workflow step MUST be removed (any
#      lingering --advisory in the precommit step would silently mask failures).
#   3) sfs-storage-precommit.sh --strict MUST reject a synthetic orphan Layer 2
#      sprint (regression for the strict-mode rejection itself).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORKFLOW="${DIST_DIR}/.github/workflows/sfs-pr-check.yml"
PRECOMMIT="${DIST_DIR}/scripts/sfs-storage-precommit.sh"

[[ -f "${WORKFLOW}" ]]   || { echo "F2 FAIL: ${WORKFLOW} missing"; exit 1; }
[[ -x "${PRECOMMIT}" ]]  || { echo "F2 FAIL: ${PRECOMMIT} not executable"; exit 1; }

# Contract 1: workflow invokes sfs-storage-precommit.sh with --strict.
if ! grep -qE 'sfs-storage-precommit\.sh.*--strict' "${WORKFLOW}"; then
  echo "F2 FAIL: ${WORKFLOW} does not invoke sfs-storage-precommit.sh with --strict"
  exit 1
fi

# Contract 2: no --advisory in the storage precommit step.
# Allow --advisory to appear in unrelated locations only if accompanied by --strict on the same line.
if grep -E 'sfs-storage-precommit\.sh' "${WORKFLOW}" | grep -v -- '--strict' | grep -q -- '--advisory'; then
  echo "F2 FAIL: ${WORKFLOW} still invokes sfs-storage-precommit.sh with --advisory (G6.1 F2 fix incomplete)"
  exit 1
fi

# Contract 3: --strict mode rejects orphan Layer 2 sprint.
tmp="$(mktemp -d)"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT
cd "${tmp}"
git init -q
git config user.email t@t
git config user.name t
mkdir -p .solon/sprints/0-6-0-orphan/orphan
cat > .solon/sprints/0-6-0-orphan/sprint.yml <<'YML'
sprint_id: 0-6-0-orphan
status: in-progress
features:
  - orphan
dependencies: []
completion_criteria:
  - x
milestones: []
created_at: 2026-05-04T00:00:00Z
closed_at: null
YML

set +e
bash "${PRECOMMIT}" --root . --strict >/dev/null 2>&1
strict_ec=$?
bash "${PRECOMMIT}" --root . --advisory >/dev/null 2>&1
advisory_ec=$?
set -e

if [[ "${strict_ec}" -eq 0 ]]; then
  echo "F2 FAIL: --strict mode accepted orphan Layer 2 sprint (expected non-zero)"
  exit 1
fi
if [[ "${advisory_ec}" -ne 0 ]]; then
  echo "F2 FAIL: --advisory mode rejected orphan (expected exit 0 — advisory is non-blocking)"
  exit 1
fi

echo "test-sfs-pr-check-strict: OK (workflow contract --strict + orphan rejection: strict=${strict_ec}, advisory=${advisory_ec})"
