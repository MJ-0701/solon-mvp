#!/usr/bin/env bash
# tests/test-process-self-audit-guardrails.sh — BWU-12 process self-audit and anti-yak cadence lock.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONTEXT_DIR="${DIST_DIR}/templates/.sfs-local-template/context"
TEMPLATE_DIR="${DIST_DIR}/templates/.sfs-local-template"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

assert_not_contains() {
  local file="$1" pattern="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  if grep -Eq -- "${pattern}" "${file}"; then
    fail "${label}: unexpected pattern '${pattern}'"
  fi
}

lean_en="${CONTEXT_DIR}/policies/lean-procedure-refactor-pack.md"
lean_ko="${CONTEXT_DIR}/policies/lean-procedure-refactor-pack.ko.md"
kernel="${CONTEXT_DIR}/kernel.md"
review="${CONTEXT_DIR}/commands/review.md"
retro_template="${TEMPLATE_DIR}/sprint-templates/retro.md"
dispatch="${TEMPLATE_DIR}/scripts/sfs-dispatch.sh"

for file in "${lean_en}" "${lean_ko}"; do
  assert_contains "${file}" "Process self-audit" "canonical self-audit ${file}"
  assert_contains "${file}" "anti-yak cadence" "anti-yak cadence ${file}"
  assert_contains "${file}" "3 meta-system WUs" "3-to-1 cadence ${file}"
  assert_contains "${file}" "1 user-outcome WU" "user outcome cadence ${file}"
  assert_contains "${file}" "waiver" "cadence waiver ${file}"
done
assert_contains "${lean_en}" "Does this gate or ceremony still serve the current objective" "EN objective question"
assert_contains "${lean_ko}" "이 gate 또는 ceremony 가 현재 objective" "KO objective question"

assert_contains "${kernel}" "Process self-audit is ambient" "kernel self-audit hook"
assert_contains "${kernel}" "lean-procedure-refactor-pack" "kernel lean SSoT pointer"
assert_contains "${kernel}" "3 meta-system WUs" "kernel anti-yak cadence"

assert_contains "${review}" "process self-audit" "review self-audit hook"
assert_contains "${review}" "gate or ceremony still serves the current objective" "review objective question"
assert_contains "${review}" "anti-yak cadence" "review anti-yak cadence"

assert_contains "${retro_template}" "## 4.1 Process self-audit / anti-yak cadence" "retro cadence section"
assert_contains "${retro_template}" "Does this gate or ceremony still serve the current objective" "retro objective question"
assert_contains "${retro_template}" "3 meta-system WUs" "retro meta-system cadence"
assert_contains "${retro_template}" "1 user-outcome WU" "retro user-outcome cadence"

assert_not_contains "${dispatch}" "anti-yak|process-self-audit|self-audit" "no new lifecycle command in dispatcher"
if find "${TEMPLATE_DIR}/scripts" -maxdepth 1 -type f \( -name '*anti-yak*' -o -name '*self-audit*' \) | grep -q .; then
  fail "process self-audit must stay in routed policy/template hooks, not a new command script"
fi

echo "test-process-self-audit-guardrails: OK"
