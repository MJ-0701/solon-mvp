#!/usr/bin/env bash
# .sfs-local/scripts/sfs-flowcheck.sh
#
# Solon SFS — `sfs flowcheck [--sprint <id>]` Flow-Conformance Postflight (FCP).
# At work-unit close, assert that SFS executed per its documented default flow by
# reading the non-collapsing flow events (model_resolved / worker_dispatched /
# gate_passed / conflict_surfaced / verification_pair) plus the capture ledger
# (waiver / exception override) from events.jsonl. This is methodology-conformance, NOT product
# acceptance (Gate 6) and NOT a visible-failure triage (debugging-and-error-
# recovery): it catches silent divergence that ran without error.
#
# Enforcement is hybrid. Critical invariant unresolved -> nonzero exit (blocking);
# advisory-only -> warn + exit 0. A `sfs capture --kind waiver` whose text names
# the invariant id (or a bare flowcheck waiver) downgrades that critical to waived.
# Invariant SSoT: policies/flow-conformance-postflight.md.

set -euo pipefail

SFS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sfs-common.sh
source "${SFS_SCRIPT_DIR}/sfs-common.sh"

: "${SFS_EXIT_OK:=0}"
: "${SFS_EXIT_BADCLI:=7}"
SFS_EXIT_NO_SPRINT=1
SFS_EXIT_CRITICAL=8

usage_flowcheck() {
  cat <<'EOF'
Usage:
  sfs flowcheck [--sprint <id>]

Postflight self-check that SFS ran per the documented flow. Reads the current
(or named) sprint's flow events + capture ledger from events.jsonl and asserts
the Flow-Conformance invariant registry.

Critical invariants (blocking unless PASS or a naming waiver):
  fcp-model-tier        implementation/worker model == policy worker tier
                        (source policy|configured ok; current/user-override needs
                        a live-scoped override capture or waiver)  [#4]
  fcp-conflict-surfaced default deviation (user-override) requires a
                        conflict_surfaced event                    [#3]
  fcp-gate-order        gate_passed order_index never regresses
  fcp-stop-the-line     no gate_passed with self_cpo=fail
  fcp-pr-reviewed       ship/done blocked unless an SFS review gate_passed
                        (self_cpo=pass) exists; GitHub PR approval does NOT
                        satisfy this on its own
  fcp-verifier-implementer
                        review close needs verifier != implementer

Advisory invariants (warn, exit 0):
  fcp-self-cpo          every gate_passed self_cpo=pass (partial warns)
  fcp-worker-lane       parallel worker_dispatched declares its lanes

Exit codes: 0 conformant / advisory-only | 1 no sprint | 7 usage
            8 unresolved critical (blocking).
EOF
}

FLOWCHECK_SPRINT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help|help)
      usage_flowcheck
      exit "${SFS_EXIT_OK}"
      ;;
    --sprint)
      [[ $# -ge 2 ]] || { echo "--sprint requires a value" >&2; exit "${SFS_EXIT_BADCLI}"; }
      FLOWCHECK_SPRINT="$2"; shift 2 ;;
    --sprint=*)
      FLOWCHECK_SPRINT="${1#--sprint=}"; shift ;;
    *)
      echo "unknown flag: $1" >&2; exit "${SFS_EXIT_BADCLI}" ;;
  esac
done

[[ -n "${FLOWCHECK_SPRINT}" ]] || FLOWCHECK_SPRINT="$(read_current_sprint 2>/dev/null || true)"
if [[ -z "${FLOWCHECK_SPRINT}" ]]; then
  echo "flowcheck: no current sprint (run inside a sprint or pass --sprint <id>)" >&2
  exit "${SFS_EXIT_NO_SPRINT}"
fi

# ── load this sprint's events into in-memory arrays ────────────────────────
_jf() { sfs_event_json_string_field "$1" "$2"; }

declare -a EV_LINES=()
if [[ -f "${SFS_EVENTS_FILE}" ]]; then
  while IFS= read -r line || [[ -n "${line}" ]]; do
    [[ -n "${line}" ]] || continue
    [[ "$(_jf sprint_id "${line}")" == "${FLOWCHECK_SPRINT}" ]] || continue
    EV_LINES+=("${line}")
  done < "${SFS_EVENTS_FILE}"
fi

