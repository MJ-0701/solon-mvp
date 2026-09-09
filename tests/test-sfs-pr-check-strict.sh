#!/usr/bin/env bash
# tests/test-sfs-pr-check-strict.sh — G6.1 F2 regression.
#
# Contract:
#   1) .github/workflows/sfs-pr-check.yml MUST invoke the canonical
#      scripts/sfs-quality-gate.sh --root . --mode pr wrapper, not an inlined
#      storage-precommit step.
#   2) scripts/sfs-quality-gate.sh in pr mode MUST invoke
#      sfs-storage-precommit.sh in --strict mode and must not downgrade that
#      step to --advisory.
#   3) sfs-storage-precommit.sh --strict MUST reject a synthetic orphan Layer 2
#      sprint (regression for the strict-mode rejection itself).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORKFLOW="${DIST_DIR}/.github/workflows/sfs-pr-check.yml"
QUALITY_GATE="${DIST_DIR}/scripts/sfs-quality-gate.sh"
PRECOMMIT="${DIST_DIR}/scripts/sfs-storage-precommit.sh"

[[ -f "${WORKFLOW}" ]]   || { echo "F2 FAIL: ${WORKFLOW} missing"; exit 1; }
[[ -x "${QUALITY_GATE}" ]]|| { echo "F2 FAIL: ${QUALITY_GATE} not executable"; exit 1; }
[[ -x "${PRECOMMIT}" ]]  || { echo "F2 FAIL: ${PRECOMMIT} not executable"; exit 1; }

# Contract 1: workflow invokes canonical quality gate wrapper.
if ! grep -Fq 'bash scripts/sfs-quality-gate.sh --root . --mode pr' "${WORKFLOW}"; then
  echo "F2 FAIL: ${WORKFLOW} does not invoke canonical sfs-quality-gate.sh --root . --mode pr"
  exit 1
fi
if grep -qE 'sfs-storage-precommit\.sh' "${WORKFLOW}"; then
  echo "F2 FAIL: ${WORKFLOW} must not inline sfs-storage-precommit.sh after quality-gate canonicalization"
  exit 1
fi

# Contract 2: canonical wrapper keeps the storage precommit step strict.
if ! grep -qE 'sfs-storage-precommit\.sh.*--strict' "${QUALITY_GATE}"; then
  echo "F2 FAIL: ${QUALITY_GATE} does not invoke sfs-storage-precommit.sh with --strict"
  exit 1
fi
if grep -E 'sfs-storage-precommit\.sh' "${QUALITY_GATE}" | grep -v -- '--strict' | grep -q -- '--advisory'; then
  echo "F2 FAIL: ${QUALITY_GATE} still invokes sfs-storage-precommit.sh with --advisory (G6.1 F2 fix incomplete)"
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

echo "test-sfs-pr-check-strict: OK (workflow canonical wrapper + wrapper strict-storage + orphan rejection: strict=${strict_ec}, advisory=${advisory_ec})"
