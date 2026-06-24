#!/usr/bin/env bash
# .sfs-local/scripts/sfs-orchestrator.sh
#
# Solon SFS — external self-improvement orchestrator (Hermes seam) resolver.
# Read-only, data-driven. The OCP companion to sfs-team.sh at the orchestrator
# layer: where sfs-team.sh abstracts worker CLIs via runtime_registry, this one
# abstracts an external standing orchestrator (Hermes-class) via the
# external_orchestrator section of model-profiles.yaml.
#
# The resolve-* / show / queue-path surface is pure read-only data lookup. The
# write verbs (`ingest` Seam A, `export` + `import-review` Seam B) touch ONLY the
# orchestrator's own artifacts (signal queue, outbox export, review log) — never
# the loop's authoritative state (no avoidance-rule store, no evolution delta
# record, no graduated-artifact file), so from the loop's authority they stay
# suggest-only. So even though the schema scalar reads `scope: read-only`, that
# refers to loop state: the seam's own staging files are bounded write.
#
# - `ingest` (Seam A, P2): validate a typed SIGNAL capsule and append one typed
#   entry to .sfs-local/orchestrator/signal-queue.md (curation reads it read-only).
# - `export` (Seam B, P3): emit a typed POINTER-ONLY proposal export to the
#   review_outbox (file-drop transport). Outbound carries id + pointer + metadata
#   only — a candidate's raw body is never copied out.
# - `import-review` (Seam B, P3): validate + sanitize a typed human review and
#   append one entry to .sfs-local/orchestrator/review-log.md. It CANNOT trigger an
#   apply, a remote write, a branch integration, or owner approval — the review log
#   is advisory; APPLY stays the tidy rail + human gate.
#
# Every write verb is gated on enabled: a disabled/absent seam refuses and writes
# nothing (standalone). The script spawns nothing. The standalone, suggest-only,
# and inviolable-gate invariants are declared once in
# policies/self-improvement-loop.md + policies/external-orchestrator-entry.md;
# this script only applies them.
#
# Default off: enabled resolves true only when the scalar is exactly `true`.
# A missing section / missing file / disabled flag all resolve to "false" with
# exit 0 — so removing the seam degrades cleanly to standalone (never a crash).
#
# Subcommands:
#   resolve-enabled            true only if external_orchestrator.enabled == true,
#                              else false (absent section/file -> false).
#   resolve-adapter            external_orchestrator.adapter (empty if absent).
#   resolve-transport          external_orchestrator.transport_kind
#                              (api|webhook|cli|file-drop; file-drop if absent/unknown).
#   resolve-inbox              external_orchestrator.signal_inbox path (empty if absent).
#   resolve-outbox             external_orchestrator.review_outbox path (empty if absent).
#   show                       summarize enabled / adapter / transport / inbox / outbox.
#   queue-path                 print the signal-queue path (read-only).
#   ingest --file <capsule>    (Seam A) validate a typed SIGNAL capsule and append
#                              one typed entry to the signal queue. Gated on enabled.
#   export --from <candidates> (Seam B) emit a pointer-only proposal export to the
#                              review_outbox. Gated on enabled.
#   import-review --file <rev> (Seam B) validate+sanitize a typed review and append
#                              one entry to the review log. Gated on enabled.
#
# SIGNAL capsule schema (design SSoT §4, 5 typed fields): source, kind
# (completed-work|detection|hotspot), evidence_pointer (a pointer, not raw
# content), confidence (numeric), ts. This is the typed-handoff *discipline* the
# 8-field sub-agent-capsule-contract codifies, applied to the SIGNAL artifact's
# own fields — a detection/hotspot signal has no acceptance_criteria/token_budget.
#
# Review schema (Seam B): candidate_id, decision (approve|defer|reject), comment,
# reviewer, ts. The comment is sanitized (pipe-delimiter + control chars stripped,
# length-capped) so a review can never forge a structured field or extra log line.
#
# Exit codes: 0 ok, 3 disabled (no-op, standalone), 5 schema-reject, 7 usage.

set -euo pipefail

