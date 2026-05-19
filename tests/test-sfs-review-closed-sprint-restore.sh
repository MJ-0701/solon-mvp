#!/usr/bin/env bash
# tests/test-sfs-review-closed-sprint-restore.sh — review --sprint restores compacted sprint workbench.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-review-restore.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

run_sfs() {
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" "$@"
}

assert_file() {
  local path="$1" label="$2"
  [[ -f "${path}" ]] || fail "${label} missing: ${path}"
}

assert_contains() {
  local file="$1" needle="$2" label="$3"
  assert_file "${file}" "${label}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

cd "${TMP_DIR}"
git init -q
git config user.email sfs-test@example.invalid
git config user.name "SFS Test"
printf '# Review Restore Project\n' > README.md
git add README.md
git commit -qm 'initial'

run_sfs init --layout thin --yes >/dev/null
run_sfs start "closed sprint review restore" >/dev/null
sprint_id="$(cat .sfs-local/current-sprint)"
run_sfs brainstorm --simple "restore review evidence" >/dev/null
run_sfs plan >/dev/null

implement_path=".sfs-local/sprints/${sprint_id}/implement.md"
cp "${DIST_DIR}/templates/.sfs-local-template/sprint-templates/implement.md" "${implement_path}"
{
  printf '\n## Restore Review Marker\n\n'
  printf -- '- ready-for-review: yes\n'
  printf -- '- Verification: archive restore smoke marker\n'
} >> "${implement_path}"

review_open="$(run_sfs review --gate 6 --prompt-only)"
case "${review_open}" in
  *"review.md ready:"*"prompt "*) ;;
  *) fail "prompt-only review did not create prompt: ${review_open}" ;;
esac

archive_dir=".sfs-local/archives/sprints/${sprint_id}/2026-05-19T20-00-00-09-00"
archive_stage="${TMP_DIR}/archive-stage"
mkdir -p "${archive_dir}" "${archive_stage}/sprints"
cp -R ".sfs-local/sprints/${sprint_id}" "${archive_stage}/sprints/${sprint_id}"
tar -czf "${archive_dir}/sprint-evidence.tar.gz" -C "${archive_stage}" .
printf 'SFS sprint cold archive\nsprint_id: %s\n' "${sprint_id}" > "${archive_dir}/manifest.txt"

rm -f .sfs-local/current-sprint
rm -f ".sfs-local/sprints/${sprint_id}/brainstorm.md" \
      ".sfs-local/sprints/${sprint_id}/plan.md" \
      ".sfs-local/sprints/${sprint_id}/implement.md" \
      ".sfs-local/sprints/${sprint_id}/log.md" \
      ".sfs-local/sprints/${sprint_id}/review.md"
[[ ! -f "${implement_path}" ]] || fail "archive setup should remove visible implement.md before restore"

restore_err="${TMP_DIR}/restore.err"
restore_out="$(run_sfs review --sprint "${sprint_id}" --gate 6 --prompt-only 2>"${restore_err}")"
case "${restore_out}" in
  *"review.md ready:"*"prompt "*) ;;
  *) fail "restored review did not create prompt: ${restore_out}" ;;
esac
assert_contains "${restore_err}" "review restored sprint: ${sprint_id}" "restore notice"

current="$(cat .sfs-local/current-sprint)"
[[ "${current}" == "${sprint_id}" ]] || fail "current-sprint not restored: ${current}"
assert_contains "${implement_path}" "Restore Review Marker" "restored implement workbench"
assert_contains ".sfs-local/sprints/${sprint_id}/review.md" "CPO evaluator invocation" "restored review workbench"

echo "test-sfs-review-closed-sprint-restore: OK"
