#!/usr/bin/env bash
# tests/test-sfs-capture-flow.sh — natural-language flow capture writes log.md and non-collapsing events.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-capture-flow.XXXXXX")"

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

assert_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

assert_not_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  if grep -Fq -- "${needle}" "${file}"; then
    fail "${label}: unexpected '${needle}'"
  fi
}

cd "${TMP_DIR}"
git init -q
git config user.email sfs-test@example.invalid
git config user.name "SFS Test"
printf '# Capture Flow Project\n' > README.md
git add README.md
git commit -qm 'initial'

run_sfs init --layout thin --yes >/dev/null
run_sfs start "natural language flow capture" >/dev/null
sprint_id="$(cat .sfs-local/current-sprint)"

capture_out="$(run_sfs capture --kind review-order --gate 6 "Codex self-CPO first, then Gemini, then Claude.")"
case "${capture_out}" in
  *"capture recorded:"*"kind review-order"*) ;;
  *) fail "unexpected capture output: ${capture_out}" ;;
esac

note_out="$(run_sfs note "GitHub @codex review is external evidence only.")"
case "${note_out}" in
  *"capture recorded:"*"kind note"*) ;;
  *) fail "unexpected note output: ${note_out}" ;;
esac

approval_out="$(run_sfs capture --kind user-approval --gate 3 "User approved this Gate 3 plan for implementation.")"
case "${approval_out}" in
  *"capture recorded:"*"kind user-approval"*) ;;
  *) fail "unexpected user approval capture output: ${approval_out}" ;;
esac

log_path=".sfs-local/sprints/${sprint_id}/log.md"
assert_contains "${log_path}" "## 자연어 플로우 캡처" "capture section"
assert_contains "${log_path}" "review-order" "review-order entry"
assert_contains "${log_path}" "Codex self-CPO first, then Gemini, then Claude." "review-order text"
assert_contains "${log_path}" "GitHub @codex review is external evidence only." "note text"
assert_contains "${log_path}" "User approved this Gate 3 plan for implementation." "user approval text"

long_capture_text="full prompt dump and raw transcript residue that should be summarized before capture"
set +e
too_long_out="$(SFS_CAPTURE_TEXT_MAX_CHARS=40 SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" capture --kind decision "${long_capture_text}" 2>"${TMP_DIR}/too-long.err")"
too_long_rc=$?
set -e
[[ "${too_long_rc}" -eq 7 ]] || fail "too-long capture should exit 7, got ${too_long_rc}: ${too_long_out}"
assert_contains "${TMP_DIR}/too-long.err" "capture text too long" "too-long capture guard"
assert_contains "${TMP_DIR}/too-long.err" "store bulky prompt/output as an artifact path" "too-long capture hint"
assert_not_contains "${log_path}" "${long_capture_text}" "too-long capture not logged"

SFS_CAPTURE_TEXT_MAX_CHARS=40 SFS_CAPTURE_ALLOW_LONG=1 SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" capture --kind exception "${long_capture_text}" >/dev/null
assert_contains "${log_path}" "${long_capture_text}" "explicit long capture override"

flow_count="$(grep -c '"type":"flow_capture"' .sfs-local/events.jsonl || true)"
[[ "${flow_count}" == "4" ]] || fail "flow_capture events should not collapse; got ${flow_count}"
capture_id_count="$(grep -o '"capture_id":"' .sfs-local/events.jsonl | wc -l | tr -d '[:space:]')"
[[ "${capture_id_count}" == "4" ]] || fail "capture_id count mismatch: ${capture_id_count}"

rm -f .sfs-local/current-sprint
set +e
missing_out="$(run_sfs capture "this should fail without active sprint" 2>"${TMP_DIR}/missing.err")"
missing_rc=$?
set -e
[[ "${missing_rc}" -eq 1 ]] || fail "capture without active sprint should exit 1, got ${missing_rc}: ${missing_out}"
assert_contains "${TMP_DIR}/missing.err" "no active sprint" "missing active sprint error"
assert_contains "${TMP_DIR}/missing.err" "--sprint <id>" "missing active sprint hint"

run_sfs capture --sprint "${sprint_id}" --kind decision "Explicit sprint capture still records to the named sprint." >/dev/null
flow_count="$(grep -c '"type":"flow_capture"' .sfs-local/events.jsonl || true)"
[[ "${flow_count}" == "5" ]] || fail "explicit sprint capture should append fifth event; got ${flow_count}"
assert_contains "${log_path}" "Explicit sprint capture still records to the named sprint." "explicit sprint capture text"

echo "test-sfs-capture-flow: OK"