SFS_LOCAL_DIR="${SFS_LOCAL_DIR:-.sfs-local}"
MP="${SFS_MODEL_PROFILES:-${SFS_LOCAL_DIR}/model-profiles.yaml}"
SFS_EXIT_USAGE=7
SFS_EXIT_DISABLED=3
SFS_EXIT_SCHEMA=5
ORCH_DIR="${SFS_LOCAL_DIR}/orchestrator"
SIGNAL_QUEUE="${ORCH_DIR}/signal-queue.md"
REVIEW_LOG="${ORCH_DIR}/review-log.md"
EVIDENCE_POINTER_MAXLEN=512   # longer than this = inlined content, not a pointer
COMMENT_MAXLEN=280            # review comment cap

# Whitelisted fields an outbound proposal may carry (pointer-only: NO body/raw).
EXPORT_FIELDS="id kind evidence_pointer title"

usage() {
  cat <<'EOF'
Usage:
  sfs orchestrator resolve-enabled     external_orchestrator.enabled == true ? true : false
  sfs orchestrator resolve-adapter     external_orchestrator.adapter (empty if absent)
  sfs orchestrator resolve-transport   transport_kind (api|webhook|cli|file-drop; file-drop default)
  sfs orchestrator resolve-inbox       signal_inbox path (empty if absent)
  sfs orchestrator resolve-outbox      review_outbox path (empty if absent)
  sfs orchestrator show                summarize the external_orchestrator surface
  sfs orchestrator queue-path          print the signal-queue path (read-only)
  sfs orchestrator ingest --file <f>   (Seam A) validate a typed SIGNAL capsule and
                                       append one typed entry to the signal queue
  sfs orchestrator export --from <f>   (Seam B) emit a pointer-only proposal export
                                       to the review_outbox (file-drop transport)
  sfs orchestrator import-review --file <f>
                                       (Seam B) validate+sanitize a typed review and
                                       append one entry to the review log

resolve-* / show / queue-path are pure read-only data lookup over
.sfs-local/model-profiles.yaml (external_orchestrator block). The write verbs
(ingest / export / import-review) touch only the orchestrator's own artifacts —
never the loop's authoritative state (suggest-only) — and each refuses when the
seam is disabled or absent (standalone). import-review's effect is confined to the
advisory review log; APPLY stays the tidy rail + human gate, untriggerable here.
Default off: a missing section, missing file, or enabled != true resolve to disabled.
EOF
}

# enabled-gate shared by every write verb (standalone guarantee).
require_enabled() {
  if [[ "$(read_field enabled)" != "true" ]]; then
    echo "$1: seam disabled (external_orchestrator.enabled != true) — no-op" >&2
    exit "${SFS_EXIT_DISABLED}"
  fi
}

