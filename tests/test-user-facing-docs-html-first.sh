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

agent_surfaces=(
  "${DIST_DIR}/CLAUDE.md"
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
  assert_contains "${file}" "User-facing docs HTML-first" "${file}"
  assert_contains "${file}" "HTML" "${file}"
done

echo "test-user-facing-docs-html-first: OK"
