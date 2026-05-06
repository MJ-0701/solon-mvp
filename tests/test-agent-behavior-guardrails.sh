#!/usr/bin/env bash
# SFS 에이전트 행동 가드레일이 런타임 컨텍스트와 어댑터에 남아 있는지 검증한다.
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

  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

kernel="${DIST_DIR}/templates/.sfs-local-template/context/kernel.md"
brainstorm="${DIST_DIR}/templates/.sfs-local-template/context/commands/brainstorm.md"
plan="${DIST_DIR}/templates/.sfs-local-template/context/commands/plan.md"
implement="${DIST_DIR}/templates/.sfs-local-template/context/commands/implement.md"
review="${DIST_DIR}/templates/.sfs-local-template/context/commands/review.md"
model_profiles="${DIST_DIR}/templates/.sfs-local-template/model-profiles.yaml"
researcher="${DIST_DIR}/templates/.sfs-local-template/personas/researcher.md"

assert_contains "${kernel}" "surface material assumptions" "kernel assumptions"
assert_contains "${kernel}" "minimum useful slice" "kernel simplicity"
assert_contains "${kernel}" "Read actual files, command output, and error logs" "kernel evidence"
assert_contains "${kernel}" "do not end Korean sentences with a closing colon" "kernel Korean output"
assert_contains "${kernel}" "current SFS workbench artifacts" "kernel SFS notes"
assert_contains "${kernel}" "Multi-agent work is thin supervision" "kernel thin supervision"
assert_contains "${kernel}" "Decision questions must be self-contained" "kernel decision clarity"

assert_contains "${brainstorm}" "docs/solon/domain-map.md" "brainstorm domain map"
assert_contains "${brainstorm}" "read-only researcher" "brainstorm researcher"

assert_contains "${plan}" "explicit non-goals" "plan tradeoffs"
assert_contains "${plan}" "verify by ..." "plan verification"
assert_contains "${plan}" "mandatory" "plan no root notes"
assert_contains "${plan}" "root-level" "plan no root notes"
assert_contains "${plan}" "sfs review --gate 3" "plan pre-implementation review"
assert_contains "${plan}" "docs/solon/domain-map.md" "plan domain map"
assert_contains "${plan}" "do not end with" "plan decision clarity"
assert_contains "${plan}" 'unexplained `Q1`' "plan unexplained Q1 guardrail"

assert_contains "${implement}" "Keep changes surgical" "implement surgical changes"
assert_contains "${implement}" "speculative flexibility" "implement simplicity"
assert_contains "${implement}" "dirty" "implement worktree respect"
assert_contains "${implement}" "worktree changes" "implement worktree respect"
assert_contains "${implement}" "full error/log output" "implement read errors"
assert_contains "${implement}" "smallest relevant test" "implement verification"
assert_contains "${implement}" ".sfs-local/personas/researcher.md" "implement researcher"
assert_contains "${implement}" "files_scope explicit and disjoint" "implement worker scope"

assert_contains "${review}" "Review actual diff, files, test output, and logs" "review evidence"
assert_contains "${review}" "Flag overengineering" "review overengineering"
assert_contains "${review}" "exact verification command/result" "review verification evidence"
assert_contains "${review}" "self-validation risk" "review self-validation"

assert_contains "${researcher}" "default_executor: gemini" "researcher default executor"
assert_contains "${researcher}" "Do not edit production files" "researcher read-only"
assert_contains "${researcher}" "docs/solon/domain-map.md" "researcher domain map"

assert_contains "${model_profiles}" "research_high" "model profiles research tier"
assert_contains "${model_profiles}" "researcher: research_high" "model profiles researcher policy"
assert_contains "${model_profiles}" ".sfs-local/personas/researcher.md" "model profiles researcher persona"

adapter_files=(
  "${DIST_DIR}/templates/CLAUDE.md.template"
  "${DIST_DIR}/templates/AGENTS.md.template"
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
  assert_contains "${file}" "surface material assumptions" "adapter guardrail ${file}"
  assert_contains "${file}" "report exact evidence" "adapter evidence ${file}"
  assert_contains "${file}" "Decision questions must be self-contained" "adapter decision clarity ${file}"
done

echo "test-agent-behavior-guardrails: OK"
