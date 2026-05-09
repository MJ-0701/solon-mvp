#!/usr/bin/env bash
# tests/test-sfs-shared-handoff-docs.sh — report/retro live under docs/<workspace>/<yyyyMMdd>.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-shared-handoff.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local haystack="$1" needle="$2" label="$3"
  case "${haystack}" in
    *"${needle}"*) ;;
    *) fail "${label}: missing ${needle} in: ${haystack}" ;;
  esac
}

cd "${TMP_DIR}"
git init -q
printf '# Shared Handoff Project\n' > README.md
git add README.md
git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'

SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null
start_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" start "여기작업내용")"
assert_contains "${start_out}" "created: .sfs-local/sprints/" "start output"

sprint_id="$(cat .sfs-local/current-sprint)"
date_dir="$(date +%Y%m%d)"
shared_dir="docs/여기작업내용/${date_dir}"
sprint_dir=".sfs-local/sprints/${sprint_id}"

report_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" report)"
assert_contains "${report_out}" "report.md ready: ${shared_dir}/report.md" "report stdout"
[[ -f "${shared_dir}/report.md" ]] || fail "shared report.md missing"
[[ ! -e "${sprint_dir}/report.md" ]] || fail "private sprint report.md should not remain"
grep -Fq 'workspace: "여기작업내용"' "${shared_dir}/report.md" || fail "report missing workspace frontmatter"
grep -Fq "native/workspace 언어" "${shared_dir}/report.md" || fail "report missing native language guidance"

retro_draft_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" retro --draft)"
assert_contains "${retro_draft_out}" "retro.md ready: ${shared_dir}/retro.md" "retro draft stdout"
[[ -f "${shared_dir}/retro.md" ]] || fail "shared retro.md missing"
[[ ! -e "${sprint_dir}/retro.md" ]] || fail "private sprint retro.md should not remain"
grep -Fq 'workspace: "여기작업내용"' "${shared_dir}/retro.md" || fail "retro missing workspace frontmatter"
grep -Fq "native/workspace 언어" "${shared_dir}/retro.md" || fail "retro missing native language guidance"

printf '{"ts":"2026-05-09T01:20:00+09:00","type":"review_open","sprint_id":"%s"}\n' "${sprint_id}" >> .sfs-local/events.jsonl
retro_close_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" retro)"
assert_contains "${retro_close_out}" "report.md ready: ${shared_dir}/report.md" "retro close report stdout"
assert_contains "${retro_close_out}" "sprint closed: ${sprint_id}" "retro close stdout"
[[ ! -e .sfs-local/current-sprint ]] || fail "retro close should remove current-sprint"
git ls-files --error-unmatch "${shared_dir}/report.md" >/dev/null 2>&1 \
  || fail "auto close commit should include shared report.md"
git ls-files --error-unmatch "${shared_dir}/retro.md" >/dev/null 2>&1 \
  || fail "auto close commit should include shared retro.md"

echo "test-sfs-shared-handoff-docs: OK"
