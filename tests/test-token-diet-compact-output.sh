#!/usr/bin/env bash
# Token Diet compact output fixture contract를 검증한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIXTURE_DIR="${SCRIPT_DIR}/fixtures/token-diet"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

bytes() {
  wc -c < "$1" | tr -d ' '
}

assert_contains() {
  local file="$1"
  local needle="$2"
  local label="$3"

  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

assert_not_contains() {
  local file="$1"
  local needle="$2"
  local label="$3"

  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  if grep -Fq -- "${needle}" "${file}"; then
    fail "${label}: unexpected '${needle}'"
  fi
}

check_common_contract() {
  local file="$1"
  local label="$2"

  assert_contains "${file}" "summary:" "${label} summary"
  assert_contains "${file}" "source:" "${label} source trace"
  assert_contains "${file}" "verification:" "${label} verification trace"
}

check_reduction() {
  local label="$1"
  local minimum="$2"
  local normal="${FIXTURE_DIR}/${label}.normal.md"
  local compact="${FIXTURE_DIR}/${label}.compact.md"
  local normal_bytes compact_bytes saved percent stretch

  [[ -f "${normal}" ]] || fail "${label}: missing normal fixture"
  [[ -f "${compact}" ]] || fail "${label}: missing compact fixture"

  normal_bytes="$(bytes "${normal}")"
  compact_bytes="$(bytes "${compact}")"
  [[ "${normal_bytes}" -gt 0 ]] || fail "${label}: normal fixture is empty"
  [[ "${compact_bytes}" -lt "${normal_bytes}" ]] || fail "${label}: compact is not smaller"

  saved=$((normal_bytes - compact_bytes))
  percent=$((saved * 100 / normal_bytes))
  [[ "${percent}" -ge "${minimum}" ]] \
    || fail "${label}: saved ${percent}%, expected at least ${minimum}%"

  stretch="no"
  if [[ "${percent}" -ge 65 ]]; then
    stretch="yes"
  fi
  printf 'token-diet:%s normal=%s compact=%s saved=%s%% stretch65=%s\n' \
    "${label}" "${normal_bytes}" "${compact_bytes}" "${percent}" "${stretch}"
  check_common_contract "${compact}" "${label}"
}

check_safety_contract() {
  local file="$1"
  local label="$2"

  check_common_contract "${file}" "${label}"
  assert_contains "${file}" "warning: DATA-LOSS" "${label} data-loss warning"
  assert_contains "${file}" "severity: BLOCKING" "${label} blocking severity"
  assert_contains "${file}" "required-action: take backup before destructive step" "${label} required action"
  assert_contains "${file}" "ask-user-boundary: destructive action needs explicit user approval" "${label} ask-user boundary"
}

check_review_contract() {
  local file="$1"
  local label="$2"

  check_common_contract "${file}" "${label}"
  assert_contains "${file}" "file:" "${label} file path"
  assert_contains "${file}" "line:" "${label} line reference"
  assert_contains "${file}" "verdict:" "${label} verdict"
  assert_contains "${file}" "evidence:" "${label} evidence"
  assert_contains "${file}" "risk:" "${label} risk"
}

check_decision_contract() {
  local file="$1"
  local label="$2"

  check_common_contract "${file}" "${label}"
  assert_contains "${file}" "decision:" "${label} decision"
  assert_contains "${file}" "why:" "${label} why"
  assert_contains "${file}" "recommendation:" "${label} recommendation"
  assert_contains "${file}" "alternatives:" "${label} alternatives"
  assert_contains "${file}" "consequence:" "${label} consequence"
}

[[ -d "${FIXTURE_DIR}" ]] || fail "missing fixture dir ${FIXTURE_DIR}"

check_reduction "routine-status" 40
check_reduction "plan-summary" 40
check_reduction "release-check" 40

check_review_contract "${FIXTURE_DIR}/review-finding.compact.md" "review finding"
check_safety_contract "${FIXTURE_DIR}/safety-warning.compact.md" "safety warning"
check_decision_contract "${FIXTURE_DIR}/decision-brief.compact.md" "decision brief"

assert_not_contains "${FIXTURE_DIR}/bad-review-missing-evidence.compact.md" \
  "evidence:" "bad review fixture intentionally misses evidence"
assert_not_contains "${FIXTURE_DIR}/bad-safety-missing-warning.compact.md" \
  "warning: DATA-LOSS" "bad safety fixture intentionally misses warning"
assert_not_contains "${FIXTURE_DIR}/bad-decision-missing-alternatives.compact.md" \
  "alternatives:" "bad decision fixture intentionally misses alternatives"

assert_not_contains "${FIXTURE_DIR}/routine-status.compact.md" "Caveman default" "no default persona"
assert_not_contains "${FIXTURE_DIR}/plan-summary.compact.md" "one-file-one-function" "no filefunc transplant"

echo "test-token-diet-compact-output: OK"
