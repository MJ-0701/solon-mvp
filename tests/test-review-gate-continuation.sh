#!/usr/bin/env bash
# 외부 리뷰 PASS 이후 SFS gate continuation 가드 회귀 테스트.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1"
  local needle="$2"
  local label="$3"
  local normalized

  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" \
    || {
      normalized="$(tr '\n' ' ' <"${file}" | sed 's/[[:space:]][[:space:]]*/ /g')"
      printf '%s' "${normalized}" | grep -Fq -- "${needle}"
    } \
    || fail "${label}: missing '${needle}'"
}

kernel="${DIST_DIR}/templates/.sfs-local-template/context/kernel.md"
review="${DIST_DIR}/templates/.sfs-local-template/context/commands/review.md"
implement="${DIST_DIR}/templates/.sfs-local-template/context/commands/implement.md"
capture="${DIST_DIR}/templates/.sfs-local-template/context/commands/capture.md"
context_guard="${DIST_DIR}/templates/.sfs-local-template/context/policies/context-pollution-guard.md"
review_script="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-review.sh"
cpo="${DIST_DIR}/templates/.sfs-local-template/personas/cpo-evaluator.md"
model_profiles="${DIST_DIR}/templates/.sfs-local-template/model-profiles.yaml"

assert_contains "${kernel}" "External review/check PASS is a continuation trigger, not a stopping point" "kernel continuation trigger"
assert_contains "${kernel}" "Codex, Claude, Gemini, and future LLM agents" "kernel all agents"
assert_contains "${kernel}" "sfs review --sprint <id> --gate <n>" "kernel closed sprint command"
assert_contains "${kernel}" 'hand-edit `.sfs-local/current-sprint`' "kernel no manual pointer restore"

assert_contains "${review}" "After any external GitHub/@codex/PR/check PASS, do not stop at PASS" "review no stop after pass"
assert_contains "${review}" "self-CPO first, cross-review after self-CPO PASS" "review self before cross after pass"
assert_contains "${review}" "GitHub @codex review is post-implementation only" "review GitHub post implementation only"
assert_contains "${review}" "Gate 6 implementation review order is self-CPO first, then cross CPO, then" "review Gate 6 order"
assert_contains "${review}" "External review/check PASS is a continuation trigger, not a stopping point" "review continuation trigger"
assert_contains "${review}" "Do not end on \"PASS\" without the next SFS command" "review next action required"

assert_contains "${implement}" "sfs review --gate 6 --stage self" "implement self stage"
assert_contains "${implement}" "sfs review --gate 6 --stage cross" "implement cross stage"
assert_contains "${implement}" "GitHub @codex applies only after implementation" "implement GitHub after implementation"
assert_contains "${implement}" "GitHub @codex comes" "implement GitHub after cross"

assert_contains "${capture}" "external GitHub/@codex/PR/check review" "capture external review evidence"
assert_contains "${capture}" "capture the accepted evidence plus the next SFS command" "capture next command"
assert_contains "${context_guard}" "external PASS evidence and exact next SFS command" "context guard compact continuation"

assert_contains "${review_script}" "External GitHub/@codex/PR/check PASS is a continuation trigger" "review prompt continuation"
assert_contains "${cpo}" "External review/check PASS is a continuation trigger" "cpo continuation"
assert_contains "${model_profiles}" "External review PASS is a continuation trigger" "model profiles continuation"

docs=(
  "${DIST_DIR}/GUIDE.md"
  "${DIST_DIR}/docs/en/guide.md"
  "${DIST_DIR}/docs/ko/current-product-shape.md"
  "${DIST_DIR}/docs/en/current-product-shape.md"
  "${DIST_DIR}/docs/ko/index.md"
  "${DIST_DIR}/docs/en/index.md"
)

for file in "${docs[@]}"; do
  assert_contains "${file}" "continuation trigger" "docs continuation trigger ${file}"
  assert_contains "${file}" "self-CPO" "docs self CPO ${file}"
done

adapter_files=(
  "${DIST_DIR}/templates/AGENTS.md.template"
  "${DIST_DIR}/templates/CLAUDE.md.template"
  "${DIST_DIR}/templates/GEMINI.md.template"
  "${DIST_DIR}/templates/codex-skill/SKILL.md"
  "${DIST_DIR}/templates/.agents/skills/sfs/SKILL.md"
  "${DIST_DIR}/templates/.claude/commands/sfs.md"
  "${DIST_DIR}/templates/.gemini/commands/sfs.toml"
  "${DIST_DIR}/templates/.codex/prompts/sfs.md"
  "${DIST_DIR}/commands/sfs.toml"
  "${DIST_DIR}/plugins/solon/commands/sfs.md"
)

for file in "${adapter_files[@]}"; do
  assert_contains "${file}" "External review/check PASS is a continuation trigger" "adapter continuation trigger ${file}"
  assert_contains "${file}" "Codex, Claude, Gemini, and future LLM agents" "adapter all agents ${file}"
  assert_contains "${file}" "GitHub" "adapter GitHub boundary ${file}"
  assert_contains "${file}" "post-implementation only" "adapter GitHub post implementation ${file}"
  assert_contains "${file}" "sfs review --gate 6 --stage self" "adapter Gate 6 self stage ${file}"
  assert_contains "${file}" "sfs review --gate 6 --stage cross" "adapter Gate 6 cross stage ${file}"
done

echo "test-review-gate-continuation: OK"