# capture ledger signals
has_waiver=0
waiver_text=""
override_scoped=0
for line in "${EV_LINES[@]:-}"; do
  [[ -n "${line}" ]] || continue
  case "$(_jf type "${line}")" in
    evidence_capture)
      k="$(_jf kind "${line}")"
      case "${k}" in
        waiver)
          has_waiver=1
          waiver_text+=" $(_jf text_preview "${line}")"
          ;;
        exception|user-approval)
          # a live-scoped user override is an exception/approval carrying a scope
          [[ -n "$(_jf scope "${line}")" ]] && override_scoped=1
          ;;
      esac
      ;;
  esac
done

# waived_by ID — return 0 if a waiver names this invariant (or is a bare flowcheck waiver)
waived_by() {
  local id="$1"
  [[ "${has_waiver}" -eq 1 ]] || return 1
  case "${waiver_text}" in
    *"${id}"*) return 0 ;;
    *flowcheck*|*"flow-conformance"*|*"flow conformance"*) return 0 ;;
    *) return 1 ;;
  esac
}

declare -a CRIT=()      # blocking findings (text)
declare -a CRIT_WAIVED=()
declare -a ADV=()
declare -a PASS_NOTES=()

is_worker_role() {
  case "$1" in
    *worker*|*implement*|*generator*|*executor*) return 0 ;;
    *) return 1 ;;
  esac
}

is_reviewer_role() {
  case "$1" in
    *cpo*|*evaluator*|*reviewer*) return 0 ;;
    *) return 1 ;;
  esac
}

# review_route_allowlist — the set of model values declared under any
# review_high: block in model-profiles.yaml (one per line). This anchors the
# reviewer-tier invariant to the policy SSoT so a reviewer event cannot launder
# a sub-tier model by simply claiming it as its own route_model (resolved_model
# == route_model == gemini-2.5-pro). It reads declared review model VALUES, not
# the per-runtime resolution LOGIC, so it does not duplicate route selection.
# Empty output (file missing / placeholder-only custom) → caller falls back to
# the event-internal consistency check rather than blocking.
review_route_allowlist() {
  local mp="${SFS_LOCAL_DIR}/model-profiles.yaml"
  [[ -f "${mp}" ]] || return 0
  awk '
    /^[[:space:]]*review_high:[[:space:]]*$/ { inb=1; next }
    inb && /^[[:space:]]*(model|command_or_model):[[:space:]]*/ {
      v=$0
      sub(/^[[:space:]]*(model|command_or_model):[[:space:]]*/, "", v)
      gsub(/["\047]/, "", v)
      sub(/[[:space:]]*$/, "", v)
      if (v != "" && v !~ /^</) print v
      inb=0; next
    }
    inb && /^[[:space:]]*[A-Za-z_]+:/ { inb=0 }
  ' "${mp}"
}

# ── fcp-model-tier (critical) ──────────────────────────────────────────────
mt_ok=1
for line in "${EV_LINES[@]:-}"; do
  [[ "$(_jf type "${line}")" == "model_resolved" ]] || continue
  role="$(_jf agent_role "${line}")"
  src="$(_jf source "${line}")"
  model="$(_jf resolved_model "${line}")"
  is_worker_role "${role}" || continue
  case "${src}" in
    policy|configured) ;;   # authoritative or explicit per-agent override — ok
    user-override)
      if [[ "${override_scoped}" -ne 1 ]]; then
        mt_ok=0
        CRIT+=("fcp-model-tier: worker '${role}' claims source=user-override but no live-scoped override capture (sfs capture --kind exception --scope ...) exists")
      fi
      ;;
    current)
      mt_ok=0
      CRIT+=("fcp-model-tier: worker '${role}' resolved to host current model '${model:-?}' (source=current) — policy worker tier not applied and no scoped user-override [#4]")
      ;;
    *)
      mt_ok=0
      CRIT+=("fcp-model-tier: worker '${role}' has unknown model_resolved.source='${src:-empty}'")
      ;;
  esac
done
[[ "${mt_ok}" -eq 1 ]] && PASS_NOTES+=("fcp-model-tier: worker model resolution conformant")

