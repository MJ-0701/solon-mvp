#!/usr/bin/env bash
# sfs implement 의 Single Agent 기본값과 parallel agent 선택 계약을 검증한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-implement-agent-modes.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1" needle="$2" label="$3"
  grep -Fq "${needle}" "${file}" || fail "${label}: missing ${needle}"
}

run_sfs() {
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" "$@"
}

setup_project() {
  local dir="$1"
  mkdir -p "${dir}"
  cd "${dir}"
  git init -q
  printf '# Agent Modes Project\n' > README.md
  git add README.md
  git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'
  run_sfs init --layout thin --yes >/dev/null
  run_sfs start "agent mode implement" >/dev/null
  run_sfs brainstorm --simple "raw" >/dev/null
  run_sfs plan >/dev/null

  local sprint_id result_path
  sprint_id="$(cat .sfs-local/current-sprint)"
  mkdir -p .sfs-local/tmp/review-runs
  result_path=".sfs-local/tmp/review-runs/gate3-plan-review.md"
  printf 'Verdict: pass\nReview stage: cross\nEvidence checked: plan.md\n' > "${result_path}"
  printf '{"ts":"2026-05-07T01:30:00+09:00","type":"review_run","sprint_id":"%s","gate_id":"G1","output_path":"%s","review_stage":"cross","cross_review":true,"evaluator_executor":"codex","generator_executor":"claude"}\n' "${sprint_id}" "${result_path}" >> .sfs-local/events.jsonl
}

setup_project "${TMP_DIR}/help"
help_out="$(run_sfs implement --help)"
case "${help_out}" in
  *"AC/ADR subset ownership"* ) ;;
  *) fail "implement help should name AC/ADR subset ownership: ${help_out}" ;;
esac
case "${help_out}" in
  *"expected tests/evidence"* ) ;;
  *) fail "implement help should name expected tests/evidence: ${help_out}" ;;
esac
case "${help_out}" in
  *"lane output report path"* ) ;;
  *) fail "implement help should name lane output report path: ${help_out}" ;;
esac
case "${help_out}" in
  *"merge/conflict policy"* ) ;;
  *) fail "implement help should name merge/conflict policy: ${help_out}" ;;
esac

setup_project "${TMP_DIR}/single"
single_out="$(run_sfs implement "single slice")"
case "${single_out}" in
  *"agent mode: single (default)"* ) ;;
  *) fail "single output should name default agent mode: ${single_out}" ;;
esac
case "${single_out}" in
  *"optional parallel: sfs implement --agent-mode parallel --agents codex,claude[,gemini]"* ) ;;
  *) fail "single output should advertise optional parallel command: ${single_out}" ;;
esac
case "${single_out}" in
  *"after implementation run: sfs review --gate 6"* ) ;;
  *) fail "single output should require post-implement review: ${single_out}" ;;
esac
sprint_id="$(cat .sfs-local/current-sprint)"
single_impl=".sfs-local/sprints/${sprint_id}/implement.md"
assert_contains "${single_impl}" "agent_mode: single" "single implement mode"
assert_contains "${single_impl}" "optional parallel lane" "single optional lane guidance"
assert_contains "${single_impl}" "acceptance ledger" "single acceptance ledger guidance"
assert_contains "${single_impl}" 'sfs review --gate 6' "single review handoff"
assert_contains .sfs-local/events.jsonl '"agent_mode":"single"' "single event mode"

setup_project "${TMP_DIR}/parallel"
parallel_out="$(run_sfs implement --agent-mode parallel --agents codex,claude "parallel slice")"
case "${parallel_out}" in
  *"agent mode: parallel (codex,claude)"* ) ;;
  *) fail "parallel output should name agents: ${parallel_out}" ;;
esac
case "${parallel_out}" in
  *"cross review required before Gate 6 PASS"* ) ;;
  *) fail "parallel output should require cross review: ${parallel_out}" ;;
esac
case "${parallel_out}" in
  *"after implementation run: sfs review --gate 6"* ) ;;
  *) fail "parallel output should require Gate 6 review: ${parallel_out}" ;;
esac
sprint_id="$(cat .sfs-local/current-sprint)"
parallel_impl=".sfs-local/sprints/${sprint_id}/implement.md"
assert_contains "${parallel_impl}" "agent_mode: parallel" "parallel implement mode"
assert_contains "${parallel_impl}" "split rule: use multiple agents only when each lane has disjoint files_scope" "parallel split rule"
assert_contains "${parallel_impl}" "lane AC/ADR subset" "parallel AC/ADR ownership"
assert_contains "${parallel_impl}" "expected tests/evidence" "parallel expected evidence"
assert_contains "${parallel_impl}" "output report path" "parallel output report path"
assert_contains "${parallel_impl}" "merge/conflict policy" "parallel merge conflict policy"
assert_contains "${parallel_impl}" "proposed commit message" "parallel commit message guard"
assert_contains "${parallel_impl}" "native/workspace language" "parallel native commit language"
assert_contains "${parallel_impl}" "cross review between agents is required" "parallel cross review"
assert_contains .sfs-local/events.jsonl '"agent_mode":"parallel"' "parallel event mode"
assert_contains .sfs-local/events.jsonl '"agents":"codex,claude"' "parallel event agents"

setup_project "${TMP_DIR}/invalid-one-agent"
set +e
one_agent_out="$(run_sfs implement --agent-mode parallel --agents codex "bad split" 2>&1)"
one_agent_rc=$?
set -e
[[ "${one_agent_rc}" -eq 99 ]] || fail "parallel one-agent split should exit 99, got ${one_agent_rc}: ${one_agent_out}"
case "${one_agent_out}" in
  *"parallel agent mode requires at least two agents"* ) ;;
  *) fail "one-agent error should explain split requirement: ${one_agent_out}" ;;
esac

set +e
bad_mode_out="$(run_sfs implement --agent-mode swarm "bad mode" 2>&1)"
bad_mode_rc=$?
set -e
[[ "${bad_mode_rc}" -eq 99 ]] || fail "unknown agent mode should exit 99, got ${bad_mode_rc}: ${bad_mode_out}"
case "${bad_mode_out}" in
  *"unknown agent mode"* ) ;;
  *) fail "bad mode error should explain valid modes: ${bad_mode_out}" ;;
esac

echo "test-sfs-implement-agent-modes: OK"
