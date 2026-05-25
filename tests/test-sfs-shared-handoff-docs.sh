#!/usr/bin/env bash
# tests/test-sfs-shared-handoff-docs.sh — report/retro live under shared docs paths.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-shared-handoff.XXXXXX")"

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

cd "${TMP_DIR}"
git init -q
printf '# Shared Handoff Project\n' > README.md
git add README.md
git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'

SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null
start_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" start "여기작업내용" --workspace product-image-policy)"
assert_contains "${start_out}" "created: .sfs-local/sprints/" "start output"
assert_contains "${start_out}" "shared_docs: docs/solon/product-image-policy/<yyyyMMdd>/" "start shared docs output"

sprint_id="$(cat .sfs-local/current-sprint)"
date_dir="$(date +%Y%m%d)"
shared_dir="docs/solon/product-image-policy/${date_dir}"
sprint_dir=".sfs-local/sprints/${sprint_id}"

report_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" report)"
assert_contains "${report_out}" "report.md ready: ${shared_dir}/report.md" "report stdout"
[[ -f "${shared_dir}/report.md" ]] || fail "shared report.md missing"
[[ ! -e "${sprint_dir}/report.md" ]] || fail "private sprint report.md should not remain"
grep -Fq 'workspace: "product-image-policy"' "${shared_dir}/report.md" || fail "report missing workspace frontmatter"
grep -Fq "native/workspace 언어" "${shared_dir}/report.md" || fail "report missing native language guidance"

retro_draft_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" retro --draft)"
assert_contains "${retro_draft_out}" "retro.md ready: ${shared_dir}/retro.md" "retro draft stdout"
[[ -f "${shared_dir}/retro.md" ]] || fail "shared retro.md missing"
[[ ! -e "${sprint_dir}/retro.md" ]] || fail "private sprint retro.md should not remain"
grep -Fq 'workspace: "product-image-policy"' "${shared_dir}/retro.md" || fail "retro missing workspace frontmatter"
grep -Fq "native/workspace 언어" "${shared_dir}/retro.md" || fail "retro missing native language guidance"

printf '{"ts":"2026-05-09T01:20:00+09:00","type":"review_open","sprint_id":"%s"}\n' "${sprint_id}" >> .sfs-local/events.jsonl
retro_close_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" retro)"
assert_contains "${retro_close_out}" "report.md ready: ${shared_dir}/report.md" "retro close report stdout"
assert_contains "${retro_close_out}" "sprint closed: ${sprint_id}" "retro close stdout"
[[ ! -e .sfs-local/current-sprint ]] || fail "retro close should remove current-sprint"
git ls-files --error-unmatch "${shared_dir}/report.md" >/dev/null 2>&1 \
  || fail "auto close commit should include shared report.md"
git ls-files --error-unmatch "${shared_dir}/retro.md" >/dev/null 2>&1 \
  || fail "auto close commit should include shared retro.md"

custom_sid="2026-W21-security-audit"
SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" start \
  "dependabot security audit" \
  --id "${custom_sid}" \
  --workspace security-audit >/dev/null
wrong_shared_dir="docs/solon/${custom_sid}/${date_dir}"
canonical_shared_dir="docs/solon/security-audit/${date_dir}"
mkdir -p "${wrong_shared_dir}"
printf '# Wrong report location\n' > "${wrong_shared_dir}/report.md"
printf '# Wrong retro location\n' > "${wrong_shared_dir}/retro.md"

custom_report_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" report)"
assert_contains "${custom_report_out}" "report.md ready: ${canonical_shared_dir}/report.md" "custom id report stdout"
[[ -f "${canonical_shared_dir}/report.md" ]] || fail "custom id report was not moved to canonical workspace"
[[ ! -e "${wrong_shared_dir}/report.md" ]] || fail "custom id report stayed under sprint id workspace"

custom_retro_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" retro --draft)"
assert_contains "${custom_retro_out}" "retro.md ready: ${canonical_shared_dir}/retro.md" "custom id retro stdout"
[[ -f "${canonical_shared_dir}/retro.md" ]] || fail "custom id retro was not moved to canonical workspace"
[[ ! -e "${wrong_shared_dir}/retro.md" ]] || fail "custom id retro stayed under sprint id workspace"

domain_sid="2026-W21-order-items"
domain_start_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" start \
  "주문상품 수량 변경" \
  --id "${domain_sid}")"
domain_shared_dir="docs/solon/order/order-items/quantity-update/${date_dir}"
assert_contains "${domain_start_out}" "shared_docs: docs/solon/order/order-items/quantity-update/<yyyyMMdd>/" "auto domain start stdout"

domain_report_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" report)"
assert_contains "${domain_report_out}" "report.md ready: ${domain_shared_dir}/report.md" "domain report stdout"
[[ -f "${domain_shared_dir}/report.md" ]] || fail "domain report missing"
grep -Fq 'domain: "order"' "${domain_shared_dir}/report.md" || fail "domain report missing domain frontmatter"
grep -Fq 'subdomain: "order-items"' "${domain_shared_dir}/report.md" || fail "domain report missing subdomain frontmatter"
grep -Fq 'feature: "quantity-update"' "${domain_shared_dir}/report.md" || fail "domain report missing feature frontmatter"

domain_retro_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" retro --draft)"
assert_contains "${domain_retro_out}" "retro.md ready: ${domain_shared_dir}/retro.md" "domain retro stdout"
[[ -f "${domain_shared_dir}/retro.md" ]] || fail "domain retro missing"
grep -Fq 'domain: "order"' "${domain_shared_dir}/retro.md" || fail "domain retro missing domain frontmatter"
grep -Fq 'subdomain: "order-items"' "${domain_shared_dir}/retro.md" || fail "domain retro missing subdomain frontmatter"
grep -Fq 'feature: "quantity-update"' "${domain_shared_dir}/retro.md" || fail "domain retro missing feature frontmatter"

note_sid="2026-W21-note-cli"
note_start_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" start \
  "local note CLI MVP with add/list/search, JSONL storage, tests, and no production debug logs" \
  --id "${note_sid}")"
assert_contains "${note_start_out}" "shared_docs: docs/solon/tooling/cli/note-cli/<yyyyMMdd>/" "note CLI start stdout"
case "${note_start_out}" in
  *"docs/solon/catalog/products/search"*)
    fail "note CLI goal should not be inferred as catalog/products/search because of production/search words"
    ;;
esac

note_auth_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" start \
  "note CLI user auth MVP with local JSONL storage" \
  --id "2026-W21-note-cli-auth")"
assert_contains "${note_auth_out}" "shared_docs: docs/solon/tooling/cli/note-cli/<yyyyMMdd>/" "note CLI auth should preserve first-match domain"

memo_app_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" start \
  "메모 앱 MVP 검색 기능" \
  --id "2026-W21-memo-app")"
assert_contains "${memo_app_out}" "shared_docs: docs/solon/tooling/cli/note-cli/<yyyyMMdd>/" "Korean memo app should infer note CLI"

memory_leak_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" start \
  "메모리 누수 수정" \
  --id "2026-W21-memory-leak")"
case "${memory_leak_out}" in
  *"docs/solon/tooling/cli/note-cli"*)
    fail "memory leak goal should not be inferred as Korean memo/note CLI"
    ;;
esac

order_inventory_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" start \
  "order item inventory quantity update" \
  --id "2026-W21-order-inventory")"
assert_contains "${order_inventory_out}" "shared_docs: docs/solon/order/order-items/quantity-update/<yyyyMMdd>/" "order-item inventory should preserve first-match domain"

echo "test-sfs-shared-handoff-docs: OK"
