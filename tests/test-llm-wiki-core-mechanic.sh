#!/usr/bin/env bash
# WMU-3 — llm-wiki core entry mechanics stay purpose-gated and deterministic.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"

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

run_sfs() {
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" "$@"
}

tmp="$(mktemp -d "${TMPDIR:-/tmp}/wmu3-core.XXXXXX")"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT

cd "${tmp}"
git init -q
run_sfs init --layout thin --yes >/dev/null

assert_contains "llm-wiki/project-context.md" "Initial Interview" "project context scaffold"
assert_contains "llm-wiki/project-context.md" "Core question" "project context question"
assert_contains "llm-wiki/README.md" "queryable project memory" "wiki queryable positioning"
assert_contains "llm-wiki/00-llm-retrieval-guide.md" "Observe first" "observe-first retrieval guide"
assert_contains "llm-wiki/ddd/README.md" "glossary seeds" "DDD glossary seed guidance"

set +e
missing_out="$(run_sfs ingest --source-type article --title "Purpose missing" 2>"${tmp}/missing.err")"
missing_rc=$?
set -e
[[ "${missing_rc}" -ne 0 ]] || fail "ingest without purpose should fail: ${missing_out}"
assert_contains "${tmp}/missing.err" "collection purpose required" "missing purpose error"
if [[ -d ".sfs-local/ingest" ]] && find .sfs-local/ingest -type f | grep -q .; then
  fail "missing-purpose ingest wrote a draft"
fi

set +e
invalid_out="$(run_sfs ingest --source-type memo --purpose "compare schemas" --title "Bad type" 2>"${tmp}/invalid.err")"
invalid_rc=$?
set -e
[[ "${invalid_rc}" -ne 0 ]] || fail "ingest with invalid source_type should fail: ${invalid_out}"
assert_contains "${tmp}/invalid.err" "invalid source_type" "invalid source_type error"

set +e
option_value_out="$(run_sfs ingest --source-type article --purpose --title "Option as value" 2>"${tmp}/option-value.err")"
option_value_rc=$?
set -e
[[ "${option_value_rc}" -ne 0 ]] || fail "ingest should reject option-looking value: ${option_value_out}"
assert_contains "${tmp}/option-value.err" "--purpose requires a value" "option-looking value error"
if [[ -d ".sfs-local/ingest" ]] && find .sfs-local/ingest -type f | grep -q .; then
  fail "option-looking purpose wrote a draft"
fi

for source_type in article youtube podcast book research; do
  out="$(run_sfs ingest --source-type "${source_type}" --purpose "answer why ${source_type} matters" --title "${source_type} source")"
  case "${out}" in
    "ingest draft created: "*)
      rel="${out#ingest draft created: }"
      rel="${rel%% |*}"
      ;;
    *) fail "unexpected ingest output for ${source_type}: ${out}" ;;
  esac
  [[ -f "${rel}" ]] || fail "ingest draft missing for ${source_type}: ${rel}"
  assert_contains "${rel}" "source_type: ${source_type}" "${source_type} source_type"
  assert_contains "${rel}" "collection_purpose:" "${source_type} purpose field"
  assert_contains "${rel}" "compile_to_wiki: pending" "${source_type} compile status"
  assert_contains "${rel}" "## Wiki Compile Plan" "${source_type} compile plan"
  case "${source_type}" in
    article)  assert_contains "${rel}" "publisher:" "article schema" ;;
    youtube)  assert_contains "${rel}" "channel:" "youtube schema" ;;
    podcast)  assert_contains "${rel}" "episode:" "podcast schema" ;;
    book)     assert_contains "${rel}" "edition:" "book schema" ;;
    research) assert_contains "${rel}" "doi_or_url:" "research schema" ;;
  esac
done

assert_not_contains "${DIST_DIR}/templates/.sfs-local-template/context/policies/obsidian-llm-wiki.md" "sfs ingest" "WIKI-AIERA mechanic leak"
assert_contains "${DIST_DIR}/templates/.sfs-local-template/context/commands/ingest.md" "collection purpose" "ingest routed context"
assert_contains "${DIST_DIR}/docs/en/current-product-shape/19-obsidian-llm-wiki-continuity.md" "queryable company memory" "EN queryable positioning"
assert_contains "${DIST_DIR}/docs/ko/current-product-shape/19-obsidian-llm-wiki-continuity.md" "쿼리 가능한 회사 기억" "KO queryable positioning"
assert_contains "${DIST_DIR}/CHANGELOG.md" "[Unreleased]" "unreleased changelog"

echo "test-llm-wiki-core-mechanic: OK"
