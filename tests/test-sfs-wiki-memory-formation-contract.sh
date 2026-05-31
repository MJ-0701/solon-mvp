#!/usr/bin/env bash
# Obsidian/LLM wiki should form project memory when docs are missing, not only
# migrate already-good documentation.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONTEXT_DIR="${DIST_DIR}/templates/.sfs-local-template/context"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

policy="${CONTEXT_DIR}/policies/obsidian-llm-wiki.md"
policy_ko="${CONTEXT_DIR}/policies/obsidian-llm-wiki.ko.md"
adopt="${CONTEXT_DIR}/commands/adopt.md"
intake="${CONTEXT_DIR}/policies/ai-work-intake-routing.md"
kernel="${CONTEXT_DIR}/kernel.md"
product_en_19="${DIST_DIR}/docs/en/current-product-shape/19-obsidian-llm-wiki-continuity.md"
product_ko_19="${DIST_DIR}/docs/ko/current-product-shape/19-obsidian-llm-wiki-continuity.md"
product_en_20="${DIST_DIR}/docs/en/current-product-shape/20-ai-work-intake-routing.md"
product_ko_20="${DIST_DIR}/docs/ko/current-product-shape/20-ai-work-intake-routing.md"

assert_contains "${policy}" "Documentation-poor project" "EN policy documentation-poor activation"
assert_contains "${policy}" "Memory Formation And Migration" "EN policy memory formation section"
assert_contains "${policy}" "git commit history" "EN policy git-history evidence"
assert_contains "${policy}" "project map, domain/DDD map, decision ledger, unknowns/gaps, questions ledger" "EN policy baseline artifacts"
assert_contains "${policy}" "already-answered/questions ledger" "EN policy repeated question guard"
assert_contains "${policy}" "ask-again-only-if" "EN policy stale condition"

assert_contains "${policy_ko}" "문서가 부족한 프로젝트" "KO policy documentation-poor activation"
assert_contains "${policy_ko}" "Memory Formation And Migration" "KO policy memory formation section"
assert_contains "${policy_ko}" "git commit history" "KO policy git-history evidence"
assert_contains "${policy_ko}" "project map, domain/DDD map, decision ledger, unknowns/gaps" "KO policy baseline artifacts"
assert_contains "${policy_ko}" "already-answered/questions ledger" "KO policy repeated question guard"
assert_contains "${policy_ko}" "ask-again-only-if" "KO policy stale condition"

assert_contains "${adopt}" 'memory formation after `adopt --apply`' "adopt memory formation"
assert_contains "${adopt}" "code, git commit history, tests, config" "adopt evidence sources"
assert_contains "${adopt}" "questions ledger" "adopt questions ledger"
assert_contains "${adopt}" 'sfs start "Obsidian LLM wiki memory formation"' "adopt next slice"

assert_contains "${intake}" "For documentation-poor projects" "intake docs-poor evidence"
assert_contains "${intake}" "Memory-formation work" "intake routing type"
assert_contains "${intake}" "already-answered facts" "intake repeated question guard"

assert_contains "${kernel}" "memory formation, not just migration" "kernel formation"
assert_contains "${kernel}" "Before asking the user to repeat project background" "kernel no repeat ask"
assert_contains "${kernel}" "questions/decision ledger" "kernel ledger"

assert_contains "${product_en_19}" "memory formation" "EN product wiki formation"
assert_contains "${product_en_19}" "Missing docs are treated as a gap to fill" "EN product docs gap"
assert_contains "${product_en_19}" "questions ledger" "EN product questions ledger"
assert_contains "${product_ko_19}" "memory formation" "KO product wiki formation"
assert_contains "${product_ko_19}" "문서 부재는" "KO product docs gap"
assert_contains "${product_ko_19}" "questions ledger" "KO product questions ledger"
assert_contains "${product_en_20}" "intake starts with memory formation" "EN intake product formation"
assert_contains "${product_en_20}" "already-answered questions" "EN intake repeated question guard"
assert_contains "${product_ko_20}" "intake 가 memory formation" "KO intake product formation"
assert_contains "${product_ko_20}" "already-answered question" "KO intake repeated question guard"

echo "test-sfs-wiki-memory-formation-contract: OK"
