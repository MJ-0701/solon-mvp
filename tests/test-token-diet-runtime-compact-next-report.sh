#!/usr/bin/env bash
# Token Diet start/report compact output이 추적 필드를 보존하는지 검증한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/sfs-token-diet-next-report.XXXXXX")"

cleanup() {
  rm -rf "${TMP_ROOT}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local text="$1"
  local needle="$2"
  local label="$3"

  case "${text}" in
    *"${needle}"*) ;;
    *) fail "${label}: missing '${needle}' in '${text}'" ;;
  esac
}

bytes_text() {
  printf '%s' "$1" | wc -c | tr -d ' '
}

setup_project() {
  local dir="$1"

  mkdir -p "${dir}"
  cd "${dir}"
  git init -q
  git config user.email "sfs@example.invalid"
  git config user.name "SFS Test"
  printf '# token diet fixture\n' > README.md
  git add README.md
  git commit -q -m "init"
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null
}

setup_project "${TMP_ROOT}/start-normal"
normal_start="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" start "lazy docs")"
assert_contains "${normal_start}" "no step docs yet" "normal start lazy-doc evidence"
assert_contains "${normal_start}" "next: choose brainstorm depth" "normal start next action"

setup_project "${TMP_ROOT}/start-compact"
compact_start="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" start "lazy docs" --output-style compact)"
assert_contains "${compact_start}" "created=.sfs-local/sprints/" "compact start created path"
assert_contains "${compact_start}" "current_sprint=" "compact start sprint pointer"
assert_contains "${compact_start}" "shared_docs=docs/solon/lazy-docs/<yyyyMMdd>/" "compact start shared docs path"
assert_contains "${compact_start}" "step_docs=lazy" "compact start lazy-doc state"
assert_contains "${compact_start}" 'next=sfs brainstorm "lazy docs"' "compact start recommended command"
assert_contains "${compact_start}" 'alt_simple=sfs brainstorm --simple "lazy docs"' "compact start simple alternative"
assert_contains "${compact_start}" 'alt_hard=sfs brainstorm --hard "lazy docs"' "compact start hard alternative"
assert_contains "${compact_start}" "recommended=normal" "compact start recommendation"
[[ "$(bytes_text "${compact_start}")" -lt "$(bytes_text "${normal_start}")" ]] \
  || fail "compact start should be shorter than normal start"

set +e
bad_style="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" start "bad style" --output-style ultra 2>&1)"
bad_rc=$?
set -e
[[ "${bad_rc}" -eq 99 ]] || fail "invalid start output style should exit 99, got ${bad_rc}"
assert_contains "${bad_style}" "invalid output style" "invalid start output style"

setup_project "${TMP_ROOT}/report-draft"
SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" start "report draft" >/dev/null
compact_report_draft="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" report --output-style compact)"
assert_contains "${compact_report_draft}" "report=docs/solon/report-draft/" "compact draft report path"
assert_contains "${compact_report_draft}" "compact=0" "compact draft report flag"

setup_project "${TMP_ROOT}/report-normal"
SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" start "report close" >/dev/null
normal_report="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" report --compact)"
assert_contains "${normal_report}" "report.md ready:" "normal compact report path"
assert_contains "${normal_report}" "archive:" "normal compact archive path"
assert_contains "${normal_report}" "workbench archived:" "normal compact archive state"

setup_project "${TMP_ROOT}/report-compact"
SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" start "report close" >/dev/null
compact_report="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_OUTPUT_STYLE=compact SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" report --compact)"
assert_contains "${compact_report}" "report=docs/solon/report-close/" "compact report path"
assert_contains "${compact_report}" "compact=1" "compact report final flag"
assert_contains "${compact_report}" "archive=.sfs-local/archives/sprints/" "compact report archive path"
assert_contains "${compact_report}" "workbench_archived=" "compact report archive state"
[[ "$(bytes_text "${compact_report}")" -lt "$(bytes_text "${normal_report}")" ]] \
  || fail "compact report close should be shorter than normal report close"

echo "test-token-diet-runtime-compact-next-report: OK"
