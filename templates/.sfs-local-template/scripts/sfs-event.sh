#!/usr/bin/env bash
# .sfs-local/scripts/sfs-event.sh
#
# Solon SFS — `sfs event <type> [key=value ...]`.
# Agent-facing emit of one non-collapsing Flow-Conformance Postflight (FCP)
# event to events.jsonl. Bounded to the FCP contract types plus the advisory
# `tool_call` telemetry type; `sfs flowcheck` asserts invariants over the FCP
# events and aggregates `tool_call` read-only into a tool-health summary (never
# a gate). An event is structured evidence, never a substitute for a review
# verdict.

set -euo pipefail

SFS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sfs-common.sh
source "${SFS_SCRIPT_DIR}/sfs-common.sh"

: "${SFS_EXIT_OK:=0}"
: "${SFS_EXIT_BADCLI:=7}"
SFS_EXIT_PERM=5

usage_event() {
  cat <<'EOF'
Usage:
  sfs event <type> [key=value ...]

Emit one non-collapsing Flow-Conformance event to events.jsonl. The active
sprint_id is stamped automatically. Bounded contract types:

  model_resolved     agent_role=.. resolved_tier=.. resolved_model=.. \
                     source=policy|configured|current|user-override [profiles_version=..]
                     # reviewer roles (cpo-evaluator/*reviewer*) also carry
                     # route_model=.. for fcp-reviewer-tier enforcement (#7);
                     # resolved_model must equal route_model or flowcheck CRITs.
  worker_dispatched  role=.. model=.. parallel=true|false [lanes=..]
  gate_passed        gate=.. order_index=.. self_cpo=pass|partial|fail
  conflict_surfaced  kind=.. detail=.. resolved_by=user|capture [scope=wu|sprint|until-revoked]
  verification_pair  implementer=.. verifier=.. [implementer_context=.. verifier_context=.. gate=..]
  tool_call          tool=.. outcome=ok|error latency_ms=..
                     # ADVISORY telemetry, NOT an FCP invariant. Rides the same
                     # non-collapsing ledger transport but never gates: flowcheck
                     # aggregates it read-only into a tool-health summary that
                     # pinpoints repeated-failure / slow tools (drift-warn +
                     # lessons input). Typically emitted per MCP tool call.

Exit codes: 0 ok | 5 permission denied | 7 usage.
EOF
}

case "${1:-}" in
  -h|--help|help|"")
    usage_event
    exit "${SFS_EXIT_OK}"
    ;;
esac

EVENT_TYPE="$1"
shift

case "${EVENT_TYPE}" in
  model_resolved|worker_dispatched|gate_passed|conflict_surfaced|verification_pair|tool_call) ;;
  *)
    echo "unknown event type: ${EVENT_TYPE} (allowed: model_resolved worker_dispatched gate_passed conflict_surfaced verification_pair tool_call)" >&2
    usage_event >&2
    exit "${SFS_EXIT_BADCLI}"
    ;;
esac

for kv in "$@"; do
  case "${kv}" in
    *=*) ;;
    *)
      echo "event fields must be key=value: ${kv}" >&2
      exit "${SFS_EXIT_BADCLI}"
      ;;
  esac
done

if ! append_flow_event "${EVENT_TYPE}" "$@"; then
  echo "permission denied appending event to ${SFS_EVENTS_FILE}" >&2
  exit "${SFS_EXIT_PERM}"
fi

echo "event recorded: ${EVENT_TYPE} | sprint $(read_current_sprint 2>/dev/null || echo '-') | ${SFS_EVENTS_FILE}"
