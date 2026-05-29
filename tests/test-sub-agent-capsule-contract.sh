#!/usr/bin/env bash
# tests/test-sub-agent-capsule-contract.sh — B3 contract.
#
# The sub-agent capsule field contract must (a) exist as a routable policy in
# both languages, (b) name every required capsule field, and (c) be registered
# in the context index and tied to runtime-token-firewall.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONTEXT_DIR="${DIST_DIR}/templates/.sfs-local-template/context"

fail() { echo "FAIL: $*" >&2; exit 1; }
assert_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

policy="${CONTEXT_DIR}/policies/sub-agent-capsule-contract.md"
policy_ko="${CONTEXT_DIR}/policies/sub-agent-capsule-contract.ko.md"

# (a) routable: frontmatter id + load_when
assert_contains "${policy}" "id: sfs-policy-sub-agent-capsule-contract" "EN id"
assert_contains "${policy}" "load_when:" "EN load_when"
assert_contains "${policy_ko}" "id: sfs-policy-sub-agent-capsule-contract-ko" "KO id"

# (b) every required field named in both languages
for f in goal acceptance_criteria files_scope tools_allowed output_paths token_budget timeout pii_rules; do
  assert_contains "${policy}" "\`${f}\`" "EN field ${f}"
  assert_contains "${policy_ko}" "\`${f}\`" "KO field ${f}"
done

# (c) tied to firewall + validated by agent-build lens
assert_contains "${policy}" "runtime-token-firewall.md" "EN firewall link"
assert_contains "${policy}" "agent-build" "EN agent-build validation"
assert_contains "${policy_ko}" "runtime-token-firewall.md" "KO firewall link"

# (d) registered in the context index
assert_contains "${CONTEXT_DIR}/_INDEX.md" "policies/sub-agent-capsule-contract.md" "context index registration"

echo "PASS: test-sub-agent-capsule-contract.sh"
