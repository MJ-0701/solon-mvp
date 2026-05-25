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

assert_not_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  if grep -Fq -- "${needle}" "${file}"; then
    fail "${label}: unexpected '${needle}'"
  fi
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
assert_contains "${kernel}" "fresh-session transfer is lossless autopilot" "kernel fresh transfer"
assert_contains "${kernel}" "resume immediately" "kernel immediate resume"
assert_contains "${kernel}" "Do not call bare clear" "kernel no bare clear"
assert_contains "${session_guard}" "Fresh-session transfer is lossless autopilot after a trigger" "session guard autopilot"
assert_contains "${session_guard}" "durably" "session guard durable"
assert_contains "${session_guard}" "host-owned transition+resume" "session guard transition resume"
assert_contains "${session_guard}" "resumes immediately in the fresh session" "session guard immediate resume"
assert_contains "${session_guard}" "Do not call a bare clear" "session guard no bare clear"
assert_contains "${session_guard}" "do not ask the user to type" "session guard no user clear"
assert_not_contains "${session_guard}" "host clear/new-session" "session guard stale host clear wording"
assert_contains "${division_policy}" "always-on conceptual sub-agents" "division policy concept"
assert_contains "${division_policy}" "activation controls depth/escalation, not participation" "division policy activation boundary"
assert_contains "${division_policy}" "division_subagent_ledger" "division policy ledger"
assert_contains "${router}" "activation_state controls read-depth" "router activation depth"
assert_contains "${router}" "not whether strategy-pm/dev/QA/design/infra/taxonomy participate" "router participation"
assert_contains "${divisions}" "activation_state controls depth" "divisions depth"
assert_contains "${divisions}" "not whether a division participates" "divisions participation"
assert_contains "${profiles}" "division_council" "profiles role boundary"
assert_contains "${profiles}" "mode: \"always_on\"" "profiles always_on mode"
assert_contains "${profiles}" "Fresh-session transfer is lossless autopilot" "profiles fresh transfer"
assert_contains "${profiles}" "resume immediately" "profiles immediate resume"
assert_contains "${profiles}" "never call bare clear" "profiles no bare clear"

command_files=(
  "${context}/commands/brainstorm.md"
  "${context}/commands/plan.md"
  "${context}/commands/implement.md"
  "${context}/commands/review.md"
)

for file in "${command_files[@]}"; do
  assert_contains "${file}" "division_subagent_ledger" "command ledger ${file}"
done
assert_contains "${context}/commands/loop.md" "Do not ask same-session vs" "loop no continuation question"
assert_contains "${context}/commands/loop.md" "do not ask the" "loop no user clear"
assert_contains "${context}/commands/loop.md" "durable compact handoff or" "loop durable handoff"
assert_contains "${context}/commands/loop.md" "resume immediately in the fresh session" "loop immediate resume"

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
  assert_contains "${file}" "Fresh-session transfer is lossless autopilot" "adapter fresh transfer ${file}"
  assert_contains "${file}" "resume immediately" "adapter immediate resume ${file}"
  assert_contains "${file}" "never call bare clear" "adapter no bare clear ${file}"
  assert_contains "${file}" 'Never ask user to type `/clear`' "adapter no user clear ${file}"
  assert_not_contains "${file}" "use host clear/new-session" "adapter no stale host clear ${file}"
done

assert_contains "${DIST_DIR}/templates/SFS.md.template" "Division sub-agent council is always-on" "SFS template division council"
assert_contains "${DIST_DIR}/templates/SFS.md.template" "fresh-session transfer is lossless autopilot" "SFS template fresh transfer"
assert_contains "${DIST_DIR}/templates/SFS.md.template" "handoff/transfer capsule" "SFS template durable transfer"
assert_contains "${DIST_DIR}/templates/SFS.md.template" "resume immediately" "SFS template immediate resume"
assert_contains "${DIST_DIR}/templates/SFS.md.template" 'Never ask the user to type' "SFS template no user clear"

echo "test-division-subagent-continuation-guard: OK"
