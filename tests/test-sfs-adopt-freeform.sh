#!/usr/bin/env bash
# tests/test-sfs-adopt-freeform.sh — adopt accepts the same natural-language brief shape as start/brainstorm.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-adopt-freeform.XXXXXX")"

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
printf '# Legacy Project\n\nExisting docs need a current-state cleanup.\n' > README.md
git add README.md
git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial legacy project'

SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null

brief="문서 정리좀 해야될거 같은데."
dry_run="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" adopt "${brief}")"
case "${dry_run}" in
  *"adopt dry-run: legacy-baseline"* ) ;;
  *) fail "dry-run did not complete: ${dry_run}" ;;
esac
case "${dry_run}" in
  *"brief: ${brief}"* ) ;;
  *) fail "dry-run did not echo free-form brief: ${dry_run}" ;;
esac

applied="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" adopt --id doc-cleanup --apply "${brief}")"
case "${applied}" in
  *"adopted: doc-cleanup"* ) ;;
  *) fail "apply did not complete: ${applied}" ;;
esac
case "${applied}" in
  *"brief: ${brief}"* ) ;;
  *) fail "apply did not echo free-form brief: ${applied}" ;;
esac

REPORT=".sfs-local/sprints/doc-cleanup/report.md"
RETRO=".sfs-local/sprints/doc-cleanup/retro.md"
[[ -f "${REPORT}" ]] || fail "missing report: ${REPORT}"
[[ -f "${RETRO}" ]] || fail "missing retro: ${RETRO}"
grep -Fq "goal: \"${brief}\"" "${REPORT}" || fail "report frontmatter did not store brief as goal"
grep -Fq "${brief}" "${REPORT}" || fail "report body missing brief"
grep -Fq "${brief}" "${RETRO}" || fail "retro body missing brief"
grep -Fq "\"brief\":\"${brief}\"" .sfs-local/events.jsonl || fail "events.jsonl missing brief"

echo "test-sfs-adopt-freeform: OK"
