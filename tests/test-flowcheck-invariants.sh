#!/usr/bin/env bash
# Invariant test for `sfs flowcheck` (Flow-Conformance Postflight, 0.8.0).
#
# Injects synthetic flow events into a sprint's events.jsonl and asserts the
# verdict + exit code for each class: conformant PASS, advisory WARN, critical
# FAIL (blocking), waiver downgrade, and the #3 silent-override case. This is
# the proof that FCP actually classifies divergence — every other surface
# (MCP tool, routing, lens alias) is wiring around this engine.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"

fail() { echo "FAIL: $*" >&2; exit 1; }

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-flowcheck.XXXXXX")"
cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

cd "${TMP_DIR}"
git init -q
git config user.email "flowcheck@solon.invalid"
git config user.name "Solon Flowcheck Test"
printf '# flowcheck\n' > README.md
git add . && git commit -qm "init"
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1

SPRINT="2026-W22-sprint-1"
mkdir -p ".sfs-local/sprints/${SPRINT}"
printf '%s\n' "${SPRINT}" > ".sfs-local/current-sprint"
EVENTS=".sfs-local/events.jsonl"

# emit <type> <field=value...> — write one synthetic event line for this sprint.
emit() {
  local t="$1"; shift
  local body=""
  for kv in "$@"; do body+=",\"${kv%%=*}\":\"${kv#*=}\""; done
  printf '{"ts":"2026-05-22T10:00:00+09:00","type":"%s","sprint_id":"%s"%s}\n' \
    "${t}" "${SPRINT}" "${body}" >> "${EVENTS}"
}
reset_events() { : > "${EVENTS}"; }

run_flowcheck() {
  set +e
  FLOW_OUT="$(SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" flowcheck 2>&1)"
  FLOW_RC=$?
  set -e
}

# ── 1) conformant → PASS, exit 0 ───────────────────────────────────────────
reset_events
emit model_resolved agent_role=implementation-worker resolved_tier=execution_standard resolved_model=sonnet-4.6 source=policy
emit worker_dispatched role=implementation-worker model=sonnet-4.6 parallel=false
emit gate_passed gate=G3 order_index=1 self_cpo=pass
emit gate_passed gate=G5 order_index=2 self_cpo=pass
run_flowcheck
[[ "${FLOW_RC}" -eq 0 ]] || fail "conformant case should exit 0, got ${FLOW_RC}: ${FLOW_OUT}"
grep -q -- "PASS" <<<"${FLOW_OUT}" || fail "conformant case should report PASS: ${FLOW_OUT}"

# ── 2) advisory only (self_cpo=partial) → WARN, exit 0 ─────────────────────
reset_events
emit model_resolved agent_role=implementation-worker resolved_tier=execution_standard resolved_model=sonnet-4.6 source=policy
emit gate_passed gate=G3 order_index=1 self_cpo=pass
emit gate_passed gate=G5 order_index=2 self_cpo=partial
run_flowcheck
[[ "${FLOW_RC}" -eq 0 ]] || fail "advisory case should exit 0, got ${FLOW_RC}: ${FLOW_OUT}"
grep -q -- "WARN" <<<"${FLOW_OUT}" || fail "advisory case should report WARN: ${FLOW_OUT}"
grep -q "fcp-self-cpo" <<<"${FLOW_OUT}" || fail "advisory case should name fcp-self-cpo: ${FLOW_OUT}"

# ── 3) critical: worker resolved to host current model (#4) → FAIL, exit 8 ─
reset_events
emit model_resolved agent_role=implementation-worker resolved_tier=execution_high resolved_model=opus-4.7 source=current
emit gate_passed gate=G5 order_index=1 self_cpo=pass
run_flowcheck
[[ "${FLOW_RC}" -eq 8 ]] || fail "model-tier violation should exit 8 (blocking), got ${FLOW_RC}: ${FLOW_OUT}"
grep -q "fcp-model-tier" <<<"${FLOW_OUT}" || fail "should name fcp-model-tier: ${FLOW_OUT}"

# ── 4) waiver naming the invariant downgrades the critical → exit 0 ────────
reset_events
emit model_resolved agent_role=implementation-worker resolved_tier=execution_high resolved_model=opus-4.7 source=current
emit gate_passed gate=G5 order_index=1 self_cpo=pass
emit evidence_capture kind=waiver text_preview="fcp-model-tier: opus run authorized for this hotfix"
run_flowcheck
[[ "${FLOW_RC}" -eq 0 ]] || fail "named waiver should downgrade to exit 0, got ${FLOW_RC}: ${FLOW_OUT}"
grep -q "waived" <<<"${FLOW_OUT}" || fail "waiver case should report waived: ${FLOW_OUT}"

# ── 5) #3: user-override deviation with no conflict_surfaced → FAIL ─────────
reset_events
emit model_resolved agent_role=implementation-worker resolved_tier=execution_high resolved_model=opus-4.7 source=user-override
emit evidence_capture kind=exception scope=sprint text_preview="run top model directly this sprint"
emit gate_passed gate=G5 order_index=1 self_cpo=pass
run_flowcheck
[[ "${FLOW_RC}" -eq 8 ]] || fail "unsurfaced override should exit 8, got ${FLOW_RC}: ${FLOW_OUT}"
grep -q "fcp-conflict-surfaced" <<<"${FLOW_OUT}" || fail "should name fcp-conflict-surfaced: ${FLOW_OUT}"

# ── 6) #3 resolved: same deviation WITH conflict_surfaced + scoped capture → exit 0
reset_events
emit model_resolved agent_role=implementation-worker resolved_tier=execution_high resolved_model=opus-4.7 source=user-override
emit conflict_surfaced kind=model-tier detail="user asked top model directly" resolved_by=user
emit evidence_capture kind=exception scope=sprint text_preview="run top model directly this sprint"
emit gate_passed gate=G5 order_index=1 self_cpo=pass
run_flowcheck
[[ "${FLOW_RC}" -eq 0 ]] || fail "surfaced+scoped override should exit 0, got ${FLOW_RC}: ${FLOW_OUT}"

# ── 7) pr-review guard: no review gate passed → FAIL ───────────────────────
reset_events
emit model_resolved agent_role=implementation-worker resolved_tier=execution_standard resolved_model=sonnet-4.6 source=policy
run_flowcheck
[[ "${FLOW_RC}" -eq 8 ]] || fail "no review gate should exit 8, got ${FLOW_RC}: ${FLOW_OUT}"
grep -q "fcp-pr-reviewed" <<<"${FLOW_OUT}" || fail "should name fcp-pr-reviewed: ${FLOW_OUT}"

# ── 8) gate order regression → FAIL ────────────────────────────────────────
reset_events
emit model_resolved agent_role=implementation-worker resolved_tier=execution_standard resolved_model=sonnet-4.6 source=policy
emit gate_passed gate=G5 order_index=2 self_cpo=pass
emit gate_passed gate=G3 order_index=1 self_cpo=pass
run_flowcheck
[[ "${FLOW_RC}" -eq 8 ]] || fail "gate order regression should exit 8, got ${FLOW_RC}: ${FLOW_OUT}"
grep -q "fcp-gate-order" <<<"${FLOW_OUT}" || fail "should name fcp-gate-order: ${FLOW_OUT}"

# ── 9) verdict artifact written ────────────────────────────────────────────
[[ -f ".sfs-local/sprints/${SPRINT}/workbench/flowcheck.md" ]] \
  || fail "flowcheck should write verdict artifact"

echo "PASS: test-flowcheck-invariants.sh"
