#!/usr/bin/env bash
# six-role council participation과 fresh-session autopilot이 런타임/어댑터
# 표면에 배포되는지 검증한다.
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

assert_no_active_six_division_drift() {
  local file="$1" label="$2" drift
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  drift="$(awk '
      /^[[:space:]]*load_when:/ { next }
      /^[[:space:]]*-[[:space:]]*(6 divisions|6본부)[[:space:]]*$/ { next }
      /historical|시점에/ { next }
      { print }
    ' "${file}" |
    sed 's/six-division-council//g' |
    grep -Ein 'six[ -]+((core|organization)[ -]+)?divisions?|6[[:space:]]*본부|6개[[:space:]]+(core[[:space:]]+)?division|six[ -]+division[ -]+ledger|6본부[[:space:]]+(council|ledger|지식팩)' || true)"
  [[ -z "${drift}" ]] || fail "${label}: active six-division organization drift: ${drift}"
}

assert_no_active_public_taxonomy_drift() {
  local file="$1" label="$2" drift
  assert_no_active_six_division_drift "${file}" "${label}"
  drift="$(awk '
      /^[[:space:]]*load_when:/ { next }
      /historical|시점에/ { next }
      { print }
    ' "${file}" |
    grep -Ein 'division[[:space:]]+(sub-agent[[:space:]]+)?council|division[[:space:]]+(row|table)|본부[[:space:]]+(council|ledger|row|표)' || true)"
  [[ -z "${drift}" ]] || fail "${label}: active taxonomy-as-division wording: ${drift}"
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
assert_contains "${kernel}" "Council participation is always-on" "kernel council participation"
assert_contains "${kernel}" "five organization divisions" "kernel five-division boundary"
assert_contains "${kernel}" "taxonomy cross-cutting product function/lens" "kernel taxonomy boundary"
assert_contains "${kernel}" "six required council roles" "kernel six-role requirement"
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
assert_contains "${division_policy}" "six required council participation roles" "council policy roles"
assert_contains "${division_policy}" "Taxonomy is not an organization division" "council policy taxonomy boundary"
assert_contains "${division_policy}" "Activation controls depth/escalation, not participation" "division policy activation boundary"
assert_contains "${division_policy}" "division_subagent_ledger" "division policy ledger"
assert_contains "${router}" "activation_state controls read-depth" "router activation depth"
assert_contains "${router}" "five organization divisions" "router five-division boundary"
assert_contains "${router}" "Taxonomy is the required cross-cutting product function/lens" "router taxonomy boundary"
assert_contains "${router}" "All six are required council roles" "router council roles"
assert_contains "${divisions}" "activation_state controls depth" "divisions depth"
assert_contains "${divisions}" "exactly five organization divisions" "divisions organization boundary"
assert_contains "${divisions}" "taxonomy entry are legacy compatibility keys" "divisions compatibility boundary"
assert_contains "${divisions}" "all six required council roles participate" "divisions participation"
assert_contains "${profiles}" "division_council" "profiles role boundary"
assert_contains "${profiles}" "mode: \"always_on\"" "profiles always_on mode"
assert_contains "${profiles}" "five organization divisions plus the taxonomy cross-cutting product function/lens" "profiles taxonomy boundary"
assert_contains "${profiles}" "all six required council roles" "profiles council roles"
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
  assert_contains "${file}" "Council Participation Ledger" "sprint council ledger ${file}"
  assert_contains "${file}" '조직 division은 `strategy-pm`, `dev`, `QA`, `design`, `infra` 다섯 개다.' "sprint five-division boundary ${file}"
  assert_contains "${file}" '`taxonomy`는 조직 division이 아니라 필수 cross-cutting product function/lens다.' "sprint taxonomy boundary ${file}"
  assert_contains "${file}" "아래 여섯 행은 모두 required council participation role이다." "sprint six-role requirement ${file}"
  assert_contains "${file}" "| council role |" "sprint council role term ${file}"
  assert_not_contains "${file}" "Division Sub-agent Ledger" "sprint taxonomy boundary ${file}"
  assert_not_contains "${file}" "| division |" "sprint legacy division term ${file}"
  for role in strategy-pm dev QA design infra taxonomy; do
    assert_contains "${file}" "| ${role} |" "sprint required council role ${role} ${file}"
  done
done

adapter_files=(
  "${DIST_DIR}/templates/codex-skill/SKILL.md"
  "${DIST_DIR}/templates/.agents/skills/sfs/SKILL.md"
  "${DIST_DIR}/templates/.claude/commands/sfs.md"
  "${DIST_DIR}/templates/.gemini/commands/sfs.toml"
  "${DIST_DIR}/templates/.codex/prompts/sfs.md"
  "${DIST_DIR}/commands/sfs.toml"
  "${DIST_DIR}/plugins/solon/commands/sfs.md"
)

for file in "${adapter_files[@]}"; do
  assert_contains "${file}" "Fresh-session transfer is lossless autopilot" "adapter fresh transfer ${file}"
  assert_contains "${file}" "resume immediately" "adapter immediate resume ${file}"
  assert_contains "${file}" "never call bare clear" "adapter no bare clear ${file}"
  assert_contains "${file}" 'Never ask user to type `/clear`' "adapter no user clear ${file}"
  assert_not_contains "${file}" "use host clear/new-session" "adapter no stale host clear ${file}"
