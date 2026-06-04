#!/usr/bin/env bash
# BWU-13: verifier context split is documented as a generalized SFS pattern.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONTEXT_DIR="${DIST_DIR}/templates/.sfs-local-template/context"

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

assert_not_contains() {
  local file="$1"
  local needle="$2"
  local label="$3"

  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  if grep -Fq -- "${needle}" "${file}"; then
    fail "${label}: forbidden vendor-specific detail '${needle}'"
  fi
}

flow_policy="${CONTEXT_DIR}/policies/flow-conformance-postflight.md"
flow_command="${CONTEXT_DIR}/commands/flowcheck.md"
harness_policy="${CONTEXT_DIR}/policies/harness-autonomy.md"
guide_en="${DIST_DIR}/docs/en/guide/10-9-optional-multi-agent-use.md"
harness_ko="${DIST_DIR}/docs/ko/current-product-shape/22-project-harness-map.md"

assert_contains "${flow_policy}" "rule-scoped verifier context" "FCP rule-scoped context"
assert_contains "${flow_policy}" "skeptic persona" "FCP skeptic persona"
assert_contains "${flow_policy}" "false-positive suppression" "FCP false-positive control"
assert_contains "${flow_policy}" "fan-out/synthesize barrier" "FCP synthesize barrier"
assert_contains "${flow_policy}" "not a new flowcheck critical invariant" "FCP no new critical invariant"

assert_contains "${flow_command}" "verifier context split" "flowcheck command context split"
assert_contains "${flow_command}" "separate verifier context" "flowcheck separate context"
assert_contains "${flow_command}" "documentation-level recommendation" "flowcheck recommendation scope"

assert_contains "${harness_policy}" "advisor-Code file bus" "harness file bus"
assert_contains "${harness_policy}" "artifact capsule" "harness artifact capsule"
assert_contains "${harness_policy}" "lead synthesizes" "harness lead synthesizes"
assert_contains "${harness_policy}" "fan-out/synthesize barrier" "harness synthesize barrier"

assert_contains "${guide_en}" "advisor-Code file bus" "guide file bus"
assert_contains "${guide_en}" "separate verifier context" "guide separate verifier context"
assert_contains "${guide_en}" "skeptic persona" "guide skeptic persona"

assert_contains "${harness_ko}" "advisor-Code file bus" "ko harness file bus"
assert_contains "${harness_ko}" "fan-out/synthesize barrier" "ko harness synthesize barrier"

for file in "${flow_policy}" "${flow_command}" "${harness_policy}" "${guide_en}" "${harness_ko}"; do
  assert_not_contains "${file}" "council tournament" "reference absorption guard ${file}"
  assert_not_contains "${file}" "JavaScript workflow" "reference absorption guard ${file}"
  assert_not_contains "${file}" "vendor template" "reference absorption guard ${file}"
done

echo "test-verifier-context-split-docs: OK"
