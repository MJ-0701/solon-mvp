#!/usr/bin/env bash
# Agent config review cadence — model/runtime evolution should trigger cleanup.
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
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}' in ${file}"
}

release_policy="${DIST_DIR}/docs/maintenance/release-policy.md"
adapter_policy="${DIST_DIR}/templates/.sfs-local-template/context/policies/agent-adapter-doc-refactor.md"

assert_contains "${release_policy}" "Config-review cadence for model evolution" "release policy cadence heading"
assert_contains "${release_policy}" "3-6" "release policy cadence interval"
assert_contains "${release_policy}" "major model release" "release policy model-release trigger"
assert_contains "${release_policy}" "stale workaround" "release policy stale workaround cleanup"
assert_contains "${release_policy}" "How Claude Code works in large codebases" "release policy historical evidence"

assert_contains "${adapter_policy}" "Config Review Cadence" "routed adapter policy cadence heading"
assert_contains "${adapter_policy}" "3-6" "routed adapter policy cadence interval"
assert_contains "${adapter_policy}" "stale workaround" "routed adapter policy stale workaround cleanup"

for template in \
  "${DIST_DIR}/templates/CLAUDE.md.template" \
  "${DIST_DIR}/templates/AGENTS.md.template" \
  "${DIST_DIR}/templates/GEMINI.md.template"; do
  assert_contains "${template}" "frontmatter_only: true" "adapter template frontmatter marker"
  assert_contains "${template}" "config_review_cadence:" "adapter template cadence pointer"
  assert_contains "${template}" "3-6 months" "adapter template cadence interval"
  assert_contains "${template}" "major model/runtime release" "adapter template model runtime trigger"
done

echo "test-agent-config-review-cadence: OK"