# ── fcp-reviewer-tier (critical) — solon-product#7 ─────────────────────────
# CPO/cross-review reviewer model is enforced, not a soft target: a reviewer
# model_resolved event must resolve to the model-profiles review route carried
# in the event (route_model), and must not come from the host default
# (source=current). A sub-tier/downgraded reviewer (e.g. Codex quota exhaustion
# silently falling back to gemini-2.5-pro) is a CRIT. The route is asserted from
# the event itself; the invariant does not re-derive it from model-profiles, so
# the runtime that emitted the event remains the single source of the route.
rt_ok=1
rt_seen=0
rt_allowlist="$(review_route_allowlist 2>/dev/null || true)"
for line in "${EV_LINES[@]:-}"; do
  [[ "$(_jf type "${line}")" == "model_resolved" ]] || continue
  role="$(_jf agent_role "${line}")"
  is_reviewer_role "${role}" || continue
  rt_seen=1
  rmodel="$(_jf resolved_model "${line}")"
  route="$(_jf route_model "${line}")"
  rsrc="$(_jf source "${line}")"
  if [[ -z "${route}" ]]; then
    rt_ok=0
    CRIT+=("fcp-reviewer-tier: reviewer '${role}' model_resolved carries no route_model — reviewer tier unenforceable [#7]")
  elif [[ "${rmodel}" != "${route}" ]]; then
    rt_ok=0
    CRIT+=("fcp-reviewer-tier: reviewer '${role}' resolved_model '${rmodel:-?}' != review route '${route}' — sub-tier/downgraded reviewer [#7]")
  elif [[ -n "${rt_allowlist}" ]] && ! grep -Fxq -- "${route}" <<<"${rt_allowlist}"; then
    # route_model agrees with resolved_model but is not a model-profiles
    # review_high route — a laundered sub-tier model (e.g. both = 2.5-pro).
    rt_ok=0
    CRIT+=("fcp-reviewer-tier: reviewer '${role}' route_model '${route}' is not a model-profiles review_high route — laundered/sub-tier reviewer [#7]")
  fi
  case "${rsrc}" in
    current)
      rt_ok=0
      CRIT+=("fcp-reviewer-tier: reviewer '${role}' resolved via source=current (host default) — review route not enforced [#7]")
      ;;
  esac
done
if [[ "${rt_seen}" -eq 1 && "${rt_ok}" -eq 1 ]]; then
  PASS_NOTES+=("fcp-reviewer-tier: reviewer model resolution on enforced review route")
fi

# ── fcp-conflict-surfaced (critical) ───────────────────────────────────────
deviation=0
conflict_count=0
for line in "${EV_LINES[@]:-}"; do
  t="$(_jf type "${line}")"
  case "${t}" in
    model_resolved)
      [[ "$(_jf source "${line}")" == "user-override" ]] && deviation=1 ;;
    conflict_surfaced) conflict_count=$((conflict_count + 1)) ;;
  esac
done
[[ "${override_scoped}" -eq 1 ]] && deviation=1
if [[ "${deviation}" -eq 1 && "${conflict_count}" -eq 0 ]]; then
  CRIT+=("fcp-conflict-surfaced: a default deviation (user-override) occurred with no conflict_surfaced event — silent override [#3]")
else
  PASS_NOTES+=("fcp-conflict-surfaced: deviations (if any) were surfaced")
fi

# ── fcp-gate-order (critical) ──────────────────────────────────────────────
prev_idx=-1
order_ok=1
gate_pass_count=0
review_passed=0
stop_line_ok=1
for line in "${EV_LINES[@]:-}"; do
  [[ "$(_jf type "${line}")" == "gate_passed" ]] || continue
  gate_pass_count=$((gate_pass_count + 1))
  oi="$(_jf order_index "${line}")"
  cpo="$(_jf self_cpo "${line}")"
  case "${oi}" in
    ''|*[!0-9]*) ADV+=("fcp-gate-order: gate_passed has non-numeric order_index '${oi}' (skipped)") ;;
    *)
      if (( oi < prev_idx )); then
        order_ok=0
        CRIT+=("fcp-gate-order: gate_passed order_index ${oi} regressed below ${prev_idx} — out-of-order gate")
      fi
      (( oi > prev_idx )) && prev_idx="${oi}"
      ;;
  esac
  case "${cpo}" in
    pass) review_passed=1 ;;
    partial) ADV+=("fcp-self-cpo: gate_passed (order ${oi:-?}) recorded self_cpo=partial") ;;
    fail)
      stop_line_ok=0
      CRIT+=("fcp-stop-the-line: gate_passed (order ${oi:-?}) recorded self_cpo=fail — a gate cannot pass on a failed self-CPO")
      ;;
  esac
