#!/usr/bin/env bash
# docs/solon GC 는 report/retro 원본을 남기고 llm-wiki 계승 후보만 만든다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-tidy-wiki-promotion.XXXXXX")"

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
    *) fail "${label}: missing ${needle} in: ${haystack}" ;;
  esac
}

assert_file_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: ${file} missing ${needle}"
}

assert_file_not_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing ${file}"
  if grep -Fq -- "${needle}" "${file}"; then
    fail "${label}: ${file} unexpectedly contains ${needle}"
  fi
}

cd "${TMP_DIR}"
git init -q
printf '# Wiki Promotion GC Project\n' > README.md
git add README.md
git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'

SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null

date_dir="$(date +%Y%m%d)"
source_dir="docs/solon/payment/refunds/cancel-flow/${date_dir}"
mkdir -p "${source_dir}"
cat > "${source_dir}/report.md" <<'EOF'
---
phase: report
domain: "payment"
subdomain: "refunds"
feature: "cancel-flow"
---
# Report

Durable lesson: refund cancel flow needs idempotent PG webhook handling.
DO_NOT_COPY_RAW_SENTINEL report body should stay out of wiki candidates.
EOF
cat > "${source_dir}/retro.md" <<'EOF'
---
phase: retro
domain: "payment"
subdomain: "refunds"
feature: "cancel-flow"
---
# Retro

Keep: record the rejected restore API decision as source-linked wiki memory.
DO_NOT_COPY_RAW_SENTINEL retro body should stay out of wiki candidates.
EOF

dry_run="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" tidy --all --wiki-promote)"
assert_contains "${dry_run}" "wiki_promotion: 1 source dir(s) would create/update candidate(s)" "dry-run wiki promotion count"

apply_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" tidy --all --wiki-promote --apply)"
assert_contains "${apply_out}" "wiki_promotion: 1 candidate(s) created; 0 existing; 2 source file(s) linked" "apply wiki promotion summary"

candidate="$(find llm-wiki/promotion-candidates/payment -name "${date_dir}-refunds-cancel-flow-*.md" -type f | head -1)"
[[ -n "${candidate}" ]] || fail "promotion candidate not created"
assert_file_contains "${candidate}" "doc_type: wiki-promotion-candidate" "candidate frontmatter"
assert_file_contains "${candidate}" 'generated_by: "sfs tidy --wiki-promote"' "candidate generator"
assert_file_contains "${candidate}" "- report: \`${source_dir}/report.md\`" "candidate report source link"
assert_file_contains "${candidate}" "- retro: \`${source_dir}/retro.md\`" "candidate retro source link"
assert_file_contains "${candidate}" "Promotion Roots" "candidate promotion checklist"
assert_file_not_contains "${candidate}" "DO_NOT_COPY_RAW_SENTINEL" "candidate must not copy report/retro body"

assert_file_contains "${source_dir}/report.md" "## Wiki Promotion Candidate" "report pointer heading"
assert_file_contains "${source_dir}/report.md" "\`${candidate}\`" "report candidate path"
assert_file_contains "${source_dir}/retro.md" "\`${candidate}\`" "retro candidate path"

second_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" tidy --all --wiki-promote --apply)"
assert_contains "${second_out}" "wiki_promotion: 0 candidate(s) created; 1 existing; 2 source file(s) linked" "idempotent rerun summary"
marker_count="$(grep -c 'solon:wiki-promotion-candidate:start' "${source_dir}/report.md")"
[[ "${marker_count}" = "1" ]] || fail "report marker should be upserted once, got ${marker_count}"

mv llm-wiki llm-wiki.disabled
missing_wiki_dry="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" tidy --all --wiki-promote)"
assert_contains "${missing_wiki_dry}" "wiki_promotion: skipped (llm-wiki absent)" "missing wiki dry-run skip"
missing_wiki_apply="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" tidy --all --wiki-promote --apply)"
assert_contains "${missing_wiki_apply}" "wiki_promotion: skipped (llm-wiki absent)" "missing wiki apply skip"

echo "test-sfs-tidy-wiki-promotion-gc: OK"
