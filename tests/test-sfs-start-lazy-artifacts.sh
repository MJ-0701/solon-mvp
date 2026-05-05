#!/usr/bin/env bash
# tests/test-sfs-start-lazy-artifacts.sh — start leaves no empty workbench docs.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-start-lazy.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

cd "${TMP_DIR}"
git init -q
printf '# Lazy Project\n' > README.md
git add README.md
git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'

SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null
[[ ! -d ".sfs-local/sprints" ]] || fail "init should not create empty sprints dir"
[[ ! -d ".sfs-local/decisions" ]] || fail "init should not create empty decisions dir"
[[ ! -d ".sfs-local/queue" ]] || fail "init should not create empty queue dir"

start_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" start "lazy docs")"
case "${start_out}" in
  *"no step docs yet"* ) ;;
  *) fail "start output did not announce lazy docs: ${start_out}" ;;
esac

sprint_id="$(cat .sfs-local/current-sprint)"
sprint_dir=".sfs-local/sprints/${sprint_id}"
[[ -d "${sprint_dir}" ]] || fail "missing sprint dir: ${sprint_dir}"
for doc in brainstorm plan implement log review retro report; do
  [[ ! -e "${sprint_dir}/${doc}.md" ]] || fail "start should not create ${doc}.md"
done

SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" brainstorm --simple "raw" >/dev/null
[[ -f "${sprint_dir}/brainstorm.md" ]] || fail "brainstorm should create brainstorm.md"
[[ ! -e "${sprint_dir}/plan.md" ]] || fail "brainstorm should not create plan.md"
grep -Fq 'goal: "lazy docs"' "${sprint_dir}/brainstorm.md" || fail "brainstorm did not inherit sprint goal"

echo "test-sfs-start-lazy-artifacts: OK"
