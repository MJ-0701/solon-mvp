#!/usr/bin/env bash
# tests/test-sfs-adopt-ddd-tdd-retrofit.sh — adopt can seed DDD retrofit + next-sprint TDD for legacy code.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-adopt-ddd-retrofit.XXXXXX")"

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
    *) fail "${label}: missing '${needle}' in: ${haystack}" ;;
  esac
}

assert_file_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

cd "${TMP_DIR}"
git init -q
mkdir -p src
cat > package.json <<'JSON'
{"scripts":{"test":"node src/orderService.js"}}
JSON
cat > src/orderService.js <<'JS'
function priceOrder(lines) {
  return lines.reduce((total, line) => total + line.price * line.qty, 0);
}
module.exports = { priceOrder };
JS
git add package.json src/orderService.js
git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'legacy order service'

SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null

brief="기존 주문 코드 DDD 리팩토링 준비"
dry_run="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" adopt --ddd-tdd-retrofit --id code-retrofit "${brief}")"
assert_contains "${dry_run}" "adopt dry-run: code-retrofit" "dry-run id"
assert_contains "${dry_run}" "ddd_tdd_retrofit: enabled" "dry-run retrofit enabled"
assert_contains "${dry_run}" "ddd_status: missing" "dry-run DDD missing"
assert_contains "${dry_run}" "tdd_next_sprint_required: yes" "dry-run TDD next sprint"
assert_contains "${dry_run}" "ddd-tdd-retrofit.md" "dry-run retrofit doc"
assert_contains "${dry_run}" "docs/solon/domain-map.md" "dry-run domain map"

applied="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" adopt --ddd-tdd-retrofit --id code-retrofit --apply "${brief}")"
assert_contains "${applied}" "adopted: code-retrofit" "apply complete"
assert_contains "${applied}" "ddd_tdd_retrofit_doc:" "apply retrofit doc"
assert_contains "${applied}" "ddd_status: missing" "apply DDD missing"
assert_contains "${applied}" "tdd_next_sprint_required: yes" "apply TDD next sprint"

date_dir="$(date +%Y%m%d)"
handoff="docs/solon/code-retrofit/${date_dir}/handoff.md"
retrofit="docs/solon/code-retrofit/${date_dir}/ddd-tdd-retrofit.md"
domain_map="docs/solon/domain-map.md"

assert_file_contains "${handoff}" "## §5. DDD/TDD Retrofit Scan" "handoff retrofit section"
assert_file_contains "${handoff}" "TDD policy" "handoff TDD policy"
assert_file_contains "${retrofit}" "DDD status: missing" "retrofit missing status"
assert_file_contains "${retrofit}" "characterization/failing/smoke" "retrofit characterization"
assert_file_contains "${retrofit}" "sfs start \"DDD retrofit:" "retrofit next sprint command"
assert_file_contains "${domain_map}" "Adoption DDD/TDD Retrofit Seed - code-retrofit" "domain map seed"
assert_file_contains "${domain_map}" "TDD policy: next real sprint starts" "domain map TDD policy"

source_summary="$(find .sfs-local/archives/adopt/code-retrofit -name source-summary.txt -type f | sort | tail -1)"
[[ -n "${source_summary}" && -f "${source_summary}" ]] || fail "missing source summary"
assert_file_contains "${source_summary}" "ddd_tdd_retrofit_enabled: 1" "summary retrofit enabled"
assert_file_contains "${source_summary}" "ddd_status: missing" "summary DDD status"
assert_file_contains "${source_summary}" "ddd_next_actions:" "summary next actions"

[[ ! -f .sfs-local/current-sprint ]] || fail "adopt retrofit should not leave active sprint pointer"

echo "test-sfs-adopt-ddd-tdd-retrofit: OK"
