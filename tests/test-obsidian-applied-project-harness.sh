#!/usr/bin/env bash
# Obsidian 적용 프로젝트를 SFS 런타임 notice 가 감지하는지 검증한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-obsidian-applied.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

assert_not_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing ${file}"
  if grep -Fq -- "${needle}" "${file}"; then
    fail "${label}: unexpected '${needle}'"
  fi
}

run_sfs_status() {
  local stdout="$1" stderr="$2"
  shift 2
  SFS_COMMAND_TIMEOUT_SEC=0 \
  SFS_DIST_DIR="${DIST_DIR}" \
  "$@" bash "${SFS_BIN}" status >"${stdout}" 2>"${stderr}"
}

cd "${TMP_DIR}"
git init -q
printf '# Obsidian Applied Project\n' > README.md
git add README.md
git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'

SFS_COMMAND_TIMEOUT_SEC=0 \
SFS_DIST_DIR="${DIST_DIR}" \
bash "${SFS_BIN}" init --yes >/dev/null

mkdir -p llm-wiki/ddd
printf '# LLM Wiki\n' > llm-wiki/README.md
printf '# DDD Model\n' > llm-wiki/ddd/README.md

run_sfs_status status.out status.err env \
  SFS_OBSIDIAN_NOTICE_FORCE=1 \
  SFS_OBSIDIAN_NOTICE_TTL_SEC=0

assert_contains status.out "sprint" "status stdout"
assert_contains status.err "sfs obsidian notice" "active wiki notice"
assert_contains status.err "Obsidian project surface detected" "active wiki detected"
assert_contains status.err "llm-wiki/" "active wiki root"
assert_contains status.err "DDD wiki boundary expected: llm-wiki/ddd/" "active wiki DDD boundary"
assert_contains status.err "Taxonomy stays domain language/classification lens" "active wiki taxonomy boundary"
assert_contains status.err "update the relevant wiki map or record a gap/waiver" "active wiki update gap"

rm -f llm-wiki/ddd/README.md
run_sfs_status missing-ddd.out missing-ddd.err env \
  SFS_OBSIDIAN_NOTICE_FORCE=1 \
  SFS_OBSIDIAN_NOTICE_TTL_SEC=0
assert_contains missing-ddd.err "Gap: llm-wiki/ddd/README.md missing" "missing DDD gap"

rm -rf llm-wiki
mkdir -p .obsidian
run_sfs_status obsidian-only.out obsidian-only.err env \
  SFS_OBSIDIAN_NOTICE_FORCE=1 \
  SFS_OBSIDIAN_NOTICE_TTL_SEC=0
assert_contains obsidian-only.err "Gap: .obsidian/ exists but llm-wiki/ is missing" "obsidian-only gap"

run_sfs_status disabled.out disabled.err env \
  SFS_OBSIDIAN_NOTICE=0 \
  SFS_OBSIDIAN_NOTICE_FORCE=1 \
  SFS_OBSIDIAN_NOTICE_TTL_SEC=0
assert_not_contains disabled.err "sfs obsidian notice" "disabled notice"

echo "test-obsidian-applied-project-harness: OK"
