#!/usr/bin/env bash
# Runtime Token Firewall guardrails prevent full-history worker/review bridges.
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

assert_not_contains() {
  local file="$1"
  local needle="$2"
  local label="$3"

  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  if grep -Fq -- "${needle}" "${file}"; then
    fail "${label}: unexpected '${needle}'"
  fi
}

context="${DIST_DIR}/templates/.sfs-local-template/context"
index="${context}/_INDEX.md"
kernel="${context}/kernel.md"
token_policy="${context}/policies/token-harness.md"
firewall_policy="${context}/policies/runtime-token-firewall.md"
implement="${context}/commands/implement.md"
review="${context}/commands/review.md"
review_script="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-review.sh"
adapter_files=(
  "${DIST_DIR}/templates/codex-skill/SKILL.md"
  "${DIST_DIR}/templates/.agents/skills/sfs/SKILL.md"
  "${DIST_DIR}/templates/.claude/commands/sfs.md"
  "${DIST_DIR}/templates/.gemini/commands/sfs.toml"
  "${DIST_DIR}/templates/.codex/prompts/sfs.md"
  "${DIST_DIR}/commands/sfs.toml"
  "${DIST_DIR}/plugins/solon/commands/sfs.md"
)

assert_contains "${index}" "policies/runtime-token-firewall.md" "index runtime token firewall policy"

assert_contains "${firewall_policy}" "Capsule-only handoff is the default" "firewall capsule default"
assert_contains "${firewall_policy}" "full conversation" "firewall no full history"
assert_contains "${firewall_policy}" "Claude in-process Codex/Gemini plugin wrappers" "firewall plugin wrapper boundary"
assert_contains "${firewall_policy}" "Poll artifacts, not thoughts" "firewall artifact polling"
assert_contains "${firewall_policy}" "Bulk verification/investigation work is a compressed-return worker slice" "firewall bulk verification worker"
assert_contains "${firewall_policy}" "build logs, smoke logs, test logs" "firewall bulk log examples"
assert_contains "${firewall_policy}" "Preserve the lead session for user intent" "firewall lead context preservation"
assert_contains "${firewall_policy}" "docs diff, ADR delta, or compact run brief" "firewall docs-diff capsule"
assert_contains "${firewall_policy}" "Chat threads are not full-history handoffs" "firewall chat thread boundary"
assert_contains "${firewall_policy}" "compact summary artifact" "firewall archived thread resume"
assert_contains "${firewall_policy}" "Budget failure is a product finding" "firewall budget finding"

assert_contains "${kernel}" "Runtime Token Firewall is ambient" "kernel firewall"
assert_contains "${kernel}" "capsule-only" "kernel capsule-only"
assert_contains "${kernel}" "full conversation history" "kernel no full history"

assert_contains "${token_policy}" "Apply Runtime Token Firewall before delegating work" "token policy firewall"
assert_contains "${token_policy}" "Never forward full conversation history" "token policy no full history"
assert_contains "${token_policy}" "Poll run artifacts instead of chat state" "token policy artifact polling"
assert_contains "${token_policy}" "Delegate heavy verification/investigation" "token policy heavy verification delegation"

assert_contains "${implement}" "Worker handoff must follow Runtime Token Firewall" "implement worker firewall"
assert_contains "${implement}" "goal, AC, files_scope" "implement capsule fields"
assert_contains "${implement}" "plugin wrapper, rescue subagent" "implement wrapper boundary"
assert_contains "${implement}" "Poll worker artifacts" "implement artifact polling"
assert_contains "${implement}" "I/O-heavy verification/investigation" "implement heavy verification delegation"

assert_contains "${review}" "Review handoff must follow Runtime Token Firewall" "review firewall"
assert_contains "${review}" "bounded" "review capsule evidence"
assert_contains "${review}" "rescue subagents" "review rescue boundary"
assert_contains "${review}" "Do not request full chat history" "review no full chat"
assert_contains "${review}" "compressed-return worker" "review heavy verification delegation"

assert_contains "${review_script}" "Runtime Token Firewall applies to this review" "review prompt firewall"
assert_contains "${review_script}" "history-forwarding review bridge rejected" "review script rejects history bridge"
assert_contains "${review_script}" "codex-plugin/Claude in-process Codex wrappers are blocked" "review script blocks codex plugin"
assert_contains "${review_script}" "history_forwarding_executor_cmd" "review script detects risky override"
assert_contains "${review_script}" "SFS_REVIEW_CODEX_CMD" "review script still supports capsule codex cmd"
assert_not_contains "${review_script}" "SFS_REVIEW_CODEX_PLUGIN_CMD" "review script no codex plugin override"

for file in "${adapter_files[@]}"; do
  assert_contains "${file}" "I/O-heavy verification/investigation" "adapter heavy verification delegation ${file}"
  assert_contains "${file}" "compressed-return worker" "adapter compressed-return worker ${file}"
done

echo "test-runtime-token-firewall: OK"
