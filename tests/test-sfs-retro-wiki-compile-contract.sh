#!/usr/bin/env bash
# Sprint close should keep report/retro as evidence and compile only durable
# meaning into llm-wiki when an Obsidian/wiki project surface exists.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

context_dir="${DIST_DIR}/templates/.sfs-local-template/context"
scripts_dir="${DIST_DIR}/templates/.sfs-local-template/scripts"
templates_dir="${DIST_DIR}/templates/.sfs-local-template/sprint-templates"

policy="${context_dir}/policies/obsidian-llm-wiki.md"
policy_ko="${context_dir}/policies/obsidian-llm-wiki.ko.md"
common="${scripts_dir}/sfs-common.sh"
retro_script="${scripts_dir}/sfs-retro.sh"
report_template="${templates_dir}/report.md"
retro_template="${templates_dir}/retro.md"
product_en_15="${DIST_DIR}/docs/en/current-product-shape/15-retro-closes-the-sprint-by-default.md"
product_ko_15="${DIST_DIR}/docs/ko/current-product-shape/15-retro-sprint-close.md"
product_en_19="${DIST_DIR}/docs/en/current-product-shape/19-obsidian-llm-wiki-continuity.md"
product_ko_19="${DIST_DIR}/docs/ko/current-product-shape/19-obsidian-llm-wiki-continuity.md"

assert_contains "${policy}" "Sprint Close Compile Contract" "EN policy close contract"
assert_contains "${policy}" '`report.md` and `retro.md` remain the sprint close records' "EN policy report retro source"
assert_contains "${policy}" "Do not copy the full report or retro into the wiki" "EN policy no duplication"
assert_contains "${policy}" "wiki compile checklist or a gap/waiver" "EN policy checklist"

assert_contains "${policy_ko}" "Sprint Close Compile Contract" "KO policy close contract"
assert_contains "${policy_ko}" '`report.md` 와 `retro.md` 는 sprint close record' "KO policy report retro source"
assert_contains "${policy_ko}" "report/retro 전문을 wiki 에 복사하지 않는다" "KO policy no duplication"
assert_contains "${policy_ko}" "wiki compile checklist 또는 gap/waiver" "KO policy checklist"

assert_contains "${common}" "sfs_write_wiki_compile_checklist()" "common helper"
assert_contains "${common}" "sfs_render_wiki_compile_checklist_body" "common render helper"
assert_contains "${common}" "sprint_records:" "common sprint records line"
assert_contains "${common}" "compile_only:" "common compile-only line"
assert_contains "${common}" "wiki-compile-checklist" "common marker"
assert_contains "${retro_script}" "sfs_write_wiki_compile_checklist" "retro invokes wiki compile"

assert_contains "${report_template}" "## 8. Wiki compile" "report template wiki section"
assert_contains "${report_template}" "<!-- solon:wiki-compile-checklist:start -->" "report template marker"
assert_contains "${report_template}" "report/retro 전문을 wiki 에 복사하지 않는다" "report template no duplication"
assert_contains "${retro_template}" "## 6. Wiki compile" "retro template wiki section"
assert_contains "${retro_template}" "<!-- solon:wiki-compile-checklist:start -->" "retro template marker"
assert_contains "${retro_template}" "durable conclusion 과 source link" "retro template durable conclusion"

assert_contains "${product_en_15}" "wiki compile checklist" "EN retro doc checklist"
assert_contains "${product_en_15}" "report/retro stay the sprint evidence SSoT" "EN retro doc source"
assert_contains "${product_ko_15}" "wiki compile checklist" "KO retro doc checklist"
assert_contains "${product_ko_15}" "report/retro 는 sprint evidence SSoT" "KO retro doc source"
assert_contains "${product_en_19}" "remain the authoritative close" "EN wiki doc close source"
assert_contains "${product_en_19}" "The wiki links to the close artifacts instead of copying them wholesale" "EN wiki doc no duplication"
assert_contains "${product_ko_19}" "authoritative close record" "KO wiki doc close source"
assert_contains "${product_ko_19}" "wiki 는 close artifact 전문을 복사하지 않고 링크합니다" "KO wiki doc no duplication"

echo "test-sfs-retro-wiki-compile-contract: OK"
