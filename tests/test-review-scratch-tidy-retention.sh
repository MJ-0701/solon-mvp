#!/usr/bin/env bash
# Review prompt/run scratch uses per-invocation directories and must still be
# packed into the sprint cold archive by tidy/retro close.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-review-scratch-tidy.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

run_sfs() {
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_REVIEW_BRIDGE_PROBE_TIMEOUT_SEC=1 \
    SFS_REVIEW_EXECUTOR_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" "$@"
}

assert_file() {
  local path="$1" label="$2"
  [[ -f "${path}" ]] || fail "${label} missing: ${path}"
}

cd "${TMP_DIR}"
git init -q
printf '# Review Scratch Tidy Project\n' > README.md
git add README.md
git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'

run_sfs init --layout thin --yes >/dev/null
run_sfs start "review scratch tidy retention" >/dev/null
sprint_id="$(cat .sfs-local/current-sprint)"
fake_reviewer="${TMP_DIR}/fake-reviewer.sh"
cat > "${fake_reviewer}" <<'EOF_FAKE_REVIEWER'
#!/usr/bin/env bash
cat >/dev/null
printf 'Verdict: pass\n'
printf 'Next action:\n'
printf -- '- close\n'
printf 'Final recommendation:\n'
printf -- '- pass\n'
EOF_FAKE_REVIEWER
chmod +x "${fake_reviewer}"

prompt_out="$(run_sfs review --gate 6 --prompt-only --allow-empty)"
prompt_path="$(printf '%s\n' "${prompt_out}" | sed -nE 's/.* prompt ([^[:space:]]+)$/\1/p' | tail -n 1)"
[[ -n "${prompt_path}" ]] || fail "could not parse prompt path: ${prompt_out}"
assert_file "${prompt_path}" "prompt-only nested prompt"

case "${prompt_path}" in
  .sfs-local/tmp/review-prompts/"${sprint_id}"-gate6-*/prompt.txt) ;;
  *) fail "prompt path should use per-invocation directory: ${prompt_path}" ;;
esac

run_out="$(run_sfs review --gate 6 --executor "${fake_reviewer}" --allow-empty)"
run_result_path="$(printf '%s\n' "${run_out}" | sed -nE 's/.* output ([^[:space:]]+)$/\1/p' | tail -n 1)"
[[ -n "${run_result_path}" ]] || fail "could not parse run result path: ${run_out}"
assert_file "${run_result_path}" "nested run result"

case "${run_result_path}" in
  .sfs-local/tmp/review-runs/"${sprint_id}"-gate6-*/stdout.md) ;;
  *) fail "run result path should use per-invocation directory: ${run_result_path}" ;;
esac

tidy_out="$(run_sfs tidy --sprint "${sprint_id}" --apply)"
case "${tidy_out}" in
  *"tmp: 0 file(s) packed"*) fail "tidy did not count nested review scratch: ${tidy_out}" ;;
  *"tmp: "*" file(s) packed"*) ;;
  *) fail "tidy output missing tmp packed count: ${tidy_out}" ;;
esac

remaining_files="$(find .sfs-local/tmp -type f 2>/dev/null | grep -F "${sprint_id}" || true)"
[[ -z "${remaining_files}" ]] || fail "review scratch files should be removed from tmp: ${remaining_files}"
remaining_dirs="$(find .sfs-local/tmp -type d -name "${sprint_id}*" 2>/dev/null || true)"
[[ -z "${remaining_dirs}" ]] || fail "empty review scratch dirs should be removed from tmp: ${remaining_dirs}"

surface_bundle="$(find ".sfs-local/archives/adopt/surface-cleanup" -mindepth 2 -maxdepth 2 -name surface-cleanup.tar.gz -type f 2>/dev/null | head -n 1)"
[[ -n "${surface_bundle}" ]] || fail "missing consolidated surface cleanup archive"
surface_extract="${TMP_DIR}/surface-extract"
archive_extract="${TMP_DIR}/archive-extract"
mkdir -p "${surface_extract}" "${archive_extract}"
tar -xzf "${surface_bundle}" -C "${surface_extract}"
preexisting_archives="$(find "${surface_extract}" -name preexisting-archives.tar.gz -type f 2>/dev/null | head -n 1)"
[[ -n "${preexisting_archives}" ]] || fail "missing collapsed preexisting archives bundle"
tar -xzf "${preexisting_archives}" -C "${archive_extract}"
archive_file="$(find "${archive_extract}" -path "*/sprints/${sprint_id}/*/sprint-evidence.tar.gz" -type f 2>/dev/null | head -n 1)"
[[ -n "${archive_file}" ]] || fail "missing sprint cold archive inside collapsed bundle"
archive_index="${TMP_DIR}/archive-index.txt"
tar -tzf "${archive_file}" > "${archive_index}"

grep -F "tmp/review-prompts/${sprint_id}-gate6-" "${archive_index}" | grep -Fq "prompt.txt" \
  || fail "archive missing nested prompt scratch"
grep -F "tmp/review-runs/${sprint_id}-gate6-" "${archive_index}" | grep -Fq "stdout.md" \
  || fail "archive missing nested run stdout scratch"
grep -F "tmp/review-runs/${sprint_id}-gate6-" "${archive_index}" | grep -Fq "stderr.txt" \
  || fail "archive missing nested run stderr scratch"

echo "test-review-scratch-tidy-retention: OK"
