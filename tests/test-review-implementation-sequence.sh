#!/usr/bin/env bash
# Gate 6 implementation review must be self -> cross CPO -> GitHub @codex last.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-review-implementation-sequence.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local haystack="$1" needle="$2" label="$3"
  case "${haystack}" in
    *"${needle}"*) ;;
    *) fail "${label}: missing '${needle}' in: ${haystack}" ;;
  esac
}

assert_file_contains() {
  local file="$1" needle="$2" label="$3"
  local normalized
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" \
    || {
      normalized="$(tr '\n' ' ' <"${file}" | sed 's/[[:space:]][[:space:]]*/ /g')"
      printf '%s' "${normalized}" | grep -Fq -- "${needle}"
    } \
    || fail "${label}: missing '${needle}'"
}

assert_file_not_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  ! grep -Fq -- "${needle}" "${file}" \
    || fail "${label}: unexpected '${needle}'"
}

run_sfs() {
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" "$@"
}

setup_project() {
  local name="$1"
  origin="${TMP_DIR}/${name}-origin.git"
  work="${TMP_DIR}/${name}-work"

  git init --bare -q "${origin}"
  mkdir -p "${work}"
  cd "${work}"
  git init -q
  git branch -M main
  git config user.email sfs-test@example.invalid
  git config user.name "SFS Test"
  git remote add origin "${origin}"
  printf '# Review Sequence Project\n' > README.md
  git add README.md
  git commit -qm 'initial'
  git push -u origin HEAD >/dev/null

  run_sfs init --layout thin --yes >/dev/null
  git add SFS.md CLAUDE.md AGENTS.md GEMINI.md .gitignore
  git commit -qm 'install sfs'
  git push >/dev/null
  run_sfs start "implementation review order" >/dev/null
  sprint_id="$(cat .sfs-local/current-sprint)"
  mkdir -p src .sfs-local/tmp/review-runs
  printf '{"ts":"2026-05-21T20:00:00+09:00","type":"implement_open","sprint_id":"%s","path":".sfs-local/sprints/%s/implement.md"}\n' "${sprint_id}" "${sprint_id}" >> .sfs-local/events.jsonl
}

add_review_pass() {
  local stage="$1" result_path="$2" fallback="${3:-false}"
  printf 'Verdict: pass\nReview stage: %s\n' "${stage}" > "${result_path}"
  if [[ "${fallback}" == "true" ]]; then
    printf 'Self-CPO fallback: true\nFallback reason: no other agent subscription\n' >> "${result_path}"
    printf '{"ts":"2026-05-21T20:05:00+09:00","type":"review_run","sprint_id":"%s","gate_id":"G4","output_path":"%s","review_stage":"%s","cross_review":false,"self_cpo_fallback":true,"fallback_reason":"no_other_agent_subscription"}\n' "${sprint_id}" "${result_path}" "${stage}" >> .sfs-local/events.jsonl
  else
    local cross=false
    [[ "${stage}" == "cross" ]] && cross=true
    printf '{"ts":"2026-05-21T20:05:00+09:00","type":"review_run","sprint_id":"%s","gate_id":"G4","output_path":"%s","review_stage":"%s","cross_review":%s}\n' "${sprint_id}" "${result_path}" "${stage}" "${cross}" >> .sfs-local/events.jsonl
  fi
}

review_context="${DIST_DIR}/templates/.sfs-local-template/context/commands/review.md"
implement_context="${DIST_DIR}/templates/.sfs-local-template/context/commands/implement.md"
review_script="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-review.sh"
commit_script="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-commit.sh"

assert_file_contains "${review_context}" "Gate 6 implementation review order is self-CPO first, then cross CPO, then" "review context order"
assert_file_contains "${review_context}" "count GitHub @codex review during brainstorm or Gate 3 plan review" "review context GitHub plan boundary"
assert_file_contains "${implement_context}" "sfs review --gate 6 --stage self" "implement context self stage"
assert_file_contains "${implement_context}" "sfs review --gate 6 --stage cross" "implement context cross stage"
assert_file_contains "${implement_context}" "GitHub @codex applies only after implementation" "implement context GitHub boundary"
assert_file_contains "${review_script}" "belongs last, after" "review help GitHub last"
assert_file_contains "${review_script}" "both self-CPO PASS and cross CPO PASS when available" "review help GitHub after cross"
assert_file_not_contains "${review_script}" "between self and cross when available" "review help no old GitHub order"
assert_file_contains "${review_script}" "GitHub @codex review is post-implementation only" "review prompt GitHub boundary"
assert_file_contains "${commit_script}" "Gate 6 self-CPO review required before pushing product-code" "commit guard self"
assert_file_contains "${commit_script}" "Gate 6 cross CPO review or valid self-CPO fallback required before pushing product-code" "commit guard cross"

setup_project "blocked"
printf 'hello\n' > src/app.txt
set +e
blocked_out="$(run_sfs commit apply --group product-code -m "feat: add app" 2>&1)"
blocked_rc=$?
set -e
[[ "${blocked_rc}" -eq 5 ]] || fail "missing self-CPO should exit 5, got ${blocked_rc}: ${blocked_out}"
assert_contains "${blocked_out}" "Gate 6 self-CPO review required before pushing product-code" "self preflight block"
assert_contains "${blocked_out}" "sfs review --gate 6 --stage self" "self preflight guidance"

add_review_pass "self" ".sfs-local/tmp/review-runs/gate6-self.md"
set +e
self_only_out="$(run_sfs commit apply --group product-code -m "feat: add app" 2>&1)"
self_only_rc=$?
set -e
[[ "${self_only_rc}" -eq 5 ]] || fail "missing cross CPO should exit 5, got ${self_only_rc}: ${self_only_out}"
assert_contains "${self_only_out}" "Gate 6 cross CPO review or valid self-CPO fallback required before pushing product-code" "cross preflight block"
assert_contains "${self_only_out}" "GitHub @codex PR/code review as the final external evidence" "GitHub last guidance"

add_review_pass "cross" ".sfs-local/tmp/review-runs/gate6-cross.md"
passed_out="$(run_sfs commit apply --group product-code -m "feat: add app")"
assert_contains "${passed_out}" "pre-push review: Gate 6 self-CPO PASS" "self pre-push evidence"
assert_contains "${passed_out}" "pre-push review: Gate 6 cross/fallback PASS" "cross pre-push evidence"
assert_contains "${passed_out}" "pushed:" "push success"

setup_project "fallback"
printf 'fallback\n' > src/fallback.txt
add_review_pass "self" ".sfs-local/tmp/review-runs/gate6-self-fallback.md" "true"
fallback_out="$(run_sfs commit apply --group product-code -m "feat: add fallback")"
assert_contains "${fallback_out}" "pre-push review: Gate 6 self-CPO PASS" "fallback self evidence"
assert_contains "${fallback_out}" "pre-push review: Gate 6 cross/fallback PASS" "fallback cross slot evidence"
assert_contains "${fallback_out}" "pushed:" "fallback push success"

echo "test-review-implementation-sequence: OK"
