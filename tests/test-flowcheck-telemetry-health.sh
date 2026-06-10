#!/usr/bin/env bash
# Headline test for WU-1 — per-tool telemetry health in `sfs flowcheck`.
#
# Proves two things the AC requires:
#   1. flowcheck aggregates synthetic `tool_call` events read-only and pinpoints
#      the REPEATED-failure hotspot. The metric is error COUNT (>=2 floor), NOT
#      error rate: a 1/1 (100%) one-off must NOT outrank a 3/4 (75%) repeated
#      failure. This case discriminates — a wrong (rate-based) metric fails it.
#   2. Telemetry is non-destructive (기존 동작 비파괴): tool_call events never
#      change the verdict or exit code in EITHER direction — a conformant set
#      stays PASS/exit 0, a critical-FAIL set stays exit 8.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"

fail() { echo "FAIL: $*" >&2; exit 1; }

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-telemetry.XXXXXX")"
cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

cd "${TMP_DIR}"
git init -q
git config user.email "telemetry@solon.invalid"
git config user.name "Solon Telemetry Test"
printf '# telemetry\n' > README.md
git add . && git commit -qm "init"
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1

SPRINT="2026-W24-sprint-1"
mkdir -p ".sfs-local/sprints/${SPRINT}"
printf '%s\n' "${SPRINT}" > ".sfs-local/current-sprint"
EVENTS=".sfs-local/events.jsonl"

emit() {
  local t="$1"; shift
  local body=""
  for kv in "$@"; do body+=",\"${kv%%=*}\":\"${kv#*=}\""; done
  printf '{"ts":"2026-06-10T10:00:00+09:00","type":"%s","sprint_id":"%s"%s}\n' \
    "${t}" "${SPRINT}" "${body}" >> "${EVENTS}"
}
reset_events() { : > "${EVENTS}"; }

run_flowcheck() {
  set +e
  FLOW_OUT="$(SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" flowcheck 2>&1)"
  FLOW_RC=$?
  set -e
}

# fixed telemetry fixture: status clean, review repeated-failure, plan one-off 100%
emit_telemetry() {
  emit tool_call tool=sfs_status outcome=ok latency_ms=40
  emit tool_call tool=sfs_status outcome=ok latency_ms=55
  emit tool_call tool=sfs_status outcome=ok latency_ms=48
  emit tool_call tool=sfs_review outcome=error latency_ms=900
  emit tool_call tool=sfs_review outcome=error latency_ms=120
  emit tool_call tool=sfs_review outcome=error latency_ms=300
  emit tool_call tool=sfs_review outcome=ok    latency_ms=110
  emit tool_call tool=sfs_plan   outcome=error latency_ms=70
}

# ── 1) conformant FCP base + telemetry → PASS, exit 0, hotspot = review ─────
reset_events
emit model_resolved agent_role=implementation-worker resolved_tier=execution_standard resolved_model=sonnet-4.6 source=policy
emit gate_passed gate=G3 order_index=1 self_cpo=pass
emit gate_passed gate=G5 order_index=2 self_cpo=pass
emit verification_pair implementer=implementation-worker verifier=cpo-evaluator implementer_context=worker-1 verifier_context=review-1 gate=G5
emit_telemetry
run_flowcheck

[[ "${FLOW_RC}" -eq 0 ]] || fail "telemetry must not change a conformant verdict (want exit 0, got ${FLOW_RC}): ${FLOW_OUT}"
grep -q -- "PASS" <<<"${FLOW_OUT}" || fail "conformant+telemetry should still report PASS: ${FLOW_OUT}"
grep -q "8 tool_call event(s)" <<<"${FLOW_OUT}" || fail "should report aggregated tool_call count: ${FLOW_OUT}"
grep -q "repeated-failure hotspot: tool sfs_review" <<<"${FLOW_OUT}" \
  || fail "hotspot should be sfs_review (3 errors, repeated): ${FLOW_OUT}"
grep -q "hotspot: tool sfs_plan" <<<"${FLOW_OUT}" \
  && fail "sfs_plan (1/1 one-off, 100% rate) must NOT be the hotspot — metric is repeated error count, not rate: ${FLOW_OUT}"

# hotspot must be reported in the verdict artifact too
ART=".sfs-local/sprints/${SPRINT}/workbench/flowcheck.md"
[[ -f "${ART}" ]] || fail "flowcheck artifact missing"
grep -q "Tool telemetry health" "${ART}" || fail "artifact missing Tool telemetry health section: $(cat "${ART}")"
grep -q "repeated-failure hotspot: tool sfs_review" "${ART}" || fail "artifact missing hotspot: $(cat "${ART}")"

# ── 2) non-destructive on FAIL: critical-FAIL base + telemetry → still exit 8 ─
reset_events
emit model_resolved agent_role=implementation-worker resolved_tier=execution_standard resolved_model=sonnet-4.6 source=policy
# no review gate_passed → fcp-pr-reviewed CRIT (blocking)
emit_telemetry
run_flowcheck

[[ "${FLOW_RC}" -eq 8 ]] || fail "telemetry must not rescue a critical FAIL (want exit 8, got ${FLOW_RC}): ${FLOW_OUT}"
grep -q "fcp-pr-reviewed" <<<"${FLOW_OUT}" || fail "FAIL case should still name fcp-pr-reviewed: ${FLOW_OUT}"
grep -q "repeated-failure hotspot: tool sfs_review" <<<"${FLOW_OUT}" \
  || fail "telemetry should still be aggregated even on a FAIL verdict: ${FLOW_OUT}"

# ── 3) no telemetry → no health section, verdict unchanged ──────────────────
reset_events
emit model_resolved agent_role=implementation-worker resolved_tier=execution_standard resolved_model=sonnet-4.6 source=policy
emit gate_passed gate=G5 order_index=1 self_cpo=pass
emit verification_pair implementer=implementation-worker verifier=cpo-evaluator implementer_context=worker-1 verifier_context=review-1 gate=G5
run_flowcheck

[[ "${FLOW_RC}" -eq 0 ]] || fail "no-telemetry conformant case should exit 0, got ${FLOW_RC}: ${FLOW_OUT}"
grep -q "tool_call event(s) aggregated" <<<"${FLOW_OUT}" \
  && fail "no tool_call events should produce no telemetry line: ${FLOW_OUT}"

echo "test-flowcheck-telemetry-health: OK"
