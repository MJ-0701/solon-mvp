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

# (e) WU-E: verifier ≠ author named in both languages (handoff rule + lens)
assert_contains "${policy}" "the same instance as the authoring agent" "EN verifier≠author handoff rule"
assert_contains "${policy}" "the verifying agent is a different instance from the author" "EN verifier≠author lens"
assert_contains "${policy_ko}" "저작 agent 와 동일" "KO verifier≠author handoff rule"
assert_contains "${policy_ko}" "검증 agent 가 저작자와 다른 인스턴스인지" "KO verifier≠author lens"

# (e') council policy carries the same verifier ≠ author rule
council="${CONTEXT_DIR}/policies/division-subagent-council.md"
assert_contains "${council}" "verifier ≠ author" "council verifier≠author rule"

# (f) negative lock — self-verification must never be permitted (WU regression direction)
refuse() {
  local file="$1" needle="$2" label="$3"
  ! grep -Fq -- "${needle}" "${file}" || fail "${label}: forbidden phrase present '${needle}'"
}
refuse "${policy}" "the same agent may both author and verify" "EN self-verify allowance"
refuse "${policy_ko}" "저작 agent 가 자신을 검증해도 된다" "KO self-verify allowance"

echo "PASS: test-sub-agent-capsule-contract.sh"
