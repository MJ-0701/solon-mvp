#!/usr/bin/env bash
# Mainline-first, Gate 6 data validation, OWASP/logging, and checklist guardrails.
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
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

packs=(
  mainline-focus-guard.md
  mainline-focus-guard.ko.md
  gate6-data-validation-pack.md
  gate6-data-validation-pack.ko.md
  agentic-security-logging-pack.md
  agentic-security-logging-pack.ko.md
  wiki-mission-checklist-skill.md
  wiki-mission-checklist-skill.ko.md
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
plan="${CONTEXT_DIR}/commands/plan.md"
implement="${CONTEXT_DIR}/commands/implement.md"
review="${CONTEXT_DIR}/commands/review.md"
release="${CONTEXT_DIR}/commands/release.md"
tidy="${CONTEXT_DIR}/commands/tidy.md"
review_lens="${CONTEXT_DIR}/policies/review-lens-routing.md"
plan_template="${DIST_DIR}/templates/.sfs-local-template/sprint-templates/plan.md"
implement_template="${DIST_DIR}/templates/.sfs-local-template/sprint-templates/implement.md"
review_template="${DIST_DIR}/templates/.sfs-local-template/sprint-templates/review.md"
claude_template="${DIST_DIR}/templates/CLAUDE.md.template"
agents_template="${DIST_DIR}/templates/AGENTS.md.template"
gemini_template="${DIST_DIR}/templates/GEMINI.md.template"
codex_skill="${DIST_DIR}/templates/codex-skill/SKILL.md"
dist_claude="${DIST_DIR}/CLAUDE.md"
# 0.7.2: § 배포 원칙 8 ("Mainline-first + Gate 6 data/security") moved out
# of CLAUDE.md body into docs/maintenance/release-policy.md as part of the
# doc concern separation. CLAUDE.md is now a thin agent entry that
# cross-links to it. The canonical assertion target shifted accordingly.
dist_release_policy="${DIST_DIR}/docs/maintenance/release-policy.md"

for file in "${index}" "${router}" "${router_ko}" "${plan}" "${implement}" "${review}"; do
  assert_contains "${file}" "mainline-focus-guard" "mainline routing ${file}"
  assert_contains "${file}" "gate6-data-validation-pack" "data validation routing ${file}"
  assert_contains "${file}" "agentic-security-logging-pack" "security logging routing ${file}"
  assert_contains "${file}" "wiki-mission-checklist-skill" "checklist routing ${file}"
done

assert_contains "${kernel}" "Mainline Focus Guard is ambient" "kernel mainline focus"
assert_contains "${kernel}" 'only true `unblocker`' "kernel unblocker only"
assert_contains "${kernel}" "Long-context checklist skill is ambient" "kernel checklist"
assert_contains "${kernel}" "Gate 6 data validation is mandatory" "kernel data validation"
assert_contains "${kernel}" "Mock data is not acceptance evidence" "kernel mock not acceptance"
assert_contains "${kernel}" "OWASP-style web/API/LLM/MCP" "kernel OWASP families"
assert_contains "${kernel}" 'production `console.log`' "kernel console log"
assert_contains "${kernel}" "Datadog" "kernel Datadog"
assert_contains "${CONTEXT_DIR}/policies/agentic-security-logging-pack.md" "Unattended or always-approve agent runs require isolation first" "EN security unattended approval boundary"
assert_contains "${CONTEXT_DIR}/policies/agentic-security-logging-pack.ko.md" "unattended 또는 always-approve agent run 은 먼저 격리가 필요" "KO security unattended approval boundary"
assert_contains "${CONTEXT_DIR}/policies/agentic-security-logging-pack.md" "Report-channel bots need explicit channel/app permission" "EN security report-channel bot boundary"
assert_contains "${CONTEXT_DIR}/policies/agentic-security-logging-pack.ko.md" "보고 channel bot 은 channel/app permission inventory" "KO security report-channel bot boundary"
assert_contains "${CONTEXT_DIR}/policies/agentic-security-logging-pack.md" "server/channel/user/actor allowlists" "EN security chatops allowlist"
assert_contains "${CONTEXT_DIR}/policies/agentic-security-logging-pack.ko.md" "server/channel/user/actor allowlist" "KO security chatops allowlist"
assert_contains "${CONTEXT_DIR}/policies/agentic-security-logging-pack.md" "thread/archive retention" "EN security thread retention"
assert_contains "${CONTEXT_DIR}/policies/agentic-security-logging-pack.md" "Credit-spending generation tools require a preflight manifest" "EN security credit-spend generation preflight"
assert_contains "${CONTEXT_DIR}/policies/agentic-security-logging-pack.ko.md" "credit 을 쓰는 generation tool 은 실행 전 preflight manifest" "KO security credit-spend generation preflight"

assert_contains "${plan}" "side work as mainline" "plan side-work classification"
assert_contains "${plan}" "Add data" "plan data AC"
assert_contains "${plan}" "OWASP family" "plan OWASP"
assert_contains "${plan}" "checklist path" "plan checklist"
assert_contains "${implement}" "minimum viable unblocker work" "implement unblocker"
assert_contains "${implement}" "representative synthetic fixtures" "implement fixtures"
assert_contains "${implement}" 'production `console.log`' "implement console cleanup"
assert_contains "${implement}" "wiki/workbench mission checklist" "implement checklist"
assert_contains "${review}" "Gate 6 mainline review" "review mainline"
assert_contains "${review}" "Gate 6 data review" "review data"
assert_contains "${review}" "Gate 6 security/logging review" "review security"
assert_contains "${review}" "Gate 6 checklist review" "review checklist"
assert_contains "${review_lens}" "agentic-security-logging-pack.md" "review lens security pack"
assert_contains "${review_lens}" "gate6-data-validation-pack.md" "review lens data pack"
assert_contains "${review_lens}" "mainline-focus-guard.md" "review lens mainline pack"
assert_contains "${release}" "no stray production" "release console cleanup"
assert_contains "${release}" "Datadog or equivalent" "release observability"
assert_contains "${tidy}" "wiki/workbench mission checklist" "tidy checklist close"

assert_contains "${plan_template}" "Mainline Focus Ledger" "plan template mainline"
assert_contains "${plan_template}" "Data Validation / Security / Checklist Plan" "plan template data security"
assert_contains "${implement_template}" "Data / Security / Checklist Guard" "implement template data security"
assert_contains "${review_template}" "Mainline / Data / Security / Checklist Ledger" "review template combined ledger"

for file in "${codex_skill}"; do
  assert_contains "${file}" "Mainline Focus Guard" "agent template mainline ${file}"
  assert_contains "${file}" "OWASP-style security/logging/Datadog evidence" "agent template security ${file}"
  assert_contains "${file}" "checklist reconciliation" "agent template checklist ${file}"
done

# 0.7.2: canonical location for the § 배포 원칙 8 text moved.
assert_contains "${dist_release_policy}" "Mainline-first + Gate 6 data/security" "dist release-policy product checklist"
# CLAUDE.md must still cross-link to the new canonical location so agents
# discover the rule even after the body was moved.
assert_contains "${dist_claude}" "docs/maintenance/release-policy.md" "dist CLAUDE cross-link to release policy"

echo "test-mainline-data-security-guardrails: OK"
