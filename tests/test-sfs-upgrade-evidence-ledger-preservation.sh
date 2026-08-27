#!/usr/bin/env bash
# 활성 sprint evidence 원장과 approval 별칭의 업그레이드 회귀를 잠근다.
# tests/test-sfs-upgrade-evidence-ledger-preservation.sh — upgrade preserves evidence; approval normalizes.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-upgrade-evidence-ledger.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

run_sfs() {
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" "$@"
}

capture_id_from_output() {
  sed -nE 's/.*\| capture ([^[:space:]]+).*/\1/p' <<<"$1"
}

assert_capture_id() {
  local capture_id="$1" label="$2"
  grep -Fq -- "\"capture_id\":\"${capture_id}\"" .sfs-local/events.jsonl \
    || fail "${label}: capture_id ${capture_id} missing from active event ledger"
}

append_conformant_override_events() {
  run_sfs event model_resolved agent_role=implementation-worker resolved_tier=execution_high resolved_model=opus-4.7 source=user-override >/dev/null
  run_sfs event conflict_surfaced kind=model-tier detail=user-requested-override resolved_by=user >/dev/null
  run_sfs event gate_passed gate=G5 order_index=1 self_cpo=pass >/dev/null
  run_sfs event verification_pair implementer=implementation-worker verifier=cpo-evaluator implementer_context=worker-1 verifier_context=review-1 gate=G5 >/dev/null
}

run_flowcheck() {
  set +e
  FLOW_OUT="$(run_sfs flowcheck 2>&1)"
  FLOW_RC=$?
  set -e
}

cd "${TMP_DIR}"
git init -q
git config user.email sfs-test@example.invalid
git config user.name "SFS Test"
printf '# Upgrade Evidence Ledger Project\n' > README.md
git add README.md
git commit -qm 'initial'

run_sfs init --layout thin --yes >/dev/null
run_sfs start "preserve active evidence across upgrade" >/dev/null

approval_out="$(run_sfs capture --kind user-approval --scope sprint --gate 3 "User approved the scoped Gate 3 override.")"
approval_id="$(capture_id_from_output "${approval_out}")"
[[ -n "${approval_id}" ]] || fail "could not parse user-approval capture id: ${approval_out}"

note_out="$(run_sfs note --gate 3 "A later note at the same gate must not erase approval evidence.")"
note_id="$(capture_id_from_output "${note_out}")"
[[ -n "${note_id}" ]] || fail "could not parse note capture id: ${note_out}"
[[ "${approval_id}" != "${note_id}" ]] || fail "capture ids must be unique"

append_conformant_override_events
run_sfs event tool_call tool=first-tool outcome=ok latency_ms=1 >/dev/null
run_sfs event tool_call tool=latest-tool outcome=ok latency_ms=2 >/dev/null

# Force the distribution upgrader against the isolated consumer fixture.
sed -i.bak 's/^solon_mvp_version:.*/solon_mvp_version: 0.0.0-product/' .sfs-local/VERSION
rm -f .sfs-local/VERSION.bak
SFS_MODEL_PROFILE_PROMPT=0 \
SFS_SKIP_CLI_DISCOVERY=1 \
SFS_COMMAND_TIMEOUT_SEC=0 \
SFS_UPGRADE_LAYOUT=thin \
bash "${DIST_DIR}/upgrade.sh" --yes --layout thin >/dev/null

assert_capture_id "${approval_id}" "user approval survives upgrade"
assert_capture_id "${note_id}" "later note survives upgrade"
evidence_count="$(grep -c '"type":"evidence_capture"' .sfs-local/events.jsonl || true)"
[[ "${evidence_count}" -eq 2 ]] || fail "active evidence captures must remain non-collapsing, got ${evidence_count}"

tool_call_count="$(grep -c '"type":"tool_call"' .sfs-local/events.jsonl || true)"
[[ "${tool_call_count}" -eq 1 ]] || fail "tool_call compaction must keep one current line, got ${tool_call_count}"
grep -Fq '"tool":"latest-tool"' .sfs-local/events.jsonl \
  || fail "tool_call compaction should retain the latest tool_call event"

run_flowcheck
[[ "${FLOW_RC}" -eq 0 ]] || fail "user-approval scoped override must remain flowcheck-valid after upgrade, got ${FLOW_RC}: ${FLOW_OUT}"
flow_art=".sfs-local/sprints/$(cat .sfs-local/current-sprint)/workbench/flowcheck.md"
grep -Fq 'fcp-model-tier: worker model resolution conformant' "${flow_art}" \
  || fail "flowcheck did not recognize preserved scoped user-approval: $(sed -n '1,120p' "${flow_art}")"

# The accepted compatibility alias must be persisted under the canonical kind
# and independently satisfy flowcheck's scoped-override contract.
: > .sfs-local/events.jsonl
alias_out="$(run_sfs capture --kind approval --scope sprint --gate 3 "Approval alias is canonical user approval.")"
alias_id="$(capture_id_from_output "${alias_out}")"
[[ -n "${alias_id}" ]] || fail "could not parse approval alias capture id: ${alias_out}"
assert_capture_id "${alias_id}" "approval alias capture"
grep -Fq '"kind":"user-approval"' .sfs-local/events.jsonl \
  || fail "approval alias must persist as kind user-approval"
grep -Fq '"kind":"approval"' .sfs-local/events.jsonl \
  && fail "approval alias must not persist legacy kind approval"

append_conformant_override_events
run_flowcheck
[[ "${FLOW_RC}" -eq 0 ]] || fail "canonicalized approval alias must satisfy flowcheck, got ${FLOW_RC}: ${FLOW_OUT}"
grep -Fq 'fcp-model-tier: worker model resolution conformant' "${flow_art}" \
  || fail "flowcheck did not recognize canonicalized approval alias: $(sed -n '1,120p' "${flow_art}")"

echo "test-sfs-upgrade-evidence-ledger-preservation: OK"
