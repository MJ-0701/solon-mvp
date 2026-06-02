#!/usr/bin/env bash
# Contract test for the `flowcheck` routed command + FCP policy (0.8.0).
# Locks that both context docs resolve and carry the event contract, the
# hybrid enforcement model, and the invariant registry (incl. pr-reviewed).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"

fail() { echo "FAIL: $*" >&2; exit 1; }

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-flowcheck-ctx.XXXXXX")"
cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

cd "${TMP_DIR}"
git init -q
git config user.email "flowcheck-ctx@solon.invalid"
git config user.name "Solon Flowcheck Ctx Test"
printf '# flowcheck ctx\n' > README.md
git add . && git commit -qm "init"
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1

cmd="$(SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" context cat commands/flowcheck 2>&1)" \
  || fail "context cat commands/flowcheck failed: ${cmd}"
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" context cat flowcheck >/dev/null 2>&1 \
  || fail "bare 'flowcheck' context key did not resolve"

grep -q "silent divergence" <<<"${cmd}" || fail "command missing silent-divergence purpose"
grep -q "blocking" <<<"${cmd}" || fail "command missing hybrid blocking enforcement"
grep -q "report-bug" <<<"${cmd}" || fail "command missing report-bug routing"

# BWU-2 — plan=quality-gate self-check (암묵 가정 → 명시 스펙) must be exposed in
# the flowcheck command, integrated with the #3 (conflict-surfaced) / #4
# (model-tier) divergence locks. ASCII-only markers (no Korean grep / locale trap).
grep -q "plan = quality gate" <<<"${cmd}" || fail "command missing plan=quality-gate principle"
for q in intended-output implicit-assumptions edge-cases intent-alignment; do
  grep -q -- "${q}" <<<"${cmd}" || fail "command missing plan self-check question '${q}'"
done
grep -q "fcp-conflict-surfaced" <<<"${cmd}" || fail "command checklist missing #3 (fcp-conflict-surfaced) integration"

pol="$(SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" context cat policies/flow-conformance-postflight.md 2>&1)" \
  || fail "context cat policies/flow-conformance-postflight.md failed: ${pol}"

for inv in fcp-model-tier fcp-conflict-surfaced fcp-gate-order fcp-stop-the-line fcp-pr-reviewed fcp-verifier-implementer fcp-self-cpo fcp-worker-lane; do
  grep -q "${inv}" <<<"${pol}" || fail "policy missing invariant ${inv}"
done
for ev in model_resolved worker_dispatched gate_passed conflict_surfaced verification_pair; do
  grep -q "${ev}" <<<"${pol}" || fail "policy missing event ${ev}"
done
grep -q "non-collapsing" <<<"${pol}" || fail "policy missing non-collapsing event contract"
grep -q "GitHub PR" <<<"${pol}" || fail "pr-reviewed should clarify GitHub PR does not satisfy SFS gate"

# BWU-2 — policy must also expose the plan-gate self-check (ASCII markers).
grep -q "plan = quality gate" <<<"${pol}" || fail "policy missing plan=quality-gate principle"
for q in intended-output implicit-assumptions edge-cases intent-alignment; do
  grep -q -- "${q}" <<<"${pol}" || fail "policy missing plan self-check question '${q}'"
done

echo "PASS: test-context-flowcheck-command.sh"
