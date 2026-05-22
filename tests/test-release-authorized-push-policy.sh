#!/usr/bin/env bash
# Release push policy: no surprise push, but user-authorized autonomous deploy may push.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${DIST_DIR}/.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

. "${SCRIPT_DIR}/helpers/doc-search.sh"

assert_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  sfs_doc_contains "${file}" "${needle}" || fail "${label}: missing '${needle}'"
}

assert_not_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  if ! sfs_doc_not_contains "${file}" "${needle}"; then
    fail "${label}: unexpected stale '${needle}'"
  fi
}

release_context="${DIST_DIR}/templates/.sfs-local-template/context/commands/release.md"
shipping_policy="${DIST_DIR}/templates/.sfs-local-template/context/policies/shipping-and-launch.md"
readme="${DIST_DIR}/README.md"
changelog="${DIST_DIR}/CHANGELOG.md"
release_notes="${DIST_DIR}/RELEASE-NOTES.md"
cut_release="${REPO_ROOT}/scripts/cut-release.sh"
scripts_readme="${REPO_ROOT}/scripts/_README.md"
squash_wu="${REPO_ROOT}/scripts/squash-wu.sh"
sync_stable="${REPO_ROOT}/scripts/sync-stable-to-dev.sh"

assert_contains "${release_context}" "Push is not categorically forbidden" "release context no absolute push ban"
assert_contains "${release_context}" "explicitly asks for autonomous deploy" "release context authorized deploy"
assert_contains "${release_context}" "record the pushed refs as evidence" "release context push evidence"
assert_contains "${release_context}" "every LLM agent" "release context all LLM agents"
assert_contains "${release_context}" "Codex, Claude" "release context names Codex Claude"
assert_contains "${release_context}" "Gemini" "release context names Gemini"
assert_contains "${shipping_policy}" "avoid surprise pushes, not all pushes" "shipping policy no surprise push"
assert_contains "${shipping_policy}" "authorizes autonomous deploy" "shipping policy authorized deploy"
assert_contains "${shipping_policy}" "all LLM agents" "shipping policy all LLM agents"
assert_contains "${readme}" "명시 승인된 release flow" "readme authorized release flow"
assert_contains "${readme}" "모든 LLM Agent" "readme all LLM agents"
assert_contains "${changelog}" "no surprise push" "changelog push policy"
assert_contains "${changelog}" "all LLM agents" "changelog all LLM agents"
assert_contains "${release_notes}" "무조건 금지" "release note push policy"
assert_contains "${release_notes}" "Claude, Gemini" "release note all agent examples"

assert_contains "${cut_release}" "--push" "cut-release push flag"
assert_contains "${cut_release}" "authorized push requested" "cut-release authorized push log"
assert_contains "${cut_release}" "stable push not run by default" "cut-release no surprise default"
assert_contains "${scripts_readme}" "모든 LLM Agent" "scripts readme all LLM agents"
assert_contains "${scripts_readme}" "자동 배포를" "scripts readme authorized deploy"
assert_contains "${squash_wu}" "LLM Agent 도 push 가능" "squash helper authorized agent push"
assert_contains "${sync_stable}" "any LLM Agent may run" "sync helper authorized agent push"
assert_not_contains "${cut_release}" "push 는 안 함 (§1.5)" "cut-release no stale absolute push ban"
assert_not_contains "${cut_release}" "push 는 사용자 터미널" "cut-release no stale terminal-only push"
assert_not_contains "${scripts_readme}" 'host repo `git add/commit/push` 는 모두 사용자 터미널 manual' "scripts readme no stale manual-only"
assert_not_contains "${squash_wu}" "사용자 터미널에서만" "squash helper no terminal-only"
assert_not_contains "${sync_stable}" "AI commit 권한 회수" "sync helper no revoked agent commit"

echo "test-release-authorized-push-policy: OK"
