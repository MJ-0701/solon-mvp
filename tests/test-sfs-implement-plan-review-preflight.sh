#!/usr/bin/env bash
# tests/test-sfs-implement-plan-review-preflight.sh — implement requires Gate 3 plan review PASS.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-implement-plan-review.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

setup_project() {
  local dir="$1"
  mkdir -p "${dir}"
  cd "${dir}"
  git init -q
  printf '# Plan Review Project\n' > README.md
  git add README.md
  git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" start "plan review before implement" >/dev/null
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" brainstorm --simple "raw" >/dev/null
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" plan >/dev/null
}

setup_project "${TMP_DIR}/blocked"
set +e
blocked_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" implement "slice" 2>&1)"
blocked_rc=$?
set -e
[[ "${blocked_rc}" -eq 8 ]] || fail "implement without plan review should exit 8, got ${blocked_rc}: ${blocked_out}"
case "${blocked_out}" in
  *"Gate 3 Plan review required before implement"* ) ;;
  *) fail "missing plan review guidance: ${blocked_out}" ;;
esac
sprint_id="$(cat .sfs-local/current-sprint)"
[[ ! -f ".sfs-local/sprints/${sprint_id}/implement.md" ]] || fail "blocked implement should not create implement.md"

setup_project "${TMP_DIR}/waived"
waived_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" implement --allow-unreviewed-plan "slice")"
case "${waived_out}" in
  *"plan review: waived"* ) ;;
  *) fail "waived implement should announce waiver: ${waived_out}" ;;
esac
grep -Fq '"type":"implement_unreviewed_plan_waiver"' .sfs-local/events.jsonl \
  || fail "waived implement should record waiver event"

setup_project "${TMP_DIR}/passed"
sprint_id="$(cat .sfs-local/current-sprint)"
mkdir -p .sfs-local/tmp/review-runs
result_path=".sfs-local/tmp/review-runs/gate3-plan-review.md"
printf 'Verdict: pass\nEvidence checked: plan.md\n' > "${result_path}"
printf '{"ts":"2026-05-06T23:08:00+09:00","type":"review_run","sprint_id":"%s","gate_id":"G1","output_path":"%s","evaluator_executor":"codex","generator_executor":"claude"}\n' "${sprint_id}" "${result_path}" >> .sfs-local/events.jsonl
passed_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" implement "slice")"
case "${passed_out}" in
  *"plan review: pass"* ) ;;
  *) fail "passed review should allow implement: ${passed_out}" ;;
esac

echo "test-sfs-implement-plan-review-preflight: OK"
