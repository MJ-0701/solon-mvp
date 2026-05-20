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

setup_project "${TMP_DIR}/self-only-blocked"
sprint_id="$(cat .sfs-local/current-sprint)"
mkdir -p .sfs-local/tmp/review-runs
self_path=".sfs-local/tmp/review-runs/gate3-self-cpo.md"
printf 'Verdict: pass\nReview stage: self-CPO\nEvidence checked: plan.md\n' > "${self_path}"
printf '{"ts":"2026-05-06T23:07:00+09:00","type":"review_run","sprint_id":"%s","gate_id":"G1","output_path":"%s","review_stage":"self","cross_review":false,"evaluator_executor":"codex","generator_executor":"codex"}\n' "${sprint_id}" "${self_path}" >> .sfs-local/events.jsonl
set +e
self_only_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" implement "slice" 2>&1)"
self_only_rc=$?
set -e
[[ "${self_only_rc}" -eq 8 ]] || fail "self-CPO-only pass should block implement, got ${self_only_rc}: ${self_only_out}"
case "${self_only_out}" in
  *"Gate 3 cross review or valid self-CPO fallback evidence required before implement"* ) ;;
  *) fail "self-only block should require cross review or fallback evidence: ${self_only_out}" ;;
esac

setup_project "${TMP_DIR}/self-fallback-passed"
sprint_id="$(cat .sfs-local/current-sprint)"
mkdir -p .sfs-local/tmp/review-runs
self_fallback_path=".sfs-local/tmp/review-runs/gate3-self-cpo-fallback.md"
printf 'Verdict: pass\nSelf-CPO fallback: true\nFallback reason: no other agent subscription\nEvidence checked: plan.md\n' > "${self_fallback_path}"
printf '{"ts":"2026-05-06T23:07:30+09:00","type":"review_run","sprint_id":"%s","gate_id":"G1","output_path":"%s","review_stage":"self","cross_review":false,"self_cpo_fallback":true,"fallback_reason":"no_other_agent_subscription","evaluator_executor":"codex","generator_executor":"codex"}\n' "${sprint_id}" "${self_fallback_path}" >> .sfs-local/events.jsonl
self_fallback_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" implement "slice")"
case "${self_fallback_out}" in
  *"plan review: pass"* ) ;;
  *) fail "self-CPO fallback evidence should allow implement: ${self_fallback_out}" ;;
esac

setup_project "${TMP_DIR}/passed"
sprint_id="$(cat .sfs-local/current-sprint)"
mkdir -p .sfs-local/tmp/review-runs
result_path=".sfs-local/tmp/review-runs/gate3-plan-review.md"
printf 'Verdict: pass\nReview stage: cross\nEvidence checked: plan.md\n' > "${result_path}"
printf '{"ts":"2026-05-06T23:08:00+09:00","type":"review_run","sprint_id":"%s","gate_id":"G1","output_path":"%s","review_stage":"cross","cross_review":true,"evaluator_executor":"codex","generator_executor":"claude"}\n' "${sprint_id}" "${result_path}" >> .sfs-local/events.jsonl
passed_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" implement "slice")"
case "${passed_out}" in
  *"plan review: pass"* ) ;;
  *) fail "passed review should allow implement: ${passed_out}" ;;
esac

setup_project "${TMP_DIR}/latest-partial-blocks"
sprint_id="$(cat .sfs-local/current-sprint)"
mkdir -p .sfs-local/tmp/review-runs
pass_path=".sfs-local/tmp/review-runs/gate3-pass.md"
partial_path=".sfs-local/tmp/review-runs/gate3-partial.md"
printf 'Verdict: pass\nEvidence checked: old plan.md\n' > "${pass_path}"
printf 'Verdict: partial\nRequired actions: rework plan\n' > "${partial_path}"
printf '{"ts":"2026-05-07T00:01:00+09:00","type":"review_run","sprint_id":"%s","gate_id":"G1","output_path":"%s","review_stage":"cross","cross_review":true,"evaluator_executor":"codex","generator_executor":"claude"}\n' "${sprint_id}" "${pass_path}" >> .sfs-local/events.jsonl
printf '{"ts":"2026-05-07T00:02:00+09:00","type":"review_run","sprint_id":"%s","gate_id":"G1","output_path":"%s","evaluator_executor":"codex","generator_executor":"claude"}\n' "${sprint_id}" "${partial_path}" >> .sfs-local/events.jsonl
set +e
partial_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" implement "slice" 2>&1)"
partial_rc=$?
set -e
[[ "${partial_rc}" -eq 8 ]] || fail "latest partial review should block implement, got ${partial_rc}: ${partial_out}"
case "${partial_out}" in
  *"latest Gate 3 review verdict: partial"* ) ;;
  *) fail "blocked output should name latest partial verdict: ${partial_out}" ;;
esac

echo "test-sfs-implement-plan-review-preflight: OK"
