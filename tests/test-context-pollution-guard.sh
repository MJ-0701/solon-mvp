#!/usr/bin/env bash
# Context Pollution Guard: durable Solon context keeps conclusions, not prompt/transcript bulk.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1"
  local needle="$2"
  local label="$3"

  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

assert_not_contains_any() {
  local file="$1"
  local label="$2"
  shift 2

  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  local needle
  for needle in "$@"; do
    if grep -Fq -- "${needle}" "${file}"; then
      fail "${label}: unexpected scratch marker '${needle}'"
    fi
  done
}

context_dir="${DIST_DIR}/templates/.sfs-local-template/context"
policy="${context_dir}/policies/context-pollution-guard.md"
index="${context_dir}/_INDEX.md"
kernel="${context_dir}/kernel.md"
token_policy="${context_dir}/policies/token-harness.md"
capture="${context_dir}/commands/capture.md"
review="${context_dir}/commands/review.md"
tidy="${context_dir}/commands/tidy.md"
capture_script="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-capture.sh"
readme="${DIST_DIR}/README.md"
guide="${DIST_DIR}/GUIDE.md"
shape_en="${DIST_DIR}/docs/en/current-product-shape.md"
shape_ko="${DIST_DIR}/docs/ko/current-product-shape.md"

assert_contains "${index}" "context-pollution-guard.md" "index routes guard"
assert_contains "${policy}" "Core product and adapter context stays thin" "policy core docs"
assert_contains "${policy}" "Do not copy prompt bodies" "policy prompt bodies"
assert_contains "${policy}" "Release is not clean" "policy release blocker"

assert_contains "${kernel}" "Context Pollution Guard is ambient" "kernel ambient guard"
assert_contains "${kernel}" "treat residue as a review" "kernel review finding"
assert_contains "${token_policy}" "Apply Context Pollution Guard" "token policy guard"
assert_contains "${token_policy}" "Prompt/context bloat is a product finding" "token policy finding"

assert_contains "${capture}" "not use capture as a full transcript recorder" "capture no transcript"
assert_contains "${capture}" "enforces a small text budget" "capture text budget"
assert_contains "${capture_script}" "SFS_CAPTURE_TEXT_MAX_CHARS" "capture runtime budget env"
assert_contains "${capture_script}" "capture text too long" "capture runtime guard"
assert_contains "${review}" "Review durable product/context artifacts" "review guard"
assert_contains "${review}" "burn future token budget" "review token budget"
assert_contains "${tidy}" "Context Pollution Guard applies while closing" "tidy guard"
assert_contains "${tidy}" "archive/evidence pointer instead" "tidy pointer"

assert_contains "${readme}" "긴 prompt, 전체 대화" "readme capture boundary"
assert_contains "${guide}" "flow checkpoint 이지 prompt/transcript 저장소가 아닙니다" "guide capture boundary"
assert_contains "${shape_en}" "Prompt bodies" "english product shape guard"
assert_contains "${shape_ko}" "core product context 에는 결론과 evidence path 만" "korean product shape guard"

for core_doc in \
  "${readme}" \
  "${guide}" \
  "${DIST_DIR}/templates/SFS.md.template" \
  "${DIST_DIR}/templates/CLAUDE.md.template" \
  "${DIST_DIR}/templates/AGENTS.md.template" \
  "${DIST_DIR}/templates/GEMINI.md.template" \
  "${kernel}" \
  "${index}"
do
  assert_not_contains_any "${core_doc}" "core scratch hygiene ${core_doc}" \
    "tmp/review-prompts/" \
    "prompt_body:" \
    "bridge-probe.stdout" \
    "bridge-probe.stderr" \
    "result_path:"
done

echo "test-context-pollution-guard: OK"
