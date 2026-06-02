#!/usr/bin/env bash
# Post-development external review and lean procedure guardrails stay routed.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SOURCE_ROOT="$(cd "${DIST_DIR}/../.." && pwd)"
CONTEXT_DIR="${DIST_DIR}/templates/.sfs-local-template/context"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

packs=(
  postdev-external-review-pack.md
  postdev-external-review-pack.ko.md
  lean-procedure-refactor-pack.md
  lean-procedure-refactor-pack.ko.md
)

for pack in "${packs[@]}"; do
  file="${CONTEXT_DIR}/policies/${pack}"
  assert_contains "${file}" "id:" "frontmatter id ${pack}"
  assert_contains "${file}" "summary:" "frontmatter summary ${pack}"
  assert_contains "${file}" "load_when:" "frontmatter load_when ${pack}"
  lines="$(wc -l <"${file}" | tr -d '[:space:]')"
  [[ "${lines}" -le 200 ]] || fail "${pack} exceeds 200 lines: ${lines}"
done

kernel="${CONTEXT_DIR}/kernel.md"
index="${CONTEXT_DIR}/_INDEX.md"
router="${CONTEXT_DIR}/policies/knowledge-pack-router.md"
router_ko="${CONTEXT_DIR}/policies/knowledge-pack-router.ko.md"
enterprise="${CONTEXT_DIR}/policies/enterprise-agent-team-pack.md"
review="${CONTEXT_DIR}/commands/review.md"
implement="${CONTEXT_DIR}/commands/implement.md"
release="${CONTEXT_DIR}/commands/release.md"
lens="${CONTEXT_DIR}/policies/review-lens-routing.md"
script="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-review.sh"
claude_template="${DIST_DIR}/templates/CLAUDE.md.template"
agents_template="${DIST_DIR}/templates/AGENTS.md.template"
gemini_template="${DIST_DIR}/templates/GEMINI.md.template"
codex_skill="${DIST_DIR}/templates/codex-skill/SKILL.md"
claude_command="${DIST_DIR}/templates/.claude/commands/sfs.md"
gemini_command="${DIST_DIR}/templates/.gemini/commands/sfs.toml"
legacy_gemini_command="${DIST_DIR}/commands/sfs.toml"
plugin_command="${DIST_DIR}/plugins/solon/commands/sfs.md"
codex_prompt="${DIST_DIR}/templates/.codex/prompts/sfs.md"
dist_claude="${DIST_DIR}/CLAUDE.md"

for file in "${index}" "${router}" "${router_ko}" "${enterprise}" "${review}" "${implement}"; do
  assert_contains "${file}" "postdev-external-review-pack" "postdev routing ${file}"
  assert_contains "${file}" "lean-procedure-refactor-pack" "lean routing ${file}"
done

assert_contains "${kernel}" "Post-development external review is evidence" "kernel postdev evidence"
assert_contains "${kernel}" "unavailable optional reviewers are recorded" "kernel optional reviewer"
assert_contains "${kernel}" "Lean procedure review is ambient" "kernel lean ambient"

assert_contains "${review}" "Claude Cowork/Gemini/GitHub" "review external lanes"
assert_contains "${review}" "unavailable lanes record blocked/not-applicable" "review unavailable lanes"
assert_contains "${review}" "Lean procedure review" "review lean"
assert_contains "${implement}" "after SFS self/cross review" "implement postdev order"
assert_contains "${implement}" "equivalent or stronger evidence remains" "implement lean quality"
assert_contains "${release}" "unavailable optional reviewers do not block release" "release optional reviewer"
assert_contains "${release}" "do not preserve ceremony" "release lean retro"

assert_contains "${lens}" "process-lean" "lens process lean"
assert_contains "${lens}" "lean-procedure-refactor-pack.md" "lens lean pack"
assert_contains "${script}" "process-lean" "script lens support"
assert_contains "${script}" "process/ceremony -> process-lean" "script alias hint"
assert_contains "${script}" "lean procedure and bottleneck review lens" "script label"

for file in "${codex_skill}" "${claude_command}" "${gemini_command}" "${legacy_gemini_command}" "${plugin_command}" "${codex_prompt}"; do
  assert_contains "${file}" "postdev external review" "template postdev ${file}"
  assert_contains "${file}" "lean procedure review" "template lean ${file}"
  assert_contains "${file}" "process-lean" "template process-lean ${file}"
done

# 0.7.2: substantive postdev/lean policy text moved out of the thin
# top-level CLAUDE.md into docs/maintenance/release-policy.md as part of
# the doc concern separation. Assert the new canonical location plus the
# cross-link from CLAUDE.md so the rule remains discoverable.
dist_release_policy="${DIST_DIR}/docs/maintenance/release-policy.md"
assert_contains "${dist_release_policy}" "postdev external review" "release-policy postdev"
assert_contains "${dist_release_policy}" "lean procedure review" "release-policy lean"
assert_contains "${dist_release_policy}" "process-lean" "release-policy process-lean"
assert_contains "${dist_claude}" "docs/maintenance/release-policy.md" "dist CLAUDE cross-link to release policy"

postdev_pack="${CONTEXT_DIR}/policies/postdev-external-review-pack.md"
postdev_pack_ko="${CONTEXT_DIR}/policies/postdev-external-review-pack.ko.md"
for file in "${postdev_pack}" "${postdev_pack_ko}"; do
  assert_contains "${file}" "CodeRabbit" "postdev CodeRabbit-style lane ${file}"
  assert_contains "${file}" "local diff review" "postdev local diff review ${file}"
  assert_contains "${file}" "PR-stage review" "postdev PR-stage review ${file}"
  assert_contains "${file}" "Autofix" "postdev autofix adjudication ${file}"
  assert_contains "${file}" "accepted/rejected/deferred" "postdev finding disposition ${file}"
done

source_surfaces=(
  "${SOURCE_ROOT}/.claude/commands/sfs.md"
  "${SOURCE_ROOT}/.gemini/commands/sfs.toml"
)

for file in "${source_surfaces[@]}"; do
  if [[ -f "${file}" ]]; then
    assert_contains "${file}" "postdev external review" "source postdev ${file}"
    assert_contains "${file}" "lean procedure review" "source lean ${file}"
    assert_contains "${file}" "process-lean" "source process-lean ${file}"
  fi
done

echo "test-postdev-review-lean-guardrails: OK"
