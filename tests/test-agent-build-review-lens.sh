#!/usr/bin/env bash
# agent-build review lens — contract test.
#
# Verifies that the `agent-build` lens is registered end-to-end:
#   1. The lens value normalizer accepts both the canonical name and
#      the documented aliases.
#   2. The lens label resolver returns a non-default human label.
#   3. The infer_review_lens heuristic routes the expected keywords and
#      file paths into `agent-build`.
#   4. The routed policy document `agent-build-review-lens.md` exists,
#      loads-on the right `load_when` triggers, and lists the seven
#      review subsections the CPO must verify.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REVIEW_SH="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-review.sh"
POLICY_MD="${DIST_DIR}/templates/.sfs-local-template/context/policies/agent-build-review-lens.md"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f "${REVIEW_SH}" ]] || fail "missing ${REVIEW_SH}"
[[ -f "${POLICY_MD}" ]] || fail "missing ${POLICY_MD}"

# ── 1) The normalizer accepts the canonical name and aliases. ───────
for alias in agent-build agent agents agent-sdk mcp mcp-server agent-tool sub-agent subagent; do
  grep -qF "${alias}" "${REVIEW_SH}" \
    || fail "sfs-review.sh normalizer missing alias: ${alias}"
done

# ── 2) Lens label resolver returns a non-default label. ─────────────
grep -qE 'agent-build\)[[:space:]]*printf' "${REVIEW_SH}" \
  || fail "sfs-review.sh review_lens_label missing agent-build branch"

# ── 3) Valid-lens error message advertises agent-build. ─────────────
grep -qE 'release, agent-build' "${REVIEW_SH}" \
  || fail "sfs-review.sh valid-lens error message missing agent-build"

# ── 4) infer_review_lens routes the expected signals. ───────────────
for kw in 'agent sdk' 'claude agent sdk' 'mcp server' 'mcp-server' 'sub-agent' '에이전트 sdk'; do
  grep -qF -- "${kw}" "${REVIEW_SH}" \
    || fail "sfs-review.sh infer_review_lens missing keyword: ${kw}"
done
grep -qF 'mcp-server/' "${REVIEW_SH}" \
  || fail "sfs-review.sh infer_review_lens missing mcp-server/ path signal"
grep -qF 'claude-agent-sdk-zero/' "${REVIEW_SH}" \
  || fail "sfs-review.sh infer_review_lens missing claude-agent-sdk-zero/ path signal"

# ── 5) Policy doc frontmatter advertises the right load_when triggers. ─
for trig in 'lens:agent-build' '"agent sdk"' '"claude agent sdk"' '"mcp server"' '"mcp tool"' '"sub-agent"' '"agent build"'; do
  grep -qF -- "${trig}" "${POLICY_MD}" \
    || fail "${POLICY_MD} load_when missing trigger: ${trig}"
done

# ── 6) Policy doc covers the seven review subsections. ──────────────
for section in \
  '1. Tool surface scope' \
  '2. Permission posture' \
  '3. Sub-agent isolation' \
  '4. System prompt drift' \
  '5. Bash adapter SSoT' \
  '6. Evidence + audit' \
  '7. Failure modes specific to agent-build'
do
  grep -qF -- "${section}" "${POLICY_MD}" \
    || fail "${POLICY_MD} missing review subsection: ${section}"
done

for onboarding in \
  'Identity/persona text is kept separate from operating process' \
  'Scheduled or report-channel agents declare trigger' \
  'Remote MCP media-generation connectors declare endpoint provenance' \
  'Chat/messenger bridges declare server/channel/user/actor allowlists' \
  'Chat channels are coordination surfaces; task threads are bounded contexts' \
  'Cross-agent review feedback is adjudicated item by item' \
  'ChatOps loop drift'
do
  grep -qF -- "${onboarding}" "${POLICY_MD}" \
    || fail "${POLICY_MD} missing AI employee onboarding check: ${onboarding}"
done

# ── 7) Policy doc references the companion artifacts shipped in 0.7.0. ─
for cross in solon-safe-permissions.yaml mcp-server/README.md agentic-security-logging-pack.md; do
  grep -qF "${cross}" "${POLICY_MD}" \
    || fail "${POLICY_MD} missing cross-reference: ${cross}"
done

echo "test-agent-build-review-lens: OK"