done
[[ "${order_ok}" -eq 1 ]] && PASS_NOTES+=("fcp-gate-order: gate order non-regressing")
[[ "${stop_line_ok}" -eq 1 ]] && PASS_NOTES+=("fcp-stop-the-line: no gate passed on a failed self-CPO")

# ── fcp-pr-reviewed (critical) — the pr-review guard ───────────────────────
if [[ "${review_passed}" -ne 1 ]]; then
  CRIT+=("fcp-pr-reviewed: ship/done blocked — no SFS review gate_passed with self_cpo=pass in this sprint. A GitHub PR approval / @codex review does NOT satisfy this on its own (kernel: GitHub review is separate from SFS review).")
else
  PASS_NOTES+=("fcp-pr-reviewed: an SFS review gate passed (self_cpo=pass)")
fi

# ── fcp-verifier-implementer (critical) ────────────────────────────────────
pair_seen=0
pair_ok=1
for line in "${EV_LINES[@]:-}"; do
  [[ "$(_jf type "${line}")" == "verification_pair" ]] || continue
  pair_seen=1
  implementer="$(_jf implementer "${line}")"
  verifier="$(_jf verifier "${line}")"
  implementer_context="$(_jf implementer_context "${line}")"
  verifier_context="$(_jf verifier_context "${line}")"
  if [[ -z "${implementer}" || -z "${verifier}" ]]; then
    pair_ok=0
    CRIT+=("fcp-verifier-implementer: verification_pair missing implementer or verifier")
  elif [[ "${implementer}" == "${verifier}" ]]; then
    pair_ok=0
    CRIT+=("fcp-verifier-implementer: verifier '${verifier}' equals implementer '${implementer}' — self-verification close is blocked")
  elif [[ -n "${implementer_context}" && "${implementer_context}" == "${verifier_context}" ]]; then
    pair_ok=0
    CRIT+=("fcp-verifier-implementer: verifier_context '${verifier_context}' equals implementer_context — use a separate agent/context")
  fi
done
if [[ "${review_passed}" -eq 1 && "${pair_seen}" -ne 1 ]]; then
  pair_ok=0
  CRIT+=("fcp-verifier-implementer: review gate passed but no verification_pair event proves verifier != implementer")
elif [[ "${review_passed}" -eq 1 && "${pair_ok}" -eq 1 ]]; then
  PASS_NOTES+=("fcp-verifier-implementer: verifier is separated from implementer")
fi

# ── fcp-worker-lane (advisory) ─────────────────────────────────────────────
for line in "${EV_LINES[@]:-}"; do
  [[ "$(_jf type "${line}")" == "worker_dispatched" ]] || continue
  if [[ "$(_jf parallel "${line}")" == "true" && -z "$(_jf lanes "${line}")" ]]; then
    ADV+=("fcp-worker-lane: parallel worker_dispatched did not declare lanes")
  fi
done

# ── apply waivers: move named/blanket-waived criticals out of blocking set ──
declare -a CRIT_BLOCKING=()
for finding in "${CRIT[@]:-}"; do
  [[ -n "${finding}" ]] || continue
  inv_id="${finding%%:*}"
  if waived_by "${inv_id}"; then
    CRIT_WAIVED+=("${finding}")
  else
    CRIT_BLOCKING+=("${finding}")
  fi
done

# ── verdict ────────────────────────────────────────────────────────────────
blocking_n="${#CRIT_BLOCKING[@]}"
waived_n="${#CRIT_WAIVED[@]}"
adv_n="${#ADV[@]}"
if (( blocking_n > 0 )); then
  verdict="FAIL"
elif (( adv_n > 0 || waived_n > 0 )); then
  verdict="WARN"
else
  verdict="PASS"
fi

# ── tool-call telemetry health (ADVISORY, read-only; never gates) ──────────
# Aggregate non-collapsing `tool_call` telemetry events (tool / outcome /
# latency_ms), typically emitted per MCP tool call, into a per-tool health
# summary. This rides the SAME ledger transport as the FCP invariant events but
# is NOT an FCP invariant: it never enters CRIT/ADV/PASS, never changes the
# verdict or exit code. It pinpoints the tool with REPEATED failures (error
# count >= 2) as a drift-warn signal + lessons-accumulation input — the blog
# "per-tool breakdown to pinpoint what fails" pattern, instrumentation-only.
# tool_call is high-volume and bounded only by per-sprint event compaction
# (fine for MVP). Contract SSoT: policies/flow-conformance-postflight.md.
declare -a TC_ROWS=()
for line in "${EV_LINES[@]:-}"; do
  [[ "$(_jf type "${line}")" == "tool_call" ]] || continue
  tc_tool="$(_jf tool "${line}")"
  [[ -n "${tc_tool}" ]] || continue
  TC_ROWS+=("${tc_tool}|$(_jf outcome "${line}")|$(_jf latency_ms "${line}")")