done

runtime_copy_taxonomy_contract_files=(
  "${DIST_DIR}/CLAUDE.md"
  "${adapter_files[@]}"
  "${DIST_DIR}/mcp-server/solon_mcp_server.py"
)

for file in "${runtime_copy_taxonomy_contract_files[@]}"; do
  assert_contains "${file}" "Five organization divisions plus taxonomy, the cross-cutting product function/lens, form six required council roles." "runtime-copy taxonomy contract ${file}"
  assert_not_contains "${file}" "Division sub-agent council is always-on" "runtime-copy legacy division council ${file}"
  assert_not_contains "${file}" "non-Dev divisions" "runtime-copy taxonomy-as-division ${file}"
  assert_no_active_six_division_drift "${file}" "runtime-copy taxonomy organization drift ${file}"
done

active_taxonomy_contract_files=(
  "${divisions}"
  "${index}"
  "${kernel}"
  "${context}/commands/brainstorm.md"
  "${context}/commands/harness.md"
  "${context}/commands/implement.md"
  "${context}/commands/plan.md"
  "${context}/policies/domain-knowledge-assets.md"
  "${context}/policies/domain-knowledge-assets.ko.md"
  "${context}/policies/enterprise-agent-team-pack.md"
  "${context}/policies/enterprise-agent-team-pack.ko.md"
  "${context}/policies/enterprise-plan-council-pack.md"
  "${context}/policies/enterprise-plan-council-pack.ko.md"
  "${router}"
  "${context}/policies/knowledge-pack-router.ko.md"
  "${profiles}"
  "${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-common.sh"
  "${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-division.sh"
  "${DIST_DIR}/scripts/sfs-harness.sh"
)

for file in "${active_taxonomy_contract_files[@]}"; do
  assert_no_active_six_division_drift "${file}" "taxonomy organization drift ${file}"
done

# Scan maintained public/user-facing docs automatically while leaving released
# CHANGELOG/RELEASE-NOTES and dated historical reports outside the active set.
while IFS= read -r file; do
  assert_no_active_public_taxonomy_drift "${file}" "public active taxonomy drift ${file}"
done < <(
  {
    printf '%s\n' "${DIST_DIR}/README.md" "${DIST_DIR}/GUIDE.md"
    find "${DIST_DIR}/README" "${DIST_DIR}/GUIDE" "${DIST_DIR}/docs/en" "${DIST_DIR}/docs/ko" \
      -type f -name '*.md' -print
    find "${DIST_DIR}/docs/maintenance" -type f -name '*.md' ! -name '[0-9]*' -print
  } | LC_ALL=C sort -u
)

assert_contains "${DIST_DIR}/README.md" "5개 조직 본부 + cross-cutting taxonomy lens의 6개 필수 council role" "README taxonomy contract"
assert_contains "${DIST_DIR}/docs/en/index.md" "five organization divisions plus the cross-cutting taxonomy lens as six required council roles" "EN index taxonomy contract"
assert_contains "${DIST_DIR}/docs/ko/index.md" "조직 division은" "KO index organization boundary"
assert_contains "${DIST_DIR}/docs/ko/index.md" "여섯 role은 모두 필수 conceptual council participation role" "KO index council requirement"
assert_contains "${DIST_DIR}/docs/en/current-product-shape/14-divisions-knowledge-packs-review-lenses.md" "Solon has exactly five organization divisions" "EN product taxonomy contract"
assert_contains "${DIST_DIR}/docs/en/current-product-shape/14-divisions-knowledge-packs-review-lenses.md" "All six are required conceptual council participation roles" "EN product council requirement"
assert_contains "${DIST_DIR}/docs/ko/current-product-shape/14-review-lens.md" "조직 division은" "KO product organization boundary"
assert_contains "${DIST_DIR}/docs/ko/current-product-shape/14-review-lens.md" "이 여섯 role은" "KO product council requirement"
assert_contains "${DIST_DIR}/docs/maintenance/release-policy.md" "organization division은 strategy-pm / dev / QA / design / infra 다섯 개다" "maintenance five-division boundary"
assert_contains "${DIST_DIR}/docs/maintenance/release-policy.md" "taxonomy는 조직 division이 아니라 foundational cross-cutting product function/lens다" "maintenance taxonomy boundary"

assert_not_contains "${DIST_DIR}/templates/SFS.md.template" "Division sub-agent council is always-on" "SFS template no division policy body"
assert_not_contains "${DIST_DIR}/templates/SFS.md.template" "fresh-session transfer is lossless autopilot" "SFS template no session policy body"
assert_contains "${kernel}" "Council participation is always-on" "kernel council policy body"
assert_contains "${kernel}" "fresh-session transfer is lossless autopilot" "kernel fresh transfer policy body"
assert_contains "${kernel}" "handoff/transfer capsule" "kernel durable transfer policy body"
assert_contains "${kernel}" "resume immediately" "kernel immediate resume policy body"
assert_contains "${kernel}" 'Do not ask the user to type `/clear`' "kernel no user clear"

echo "test-division-subagent-continuation-guard: OK"
