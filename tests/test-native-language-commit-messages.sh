#!/usr/bin/env bash
# 커밋 메시지가 사용자 native 언어를 기본값으로 삼는지 검증한다.
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

IMPLEMENT="${DIST_DIR}/templates/.sfs-local-template/context/commands/implement.md"
REVIEW="${DIST_DIR}/templates/.sfs-local-template/context/commands/review.md"
README="${DIST_DIR}/README.md"
GUIDE="${DIST_DIR}/GUIDE.md"
TENX_KO="${DIST_DIR}/docs/ko/10x-value.md"
TENX_EN="${DIST_DIR}/docs/en/10x-value.md"
INSTALL="${DIST_DIR}/install.sh"
UPGRADE="${DIST_DIR}/upgrade.sh"
UNINSTALL="${DIST_DIR}/uninstall.sh"
IMPLEMENT_SCRIPT="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-implement.sh"
TIDY_CONTEXT="${DIST_DIR}/templates/.sfs-local-template/context/commands/tidy.md"
REPORT_TEMPLATE="${DIST_DIR}/templates/.sfs-local-template/sprint-templates/report.md"
RETRO_TEMPLATE="${DIST_DIR}/templates/.sfs-local-template/sprint-templates/retro.md"

if [[ ! -f "${README}" && -f "${DIST_DIR}/../README.md" ]]; then
  README="${DIST_DIR}/../README.md"
fi

assert_contains "${IMPLEMENT}" "Commit messages default to the user's native/workspace language" "implement native language"
assert_contains "${REVIEW}" "Review proposed or actual commit messages against the user's" "review native language"
assert_contains "${README}" "커밋 메시지는 기본적으로 사용자의 native 언어" "README native language"
assert_contains "${GUIDE}" "커밋 메시지는 사용자의 native 언어" "GUIDE native language"
assert_contains "${TENX_KO}" "commit message 는 사용자의 native 언어" "KO 10x native language"
assert_contains "${TENX_EN}" "user's native or workspace" "EN 10x native language"

for adapter in \
  "${DIST_DIR}/templates/codex-skill/SKILL.md" \
  "${DIST_DIR}/templates/.agents/skills/sfs/SKILL.md" \
  "${DIST_DIR}/templates/.claude/commands/sfs.md" \
  "${DIST_DIR}/templates/.gemini/commands/sfs.toml" \
  "${DIST_DIR}/templates/AGENTS.md.template" \
  "${DIST_DIR}/templates/CLAUDE.md.template" \
  "${DIST_DIR}/templates/GEMINI.md.template" \
  "${DIST_DIR}/templates/.codex/prompts/sfs.md" \
  "${DIST_DIR}/plugins/solon/commands/sfs.md" \
  "${DIST_DIR}/commands/sfs.toml"; do
  assert_contains "${adapter}" "clear native-language commit message" "adapter native commit ${adapter}"
  assert_contains "${adapter}" "native/workspace language" "adapter native language ${adapter}"
done

assert_contains "${INSTALL}" 'sfs commit apply --group runtime-upgrade -m' "install sfs commit command"
assert_contains "${INSTALL}" '설치: solon-product $SOLON_VERSION' "install Korean sfs commit"
assert_contains "${UPGRADE}" 'sfs commit apply --group runtime-upgrade -m' "upgrade sfs commit command"
assert_contains "${UPGRADE}" '업그레이드: solon-mvp $CUR_VER → $NEW_VER' "upgrade Korean sfs commit"
assert_contains "${UNINSTALL}" 'sfs commit apply --group runtime-upgrade -m "제거: solon-product"' "uninstall Korean sfs commit"
assert_contains "${INSTALL}" "기본적으로 현재 branch 를 push" "install sfs commit pushes"
assert_contains "${UPGRADE}" "기본적으로 현재 branch 를 push" "upgrade sfs commit pushes"
assert_contains "${UNINSTALL}" "기본적으로 현재 branch 를 push" "uninstall sfs commit pushes"
assert_contains "${IMPLEMENT_SCRIPT}" "commit language: proposed/actual commit messages default" "implement script native language"
assert_contains "${TIDY_CONTEXT}" "Report/retro prose should use the user's native/workspace language" "handoff native language"
assert_contains "${REPORT_TEMPLATE}" "native/workspace 언어" "report native language"
assert_contains "${RETRO_TEMPLATE}" "native/workspace 언어" "retro native language"

assert_not_contains "${INSTALL}" 'git commit -m "chore: install solon-product' "install no English chore"
assert_not_contains "${UPGRADE}" 'git commit -m "chore: upgrade solon-mvp' "upgrade no English chore"
assert_not_contains "${UNINSTALL}" 'git commit -m "chore: uninstall solon-product' "uninstall no English chore"
assert_not_contains "${INSTALL}" 'git commit -m "설치: solon-product' "install no raw git commit guidance"
assert_not_contains "${UPGRADE}" 'git commit -m "업그레이드: solon-mvp' "upgrade no raw git commit guidance"
assert_not_contains "${UNINSTALL}" 'git commit -m "제거: solon-product' "uninstall no raw git commit guidance"

echo "test-native-language-commit-messages: OK"