done

declare -a HEALTH_SUMMARY=()
HEALTH_HOTSPOT=""
HEALTH_USAGE=""
HEALTH_EVENT_N="${#TC_ROWS[@]}"
if (( HEALTH_EVENT_N > 0 )); then
  while IFS=$'\t' read -r kind a b c d; do
    case "${kind}" in
      SUMMARY) HEALTH_SUMMARY+=("tool ${a}: ${b} call(s), ${c} error(s), ${d}% error-rate") ;;
      MAXLAT)  HEALTH_SUMMARY+=("tool ${a}: ${b}ms max latency") ;;
      HOTSPOT) HEALTH_HOTSPOT="tool ${a} — ${b} error(s) over ${c} call(s) (${d}% error-rate)" ;;
      USAGE)   HEALTH_USAGE="tool ${a} — ${b} successful call(s) over ${c} total" ;;
    esac
  done < <(printf '%s\n' "${TC_ROWS[@]}" | awk -F'|' '
    { t=$1; calls[t]++; if ($2=="error") err[t]++;
      lat=$3+0; if (lat>maxlat[t]) maxlat[t]=lat; seen[t]=1 }
    END {
      n=0; for (t in seen) tools[++n]=t
      for (i=1;i<=n;i++) for (j=i+1;j<=n;j++) if (tools[j]<tools[i]) {x=tools[i];tools[i]=tools[j];tools[j]=x}
      for (i=1;i<=n;i++) { t=tools[i]; c=calls[t]+0; e=err[t]+0; r=(c>0)?(e*100/c):0;
        printf "SUMMARY\t%s\t%d\t%d\t%.0f\n", t, c, e, r;
        printf "MAXLAT\t%s\t%d\n", t, maxlat[t]+0 }
      # repeated-failure hotspot: err>=2 only; rank err desc, then rate desc, then name asc
      best=""; bE=-1; bR=-1
      for (i=1;i<=n;i++) { t=tools[i]; c=calls[t]+0; e=err[t]+0; r=(c>0)?(e*100/c):0;
        if (e<2) continue;
        if (e>bE || (e==bE && r>bR)) { best=t; bE=e; bR=r; bC=c } }
      if (best!="") printf "HOTSPOT\t%s\t%d\t%d\t%.0f\n", best, bE, bC, bR
      # usage-value signal (success twin of the hotspot): non-error calls >= 3;
      # rank success desc, then name asc. Repeated real use = field-tested value.
      bestU=""; bU=-1
      for (i=1;i<=n;i++) { t=tools[i]; c=calls[t]+0; e=err[t]+0; s=c-e;
        if (s<3) continue;
        if (s>bU) { bestU=t; bU=s; bUC=c } }
      if (bestU!="") printf "USAGE\t%s\t%d\t%d\n", bestU, bU, bUC
    }')
fi

# ── write verdict artifact ─────────────────────────────────────────────────
SPRINT_DIR="${SFS_SPRINTS_DIR}/${FLOWCHECK_SPRINT}"
ART_DIR="${SPRINT_DIR}/workbench"
ART="${ART_DIR}/flowcheck.md"
ts_now="$(date +%Y-%m-%dT%H:%M:%S%z 2>/dev/null | sed -E 's/([0-9]{2})$/:\1/')"
if mkdir -p "${ART_DIR}" 2>/dev/null; then
  {
    printf '# Flow-Conformance Postflight — %s\n\n' "${FLOWCHECK_SPRINT}"
    printf -- '- verdict: **%s** (%s critical-blocking, %s waived, %s advisory)\n' \
      "${verdict}" "${blocking_n}" "${waived_n}" "${adv_n}"
    printf -- '- checked: %s\n\n' "${ts_now}"
    if (( blocking_n > 0 )); then
      printf '## Critical — blocking\n'
      for f in "${CRIT_BLOCKING[@]}"; do printf -- '- ❌ %s\n' "${f}"; done
      printf '\n'
    fi
    if (( waived_n > 0 )); then
      printf '## Critical — waived\n'
      for f in "${CRIT_WAIVED[@]}"; do printf -- '- ⚠️ (waived) %s\n' "${f}"; done
      printf '\n'
    fi
    if (( adv_n > 0 )); then
      printf '## Advisory\n'
      for f in "${ADV[@]}"; do printf -- '- ⚠️ %s\n' "${f}"; done
      printf '\n'
    fi
    if (( ${#PASS_NOTES[@]} > 0 )); then
      printf '## Conformant\n'
      for f in "${PASS_NOTES[@]}"; do printf -- '- ✅ %s\n' "${f}"; done
      printf '\n'
    fi
    if (( HEALTH_EVENT_N > 0 )); then
      printf '## Tool telemetry health (advisory, non-gating)\n'
      printf -- '- %s tool_call event(s) aggregated read-only; does not affect the verdict.\n' "${HEALTH_EVENT_N}"
      for f in "${HEALTH_SUMMARY[@]:-}"; do [[ -n "${f}" ]] && printf -- '- %s\n' "${f}"; done
      if [[ -n "${HEALTH_HOTSPOT}" ]]; then
        printf -- '- ⚠️ repeated-failure hotspot: %s — drift-warn signal; record as a lesson if recurring.\n' "${HEALTH_HOTSPOT}"
      fi
      if [[ -n "${HEALTH_USAGE}" ]]; then
        printf -- '- usage-value signal: %s — repeated use is field-tested value; skill-promotion input (advisory).\n' "${HEALTH_USAGE}"
      fi
      printf '\n'
    fi
    if (( blocking_n > 0 )); then
      printf '> Blocking: resolve the findings, or record `sfs capture --kind waiver "<invariant-id>: reason"` to proceed.\n'
    fi
  } > "${ART}" 2>/dev/null || true
fi

# ── emit flow_conformance event (non-collapsing) ───────────────────────────
append_flow_event flow_conformance \
  "verdict=${verdict}" "critical_blocking=${blocking_n}" \
  "waived=${waived_n}" "advisory=${adv_n}" 2>/dev/null || true

# ── report to stdout ───────────────────────────────────────────────────────
echo "flowcheck: ${FLOWCHECK_SPRINT} — ${verdict} (critical-blocking=${blocking_n}, waived=${waived_n}, advisory=${adv_n})"
for f in "${CRIT_BLOCKING[@]:-}"; do [[ -n "${f}" ]] && echo "  CRITICAL: ${f}"; done
for f in "${CRIT_WAIVED[@]:-}"; do [[ -n "${f}" ]] && echo "  waived:   ${f}"; done
for f in "${ADV[@]:-}"; do [[ -n "${f}" ]] && echo "  advisory: ${f}"; done
[[ -f "${ART}" ]] && echo "  verdict artifact: ${ART}"

# ── tool telemetry health (advisory; never changes verdict or exit code) ────
if (( HEALTH_EVENT_N > 0 )); then
  echo "  telemetry: ${HEALTH_EVENT_N} tool_call event(s) aggregated read-only (non-gating)"
  if [[ -n "${HEALTH_HOTSPOT}" ]]; then
    echo "  telemetry: repeated-failure hotspot: ${HEALTH_HOTSPOT}"
  fi
  if [[ -n "${HEALTH_USAGE}" ]]; then
    echo "  telemetry: usage-value signal: ${HEALTH_USAGE}"
  fi
fi

# ── lessons loop (advisory; never changes verdict or exit code) ─────────────
# Surface the accumulated avoidance-rule ledger and the record obligation so a
# failure caught this work unit becomes a durable lesson. See
# policies/lessons-accumulation.md.
_lessons_file="${SFS_LOCAL_DIR}/lessons.md"
if [[ -f "${_lessons_file}" ]]; then
  _lessons_n="$(grep -cE '^## L-[0-9]' "${_lessons_file}" 2>/dev/null || printf '0')"
else
  _lessons_n=0
fi
case "${_lessons_n}" in ''|*[!0-9]*) _lessons_n=0 ;; esac
echo "  lessons: consult ${_lessons_file} (${_lessons_n} recorded); record any failure caught this work unit as a lesson"

if (( blocking_n > 0 )); then
  echo "flowcheck: BLOCKING — work unit cannot close until critical invariants PASS or are waived." >&2
  exit "${SFS_EXIT_CRITICAL}"
fi
exit "${SFS_EXIT_OK}"
