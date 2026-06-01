#!/usr/bin/env bash
# AI 업무 intake 라우팅 계약이 제품 컨텍스트/템플릿/문서에 유지되는지 검증한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONTEXT_DIR="${DIST_DIR}/templates/.sfs-local-template/context"
TEMPLATE_DIR="${DIST_DIR}/templates/.sfs-local-template/sprint-templates"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

policy="${CONTEXT_DIR}/policies/ai-work-intake-routing.md"
kernel="${CONTEXT_DIR}/kernel.md"
start="${CONTEXT_DIR}/commands/start.md"
brainstorm="${CONTEXT_DIR}/commands/brainstorm.md"
plan="${CONTEXT_DIR}/commands/plan.md"
brainstorm_template="${TEMPLATE_DIR}/brainstorm.md"
plan_template="${TEMPLATE_DIR}/plan.md"
docs_en="${DIST_DIR}/docs/en/current-product-shape/20-ai-work-intake-routing.md"
docs_ko="${DIST_DIR}/docs/ko/current-product-shape/20-ai-work-intake-routing.md"

assert_contains "${CONTEXT_DIR}/_INDEX.md" "policies/ai-work-intake-routing.md" "context index routes intake policy"
assert_contains "${policy}" "Goal: what outcome is being produced" "policy goal"
assert_contains "${policy}" "Materials: source notes" "policy materials"
assert_contains "${policy}" "Ask-back rule" "policy ask-back"
assert_contains "${policy}" "Output format" "policy output format"
assert_contains "${policy}" "One-off work" "policy one-off"
assert_contains "${policy}" "Repeated work" "policy repeated"
assert_contains "${policy}" "Batch workspace work" "policy batch"
assert_contains "${policy}" "vendor-neutral" "policy vendor neutral"
assert_contains "${policy}" "High-Context Prompt Normalization" "policy high-context prompt normalization"
assert_contains "${policy}" "Prefer positive target behavior over negative-only phrasing" "policy positive target behavior"
assert_contains "${policy}" "human review boundary" "policy nuance human boundary"

assert_contains "${kernel}" "goal, materials, ask-back rule, and output format" "kernel four-part intake"
assert_contains "${kernel}" "one-off, repeated project memory, or batch workspace" "kernel work-size routing"
assert_contains "${start}" "policies/ai-work-intake-routing.md" "start loads policy"
assert_contains "${start}" "one-off chat, repeated project memory, or a batch workspace" "start work-size routing"
assert_contains "${brainstorm}" 'Apply `policies/ai-work-intake-routing.md`' "brainstorm loads policy"
assert_contains "${brainstorm}" "goal, materials, ask-back rule, and output format" "brainstorm four-part intake"
assert_contains "${plan}" "Carry Gate 2 AI work intake forward" "plan carries intake"

assert_contains "${brainstorm_template}" "## 1.1 AI Work Intake" "brainstorm template intake section"
assert_contains "${brainstorm_template}" "작업 크기: one-off / repeated / batch workspace" "brainstorm template work size"
assert_contains "${plan_template}" "## 1.1 AI Work Intake Carryover" "plan template intake carryover"
assert_contains "${plan_template}" "AI work intake 의 goal/materials/ask-back/output format/work size" "plan review checklist"

assert_contains "${DIST_DIR}/docs/en/current-product-shape.md" "20-ai-work-intake-routing.md" "EN product index"
assert_contains "${DIST_DIR}/docs/ko/current-product-shape.md" "20-ai-work-intake-routing.md" "KO product index"
assert_contains "${docs_en}" "Goal: what is being produced" "EN doc goal"
assert_contains "${docs_en}" "Batch workspace" "EN doc batch"
assert_contains "${docs_en}" "vendor-neutral" "EN doc vendor neutral"
assert_contains "${docs_ko}" "목표: 무엇을 만들고 왜 필요한지" "KO doc goal"
assert_contains "${docs_ko}" "대량 작업" "KO doc batch"
assert_contains "${docs_ko}" "특정 vendor 에 묶이지 않습니다" "KO doc vendor neutral"

echo "test-ai-work-intake-routing: OK"
