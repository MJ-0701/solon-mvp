#!/usr/bin/env bash
# 사용자용 문서 HTML-first 규칙이 모든 에이전트 진입 표면에 배포되는지 검증한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DOCSET_ROOT="$(cd "${DIST_DIR}/.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1"
  local needle="$2"
  local label="$3"

  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

# 0.7.2: top-level CLAUDE.md is no longer one of the policy-text surfaces.
# It became a thin agent entry that cross-links to docs/maintenance/
# release-policy.md, which is the new canonical location for the
# "User-facing docs HTML-encouraged" rule. The remaining agent surfaces
# (routed kernel/context, agent adapter commands, host plugin command)
# still inline the rule, because those are the surfaces an agent actually
# reads when running.
agent_surfaces=(
  "${DIST_DIR}/templates/.sfs-local-template/context/kernel.md"
  "${DIST_DIR}/templates/codex-skill/SKILL.md"
  "${DIST_DIR}/templates/.agents/skills/sfs/SKILL.md"
  "${DIST_DIR}/templates/.claude/commands/sfs.md"
  "${DIST_DIR}/templates/.gemini/commands/sfs.toml"
  "${DIST_DIR}/commands/sfs.toml"
  "${DIST_DIR}/plugins/solon/commands/sfs.md"
)

if [[ -f "${DOCSET_ROOT}/CLAUDE.md" ]]; then
  agent_surfaces=("${DOCSET_ROOT}/CLAUDE.md" "${agent_surfaces[@]}")
fi

for file in "${agent_surfaces[@]}"; do
  assert_contains "${file}" "User-facing docs HTML-encouraged" "${file}"
  assert_contains "${file}" "HTML" "${file}"
  # 0.6.145 약화: HTML 권장이지만 MD 도 허용한다는 문구가 함께 들어가야 한다.
  # 단순히 HTML-first 만 남겨두면 정책-실태 격차가 재발한다.
  assert_contains "${file}" "MD" "${file}"
done

# 0.7.2: canonical maintainer-side rule body moved to docs/maintenance/
# release-policy.md. Assert it explicitly here so a future cleanup of
# release-policy.md does not silently delete the rule.
dist_release_policy="${DIST_DIR}/docs/maintenance/release-policy.md"
assert_contains "${dist_release_policy}" "User-facing docs HTML-encouraged" "release-policy HTML-encouraged"
assert_contains "${dist_release_policy}" "MD" "release-policy MD allowance"

# CLAUDE.md must still cross-link to the new canonical location so the
# rule is discoverable from the agent entry.
assert_contains "${DIST_DIR}/CLAUDE.md" "docs/maintenance/release-policy.md" "CLAUDE.md cross-link to release-policy"

echo "test-user-facing-docs-html-first: OK"