# strip the field delimiter (|) and control chars, collapse whitespace, cap length.
# Keeps a free-text value confined to one safe field of one log line.
sanitize_text() {
  local s="$1" max="$2"
  s="${s//|/ }"                              # neutralize the field delimiter
  s="$(printf '%s' "${s}" | tr -d '\000-\037\177' | tr -s ' ')"
  s="${s# }"; s="${s% }"
  (( ${#s} > max )) && s="${s:0:max}"
  printf '%s' "${s}"
}

# read one `| key=value` field from a `- candidate | ...` pipe-delimited line.
line_field() {
  local key="$1" line="$2"
  printf '%s\n' "${line}" | awk -v k="${key}" '
    { n=split($0, parts, /[[:space:]]*\|[[:space:]]*/)
      for (i=1;i<=n;i++) { if (index(parts[i], k"=")==1) { print substr(parts[i], length(k)+2); exit } } }'
}

# external_orchestrator.<key> — block-scoped flat scalar read (first match).
# Block scoping is required: transport_kind also appears under
# runtime_registry.<rt>, so an unscoped read would cross-contaminate.
read_field() {
  local key="$1"
  [[ -f "${MP}" ]] || return 0
  awk -v want="${key}" '
    /^external_orchestrator:/ { inb=1; next }
    inb && /^[A-Za-z_]/ { inb=0 }
    inb && $0 ~ "^[[:space:]]+"want":" {
      v=$0
      sub("^[[:space:]]+"want":[[:space:]]*", "", v)
      sub(/[[:space:]]*#.*/, "", v)
      gsub(/["\047]/, "", v)
      sub(/[[:space:]]*$/, "", v)
      print v; exit
    }
  ' "${MP}"
}

# capsule.<key> — flat scalar read of a dropped SIGNAL capsule (first match).
# The SIGNAL capsule is a flat key: value file (typed 8-field-discipline applied
# to the design §4 SIGNAL fields), so a single block-agnostic reader is correct.
capsule_field() {
  local key="$1" file="$2"
  [[ -f "${file}" ]] || return 0
  awk -v want="${key}" '
    $0 ~ "^"want":" {
      v=$0; sub("^"want":[[:space:]]*","",v)
      sub(/[[:space:]]*$/,"",v); gsub(/^["\047]|["\047]$/,"",v)
      print v; exit
    }
  ' "${file}"
}

# validate the 5 typed SIGNAL fields; echo a reason + return 1 on the first miss.
validate_signal() {
  local file="$1" source kind ptr conf ts
  source="$(capsule_field source "${file}")"
  kind="$(capsule_field kind "${file}")"
  ptr="$(capsule_field evidence_pointer "${file}")"
  conf="$(capsule_field confidence "${file}")"
  ts="$(capsule_field ts "${file}")"
  [[ -n "${source}" ]] || { echo "missing required field: source"; return 1; }
  case "${kind}" in
    completed-work|detection|hotspot) ;;
    "") echo "missing required field: kind"; return 1 ;;
    *)  echo "invalid kind '${kind}' (expected completed-work|detection|hotspot)"; return 1 ;;
  esac
  [[ -n "${ptr}" ]] || { echo "missing required field: evidence_pointer"; return 1; }
  if (( ${#ptr} > EVIDENCE_POINTER_MAXLEN )); then
    echo "evidence_pointer too long (${#ptr} > ${EVIDENCE_POINTER_MAXLEN}) — looks like inlined content, not a pointer"
    return 1
  fi
  [[ "${conf}" =~ ^[0-9]*\.?[0-9]+$ ]] || { echo "confidence must be numeric (got '${conf}')"; return 1; }
  [[ -n "${ts}" ]] || { echo "missing required field: ts"; return 1; }
  return 0
}

cmd="${1:-}"
case "${cmd}" in
  resolve-enabled)
    v="$(read_field enabled)"
    if [[ "${v}" == "true" ]]; then printf 'true\n'; else printf 'false\n'; fi
    ;;
  resolve-adapter)
    printf '%s\n' "$(read_field adapter)"
    ;;
  resolve-transport)
    v="$(read_field transport_kind)"
    case "${v}" in
      api|webhook|cli|file-drop) printf '%s\n' "${v}" ;;
      *) printf 'file-drop\n' ;;
    esac
    ;;
  resolve-inbox)
    printf '%s\n' "$(read_field signal_inbox)"
    ;;
  resolve-outbox)
    printf '%s\n' "$(read_field review_outbox)"
    ;;
  show)
    en="$(read_field enabled)"; [[ "${en}" == "true" ]] || en="false"
    tr="$(read_field transport_kind)"
    case "${tr}" in api|webhook|cli|file-drop) : ;; *) tr="file-drop" ;; esac
    printf 'enabled: %s\n' "${en}"
    printf 'adapter: %s\n' "$(read_field adapter)"
    printf 'transport_kind: %s\n' "${tr}"
    printf 'signal_inbox: %s\n' "$(read_field signal_inbox)"
    printf 'review_outbox: %s\n' "$(read_field review_outbox)"
    ;;
  queue-path)
    printf '%s\n' "${SIGNAL_QUEUE}"
    ;;
  ingest)
    shift
    capsule=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --file) shift; capsule="${1:-}" ;;
        --file=*) capsule="${1#--file=}" ;;
        *) echo "ingest: unknown arg: $1" >&2; usage >&2; exit "${SFS_EXIT_USAGE}" ;;
      esac
      shift || true
    done
    [[ -n "${capsule}" ]] || { echo "ingest: missing --file <capsule>" >&2; exit "${SFS_EXIT_USAGE}"; }
    [[ -f "${capsule}" ]] || { echo "ingest: capsule not found: ${capsule}" >&2; exit "${SFS_EXIT_USAGE}"; }
    # ── standalone gate: refuse + write nothing when the seam is off/absent ──
    if [[ "$(read_field enabled)" != "true" ]]; then
      echo "ingest: seam disabled (external_orchestrator.enabled != true) — no-op" >&2
      exit "${SFS_EXIT_DISABLED}"
    fi
    # ── schema validation: reject the whole capsule before any write ──
    if ! reason="$(validate_signal "${capsule}")"; then
      echo "ingest: SIGNAL schema reject — ${reason}" >&2
      exit "${SFS_EXIT_SCHEMA}"
    fi
    # ── append ONE typed entry to the orchestrator's own signal queue ──
    # sanitize every inbound free-text field (pipe-delimiter + control strip) so a
    # capsule cannot forge a structured field / extra line. kind is enum-validated
    # and confidence numeric-validated above.
    src="$(sanitize_text "$(capsule_field source "${capsule}")" 64)"
    knd="$(capsule_field kind "${capsule}")"
    ptr="$(sanitize_text "$(capsule_field evidence_pointer "${capsule}")" "${EVIDENCE_POINTER_MAXLEN}")"
    conf="$(capsule_field confidence "${capsule}")"
    ts="$(sanitize_text "$(capsule_field ts "${capsule}")" 64)"
    mkdir -p "$(dirname "${SIGNAL_QUEUE}")"
    if [[ ! -f "${SIGNAL_QUEUE}" ]]; then
      {
        printf '# Orchestrator SIGNAL queue (Seam A)\n\n'
        printf '%s\n' "Typed SIGNAL entries staged by 'sfs orchestrator ingest'. Read-only input to"
        printf '%s\n\n' "the curation pass; suggest-only — never the loop's authoritative state."
      } > "${SIGNAL_QUEUE}"
    fi
    printf -- '- signal | ts=%s | source=%s | kind=%s | confidence=%s | evidence_pointer=%s\n' \
      "${ts}" "${src}" "${knd}" "${conf}" "${ptr}" >> "${SIGNAL_QUEUE}"
    echo "ingest: staged 1 SIGNAL (${knd}) -> ${SIGNAL_QUEUE}"
    ;;
  export)
    shift
    candidates=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --from) shift; candidates="${1:-}" ;;
        --from=*) candidates="${1#--from=}" ;;
        *) echo "export: unknown arg: $1" >&2; usage >&2; exit "${SFS_EXIT_USAGE}" ;;
      esac
      shift || true
    done
    [[ -n "${candidates}" ]] || { echo "export: missing --from <candidates>" >&2; exit "${SFS_EXIT_USAGE}"; }
    [[ -f "${candidates}" ]] || { echo "export: candidates not found: ${candidates}" >&2; exit "${SFS_EXIT_USAGE}"; }
    require_enabled export
    # transport: file-drop is the implemented delivery (default). Other kinds
    # (api|webhook|cli) are config + a future adapter — OCP-narrow, like route P3.
    # Don't silently file-drop when the configured transport says otherwise.
    tk="$(read_field transport_kind)"; [[ -z "${tk}" ]] && tk="file-drop"
    if [[ "${tk}" != "file-drop" ]]; then
      echo "export: only the file-drop transport is wired; transport_kind='${tk}' is config-stubbed — delivering via file-drop" >&2
    fi
    outbox="$(read_field review_outbox)"; outbox="${outbox:-${ORCH_DIR}/outbox/}"
    outbox="${outbox%/}"
    out_file="${outbox}/proposal-export.md"
    mkdir -p "${outbox}"
    if [[ ! -f "${out_file}" ]]; then
      {
        printf '# Orchestrator proposal export (Seam B, pointer-only)\n\n'
        printf '%s\n\n' "Outbound proposals carry id + pointer + metadata only — never a raw body."
      } > "${out_file}"
    fi
    n=0
    while IFS= read -r line; do
      case "${line}" in '- candidate '*|'- candidate'*'|'*) ;; *) continue ;; esac
      out="- proposal"
      # whitelist ONLY: a raw `body=`/`raw=` field is structurally never emitted.
      # sanitize each value so a candidate cannot forge a structured field outbound.
      for k in ${EXPORT_FIELDS}; do
        v="$(sanitize_text "$(line_field "${k}" "${line}")" 256)"
        [[ -n "${v}" ]] && out="${out} | ${k}=${v}"
      done
      printf '%s\n' "${out}" >> "${out_file}"
      n=$((n + 1))
    done < "${candidates}"
    echo "export: wrote ${n} pointer-only proposal(s) -> ${out_file}"
    ;;
  import-review)
    shift
    review=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --file) shift; review="${1:-}" ;;
        --file=*) review="${1#--file=}" ;;
        *) echo "import-review: unknown arg: $1" >&2; usage >&2; exit "${SFS_EXIT_USAGE}" ;;
      esac
      shift || true
    done
    [[ -n "${review}" ]] || { echo "import-review: missing --file <review>" >&2; exit "${SFS_EXIT_USAGE}"; }
    [[ -f "${review}" ]] || { echo "import-review: review not found: ${review}" >&2; exit "${SFS_EXIT_USAGE}"; }
    require_enabled import-review
    cid="$(capsule_field candidate_id "${review}")"
    decision="$(capsule_field decision "${review}")"
    reviewer="$(capsule_field reviewer "${review}")"
    rts="$(capsule_field ts "${review}")"
    comment="$(capsule_field comment "${review}")"
    [[ -n "${cid}" ]] || { echo "import-review: schema reject — missing candidate_id" >&2; exit "${SFS_EXIT_SCHEMA}"; }
    case "${decision}" in
      approve|defer|reject) ;;
      "") echo "import-review: schema reject — missing decision" >&2; exit "${SFS_EXIT_SCHEMA}" ;;
      *)  echo "import-review: schema reject — decision '${decision}' not in approve|defer|reject" >&2; exit "${SFS_EXIT_SCHEMA}" ;;
    esac
    [[ -n "${rts}" ]] || { echo "import-review: schema reject — missing ts" >&2; exit "${SFS_EXIT_SCHEMA}"; }
    # sanitize EVERY inbound free-text field (not just comment) so a review cannot
    # forge a structured field / extra log line through any of them. decision is
    # already enum-validated. This records the human's decision — it NEVER triggers
    # APPLY; APPLY remains the tidy rail under a human gate.
    comment="$(sanitize_text "${comment}" "${COMMENT_MAXLEN}")"
    reviewer="$(sanitize_text "${reviewer}" 64)"
    cid="$(sanitize_text "${cid}" 64)"
    rts="$(sanitize_text "${rts}" 64)"
    mkdir -p "${ORCH_DIR}"
    if [[ ! -f "${REVIEW_LOG}" ]]; then
      {
        printf '# Orchestrator review log (Seam B, advisory)\n\n'
        printf '%s\n\n' "Imported human reviews. Advisory only — APPLY stays the tidy rail + human gate."
      } > "${REVIEW_LOG}"
    fi
    printf -- '- review | ts=%s | candidate_id=%s | decision=%s | reviewer=%s | comment=%s\n' \
      "${rts}" "${cid}" "${decision}" "${reviewer}" "${comment}" >> "${REVIEW_LOG}"
    echo "import-review: logged 1 review (${decision}) -> ${REVIEW_LOG} (advisory; no APPLY)"
    ;;
  ""|-h|--help|help)
    usage
    ;;
  *)
    echo "unknown subcommand: ${cmd}" >&2
    usage >&2
    exit "${SFS_EXIT_USAGE}"
    ;;
esac
