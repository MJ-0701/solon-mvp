#!/usr/bin/env bash
# Obsidian LLM wiki guidance must be recommended, routed, and non-blocking.
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

assert_contains "${policy}" "recommended companion" "EN policy recommended"
assert_contains "${policy}" "not a coercive dependency" "EN policy non-coercive"
assert_contains "${policy}" "New project" "EN policy new project flow"
assert_contains "${policy}" "Existing project" "EN policy existing project flow"
assert_contains "${policy}" "Build an Obsidian wiki by reference" "EN policy by-reference migration"
assert_contains "${policy}" "Never commit personal workspace state" "EN policy workspace boundary"
assert_contains "${policy_ko}" "권장" "KO policy recommended"
assert_contains "${policy_ko}" "필수 의존성처럼 강제하지 않는다" "KO policy non-coercive"
assert_contains "${policy_ko}" "신규 프로젝트" "KO policy new project flow"
assert_contains "${policy_ko}" "기존 프로젝트" "KO policy existing project flow"
assert_contains "${policy_ko}" "by-reference" "KO policy by-reference migration"

assert_contains "${CONTEXT_DIR}/_INDEX.md" "policies/obsidian-llm-wiki.md" "context index routes policy"
assert_contains "${CONTEXT_DIR}/kernel.md" "Obsidian LLM wiki is a recommended companion" "kernel recommended"
assert_contains "${CONTEXT_DIR}/kernel.md" "not a hard dependency" "kernel non-blocking"
assert_contains "${CONTEXT_DIR}/commands/start.md" "For a new SFS project" "start new project guidance"
assert_contains "${CONTEXT_DIR}/commands/start.md" "not a blocker" "start non-blocking"
assert_contains "${CONTEXT_DIR}/commands/adopt.md" "For existing projects with meaningful docs" "adopt existing project guidance"
assert_contains "${CONTEXT_DIR}/commands/adopt.md" "sfs start \"Obsidian LLM wiki baseline\"" "adopt next sprint"
assert_contains "${CONTEXT_DIR}/commands/plan.md" "policies/obsidian-llm-wiki.md" "plan loads policy"
assert_contains "${CONTEXT_DIR}/commands/implement.md" 'If `llm-wiki/` exists' "implement updates wiki maps"
assert_contains "${CONTEXT_DIR}/commands/implement.md" "durable retrieval across" "implement durable retrieval"
assert_contains "${CONTEXT_DIR}/policies/knowledge-pack-router.md" "Obsidian/wiki signals" "EN router signals"
assert_contains "${CONTEXT_DIR}/policies/knowledge-pack-router.ko.md" "Obsidian/wiki signals" "KO router signals"

assert_contains "${DIST_DIR}/templates/.gitignore.snippet" ".obsidian/workspace.json" "gitignore workspace"
assert_contains "${DIST_DIR}/templates/.gitignore.snippet" ".obsidian/plugins/" "gitignore plugins"
assert_contains "${DIST_DIR}/templates/codex-skill/SKILL.md" "Obsidian LLM wiki is a recommended companion" "codex skill"
assert_contains "${DIST_DIR}/templates/.agents/skills/sfs/SKILL.md" "Obsidian LLM wiki is a recommended companion" "agents skill"
assert_contains "${DIST_DIR}/templates/CLAUDE.md.template" "Obsidian LLM wiki is recommended" "claude template"
assert_contains "${DIST_DIR}/templates/AGENTS.md.template" "Obsidian LLM wiki is recommended" "agents template"
assert_contains "${DIST_DIR}/templates/GEMINI.md.template" "Obsidian LLM wiki is recommended" "gemini template"

assert_contains "${DIST_DIR}/docs/en/current-product-shape.md" "19-obsidian-llm-wiki-continuity.md" "EN product index"
assert_contains "${DIST_DIR}/docs/ko/current-product-shape.md" "19-obsidian-llm-wiki-continuity.md" "KO product index"
assert_contains "${DIST_DIR}/docs/en/current-product-shape/19-obsidian-llm-wiki-continuity.md" "recommended default, not a hard dependency" "EN product non-blocking"
assert_contains "${DIST_DIR}/docs/ko/current-product-shape/19-obsidian-llm-wiki-continuity.md" "권고 기본값이지 hard dependency" "KO product non-blocking"

echo "test-obsidian-llm-wiki-guidance: OK"
