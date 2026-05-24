#!/usr/bin/env bash
# 6본부 council 과 fresh-session autopilot 이 런타임/어댑터 표면에 배포되는지 검증한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

context="${DIST_DIR}/templates/.sfs-local-template/context"
kernel="${context}/kernel.md"
index="${context}/_INDEX.md"
session_guard="${context}/policies/session-continuation-guard.md"
division_policy="${context}/policies/division-subagent-council.md"
router="${context}/policies/knowledge-pack-router.md"
divisions="${DIST_DIR}/templates/.sfs-local-template/divisions.yaml"
profiles="${DIST_DIR}/templates/.sfs-local-template/model-profiles.yaml"

assert_contains "${index}" "policies/division-subagent-council.md" "index routes division council"
assert_contains "${kernel}" "Division sub-agent council is always-on" "kernel division council"
assert_contains "${kernel}" "Actual parallel worker lanes remain opt-in" "kernel parallel opt-in"
assert_contains "${kernel}" "fresh-session transfer is autopilot" "kernel fresh transfer"
assert_contains "${session_guard}" "Fresh-session transfer is autopilot after a trigger" "session guard autopilot"
assert_contains "${session_guard}" "host clear/new-session" "session guard host transfer"
assert_contains "${session_guard}" "Do not ask the user to choose same-session vs fresh-session" "session guard no user choice"
assert_contains "${division_policy}" "always-on conceptual sub-agents" "division policy concept"
assert_contains "${division_policy}" "activation controls depth/escalation, not participation" "division policy activation boundary"
assert_contains "${division_policy}" "division_subagent_ledger" "division policy ledger"
assert_contains "${router}" "activation_state controls read-depth" "router activation depth"
assert_contains "${router}" "not whether strategy-pm/dev/QA/design/infra/taxonomy participate" "router participation"
assert_contains "${divisions}" "activation_state controls depth" "divisions depth"
assert_contains "${divisions}" "not whether a division participates" "divisions participation"
assert_contains "${profiles}" "division_council" "profiles role boundary"
assert_contains "${profiles}" "mode: \"always_on\"" "profiles always_on mode"
assert_contains "${profiles}" "Fresh-session transfer is autopilot" "profiles fresh transfer"

command_files=(
  "${context}/commands/brainstorm.md"
  "${context}/commands/plan.md"
  "${context}/commands/implement.md"
  "${context}/commands/review.md"
)

for file in "${command_files[@]}"; do
  assert_contains "${file}" "division_subagent_ledger" "command ledger ${file}"
done
assert_contains "${context}/commands/loop.md" "Do not ask same-session vs fresh-session" "loop no continuation question"

template_files=(
  "${DIST_DIR}/templates/.sfs-local-template/sprint-templates/brainstorm.md"
  "${DIST_DIR}/templates/.sfs-local-template/sprint-templates/plan.md"
  "${DIST_DIR}/templates/.sfs-local-template/sprint-templates/implement.md"
  "${DIST_DIR}/templates/.sfs-local-template/sprint-templates/review.md"
)

for file in "${template_files[@]}"; do
  assert_contains "${file}" "Division Sub-agent Ledger" "sprint template ledger ${file}"
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
  assert_contains "${file}" "Division sub-agent council is always-on" "adapter division council ${file}"
  assert_contains "${file}" "Fresh-session transfer is autopilot" "adapter fresh transfer ${file}"
done

assert_contains "${DIST_DIR}/templates/SFS.md.template" "Division sub-agent council is always-on" "SFS template division council"
assert_contains "${DIST_DIR}/templates/SFS.md.template" "fresh-session transfer is autopilot" "SFS template fresh transfer"

echo "test-division-subagent-continuation-guard: OK"
