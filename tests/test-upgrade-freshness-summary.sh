#!/usr/bin/env bash
# 최신/업그레이드 안내가 병렬 agent 구현 계약을 누락하지 않는지 검증한다.
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

upgrade_context="${DIST_DIR}/templates/.sfs-local-template/context/commands/upgrade.md"
install_script="${DIST_DIR}/install.sh"
upgrade_script="${DIST_DIR}/upgrade.sh"

assert_contains "${upgrade_context}" "Freshness reports must distinguish the latest release headline" "upgrade context freshness boundary"
assert_contains "${upgrade_context}" "installed capability surface" "upgrade context capability surface"
assert_contains "${upgrade_context}" "summarizing only the newest CHANGELOG entry" "upgrade context no changelog-only latest"
assert_contains "${upgrade_context}" "sub-agents, parallel work, multi-agent" "upgrade context parallel trigger"
assert_contains "${upgrade_context}" "default is single-agent" "upgrade context single default"
assert_contains "${upgrade_context}" "sfs implement --agent-mode parallel --agents" "upgrade context parallel command"
assert_contains "${upgrade_context}" "disjoint files_scope" "upgrade context files scope"
assert_contains "${upgrade_context}" "native/workspace-language commit" "upgrade context native commit"
assert_contains "${upgrade_context}" "agent cross review before Gate 6 PASS" "upgrade context cross review"

for file in "${install_script}" "${upgrade_script}"; do
  assert_contains "${file}" "Agent implementation mode" "completion implementation mode ${file}"
  assert_contains "${file}" "기본 구현 모드는 single-agent" "completion single default ${file}"
  assert_contains "${file}" "sfs implement --agent-mode parallel --agents codex,claude[,gemini]" "completion parallel command ${file}"
  assert_contains "${file}" "disjoint files_scope" "completion files scope ${file}"
  assert_contains "${file}" "lane-level verification" "completion lane verification ${file}"
  assert_contains "${file}" "native/workspace-language one-sentence commit message" "completion native commit ${file}"
  assert_contains "${file}" "Gate 6 PASS 전 agent cross review" "completion cross review ${file}"
done

if ! awk '
  /\[ "\$CUR_VER" = "\$NEW_VER" \]/ { inside=1 }
  inside && /print_agent_implementation_mode_contract/ { saw_contract=1 }
  inside && /이미 최신 버전/ { saw_latest=1; exit }
  END { exit !(saw_contract && saw_latest) }
' "${upgrade_script}"; then
  fail "already-latest upgrade path must print the implementation mode contract before exiting"
fi

echo "test-upgrade-freshness-summary: OK"
