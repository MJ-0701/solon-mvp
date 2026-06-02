#!/usr/bin/env bash
# sfs harness doctor/map 이 프로젝트 하네스를 실행 가능한 evidence 로 노출하는지 검증한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-harness-command.XXXXXX")"
trap 'rm -rf "${TMP_DIR}"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

run_sfs() {
  PATH="${DIST_DIR}/bin:$PATH" SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" "$@"
}

run_sfs --help > "${TMP_DIR}/help.out"
assert_contains "${TMP_DIR}/help.out" "sfs harness doctor|map [--write]" "usage exposes harness"

run_sfs context cat commands/harness.md > "${TMP_DIR}/harness-command.out"
assert_contains "${TMP_DIR}/harness-command.out" "sfs harness doctor" "context command harness doctor"
assert_contains "${TMP_DIR}/harness-command.out" "sfs harness map --write" "context command harness map"
assert_contains "${TMP_DIR}/harness-command.out" "evolution-ledger.md" "context command evolution ledger"

run_sfs context cat policies/harness-autonomy.md > "${TMP_DIR}/harness-policy.out"
assert_contains "${TMP_DIR}/harness-policy.out" "Project Harness Autonomy" "context policy title"
assert_contains "${TMP_DIR}/harness-policy.out" "Audit before extending a generated harness" "context harness phase0 audit"
assert_contains "${TMP_DIR}/harness-policy.out" "better environment for whichever model is active" "context policy model boundary"

cd "${TMP_DIR}"
mkdir project
cd project
git init --quiet
run_sfs init --layout thin --yes >/dev/null
mkdir tests

run_sfs harness doctor > doctor.out
assert_contains doctor.out "SFS Project Harness Doctor" "doctor title"
assert_contains doctor.out "division active: strategy-pm" "doctor strategy division"
assert_contains doctor.out "division declared: taxonomy" "doctor taxonomy division"
assert_contains doctor.out "test/build surface detected" "doctor test surface"
assert_contains doctor.out "minimum autonomous-work harness is present" "doctor minimum harness"
assert_contains doctor.out "harness evolution ledger absent" "doctor ledger absent"

run_sfs harness map > map.out
assert_contains map.out "SFS Project Harness Map" "map title"
assert_contains map.out "Harness Components" "map components"
assert_contains map.out "Harness audit" "map harness audit row"
assert_contains map.out "Team architecture" "map team architecture row"
assert_contains map.out "Harness evolution" "map harness evolution row"
assert_contains map.out "Division Contracts" "map division contracts"
assert_contains map.out "Human Boundary" "map human boundary"

run_sfs harness map --write > write.out
assert_contains write.out "SFS harness map written: .sfs-local/harness/harness-map.md" "map write output"
assert_contains write.out "SFS harness evolution ledger written: .sfs-local/harness/evolution-ledger.md" "ledger write output"
assert_contains .sfs-local/harness/harness-map.md "SFS Project Harness Map" "written map title"
assert_contains .sfs-local/harness/harness-map.md "Autonomy Loop" "written map autonomy loop"
assert_contains .sfs-local/harness/harness-map.md "initial-to-shipped harness evolution" "written map evolution loop"
assert_contains .sfs-local/harness/harness-map.md "Harness Evolution Ledger" "written map ledger section"
assert_contains .sfs-local/harness/harness-map.md "sfs harness doctor" "written map command"
assert_contains .sfs-local/harness/evolution-ledger.md "SFS Harness Evolution Ledger" "written ledger title"
assert_contains .sfs-local/harness/evolution-ledger.md "HE-YYYYMMDD-01" "written ledger template row"
assert_contains .sfs-local/harness/evolution-ledger.md "Acceptance signal" "written ledger acceptance signal"
assert_contains .sfs-local/harness/evolution-ledger.md "Promotion Rules" "written ledger promotion rules"

run_sfs harness doctor > doctor-with-ledger.out
assert_contains doctor-with-ledger.out "harness evolution ledger present" "doctor ledger present"

run_sfs harness map --write > write-again.out
assert_contains write-again.out "SFS harness evolution ledger preserved: .sfs-local/harness/evolution-ledger.md" "ledger preserve output"

assert_contains "${DIST_DIR}/templates/SFS.md.template" "sfs harness doctor" "SFS template harness command"
assert_contains "${DIST_DIR}/docs/en/current-product-shape/22-project-harness-map.md" "sfs harness map --write" "EN docs harness map"
assert_contains "${DIST_DIR}/docs/en/current-product-shape/22-project-harness-map.md" "generated-harness audit" "EN docs harness audit"
assert_contains "${DIST_DIR}/docs/en/current-product-shape/22-project-harness-map.md" "evolution-ledger.md" "EN docs evolution ledger"
assert_contains "${DIST_DIR}/docs/ko/current-product-shape/22-project-harness-map.md" "sfs harness map --write" "KO docs harness map"
assert_contains "${DIST_DIR}/docs/ko/current-product-shape/22-project-harness-map.md" "generated-harness audit" "KO docs harness audit"
assert_contains "${DIST_DIR}/docs/ko/current-product-shape/22-project-harness-map.md" "evolution-ledger.md" "KO docs evolution ledger"

echo "test-sfs-harness-command: OK"
