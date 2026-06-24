#!/usr/bin/env bash
# Hermes self-evolution seam wiring P2 — Seam A typed signal ingest headline lock.
#
# P2 wires Seam A: `sfs orchestrator ingest --file <capsule>` validates a typed
# SIGNAL capsule and appends one typed entry to the orchestrator's own signal
# queue (.sfs-local/orchestrator/signal-queue.md), which the curation pass reads
# read-only as an additional SIGNAL input. It stages a suggestion — it never
# writes the loop's authoritative state.
#
# SIGNAL schema = the 5 typed fields the design SSoT §4 names
# ({source, kind, evidence_pointer, confidence, ts}). NOTE the task says "8필드
# schema": the 8-field sub-agent-capsule-contract is the typed-handoff *discipline*
# (named fields, validate-before-consume); a SIGNAL is a different artifact whose
# typed schema is the design §4 five fields — a `detection`/`hotspot` signal has no
# acceptance_criteria/token_budget, so a single 8-field schema cannot cover it.
# Reconciliation recorded in CHANGELOG 0.8.46 + design §10.
#
# Locks (design AC3 + P1 invariants carried):
#   (1) schema       — a valid 5-field capsule ingests (exit 0) + appends exactly
#                       one typed queue entry; a bad `kind`, a missing required
#                       field, and a non-pointer (blob) evidence all reject with no
#                       queue write.
#   (2) suggest-only — ingest writes ONLY the signal queue; no lessons ledger /
#                       evolution ledger / skill file is created or touched.
#   (3) standalone   — ingest with enabled:false (default) or the section absent
#                       refuses/no-ops and creates NO queue (invariant 2 carried to
#                       the new write verb).
#   (4) read-only resolver intact — the resolve-* surface still answers, and the
#                       script still carries no eval / CLI spawn / gate path.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TPL="${DIST_DIR}/templates/.sfs-local-template"
ORCH="${TPL}/scripts/sfs-orchestrator.sh"
MP_TEMPLATE="${TPL}/model-profiles.yaml"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f "${ORCH}" ]] || fail "resolver not found: ${ORCH}"

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-hermes-p2.XXXXXX")"
cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

# A consumer-shaped .sfs-local with the seam ENABLED.
LOCAL="${TMP_DIR}/.sfs-local"
mkdir -p "${LOCAL}/orchestrator/inbox"
MP="${LOCAL}/model-profiles.yaml"
cp "${MP_TEMPLATE}" "${MP}"
enable_seam() {
  awk '
    /^external_orchestrator:/ { inb=1 }
    inb && /^[A-Za-z_]/ && !/^external_orchestrator:/ { inb=0 }
    inb && /^[[:space:]]+enabled:/ { sub(/enabled:.*/, "enabled: true") }
    { print }
  ' "${MP}" > "${MP}.t" && mv "${MP}.t" "${MP}"
}
enable_seam
[[ "$(SFS_MODEL_PROFILES="${MP}" bash "${ORCH}" resolve-enabled)" == "true" ]] || fail "setup: seam not enabled"

QUEUE="${LOCAL}/orchestrator/signal-queue.md"
# run ingest inside the temp project root (SFS_LOCAL_DIR points at our .sfs-local).
ingest() { ( cd "${TMP_DIR}" && SFS_LOCAL_DIR=".sfs-local" SFS_MODEL_PROFILES="${MP}" bash "${ORCH}" ingest "$@" ); }

write_capsule() {
  cat > "$1" <<'EOF'
source: hermes
kind: completed-work
evidence_pointer: .sfs-local/archives/events/sprints/2026-06-24/run.jsonl#L42
confidence: 0.82
ts: 2026-06-24T10:00:00Z
EOF
}

# ── (1) schema: a valid 5-field capsule ingests + appends exactly one entry ───
CAP_OK="${LOCAL}/orchestrator/inbox/ok.yaml"
write_capsule "${CAP_OK}"
ingest --file "${CAP_OK}" >/dev/null 2>&1 || fail "(1) valid capsule rejected"
[[ -f "${QUEUE}" ]] || fail "(1) signal queue not created on valid ingest"
[[ "$(grep -c 'kind=completed-work' "${QUEUE}")" -eq 1 ]] || fail "(1) expected exactly one typed queue entry"
grep -Fq 'source=hermes' "${QUEUE}" || fail "(1) queue entry missing typed source field"
grep -Fq 'evidence_pointer=' "${QUEUE}" || fail "(1) queue entry missing evidence_pointer"

# a second valid ingest appends (does not overwrite).
CAP_OK2="${LOCAL}/orchestrator/inbox/ok2.yaml"
write_capsule "${CAP_OK2}"
ingest --file "${CAP_OK2}" >/dev/null 2>&1 || fail "(1) second valid capsule rejected"
[[ "$(grep -c 'kind=completed-work' "${QUEUE}")" -eq 2 ]] || fail "(1) ingest must append, not overwrite"

# ── (1) sanitize: an inbound field with a pipe-delimiter cannot forge a field ─
CAP_INJ="${LOCAL}/orchestrator/inbox/inj.yaml"
{ echo "source: hermes | kind=detection | confidence=9.9"; echo "kind: completed-work"; echo "evidence_pointer: x#1"; echo "confidence: 0.5"; echo "ts: 2026-06-24T10:00:00Z"; } > "${CAP_INJ}"
ingest --file "${CAP_INJ}" >/dev/null 2>&1 || fail "(1) valid capsule with pipe in source rejected"
last_line="$(tail -1 "${QUEUE}")"
# the delimiter (|) is stripped from the value, so only ONE pipe-delimited kind=
# field exists — the forged 'kind=detection' survives only as inert text.
[[ "$(printf '%s' "${last_line}" | grep -o '| kind=' | wc -l | tr -d ' ')" -eq 1 ]] \
  || fail "(1) pipe in source forged an extra structured kind= field in the queue line"

# ── (1) reject: bad kind, missing field, blob evidence — each leaves queue intact
queue_lines() { wc -l < "${QUEUE}" | tr -d ' '; }
before="$(queue_lines)"

CAP_BADKIND="${LOCAL}/orchestrator/inbox/badkind.yaml"
{ echo "source: hermes"; echo "kind: please-run-rm-rf"; echo "evidence_pointer: x#1"; echo "confidence: 0.5"; echo "ts: 2026-06-24T10:00:00Z"; } > "${CAP_BADKIND}"
ingest --file "${CAP_BADKIND}" >/dev/null 2>&1 && fail "(1) invalid kind must be rejected"
[[ "$(queue_lines)" == "${before}" ]] || fail "(1) rejected bad-kind capsule still wrote to queue"

CAP_MISSING="${LOCAL}/orchestrator/inbox/missing.yaml"
{ echo "source: hermes"; echo "kind: detection"; echo "confidence: 0.5"; echo "ts: 2026-06-24T10:00:00Z"; } > "${CAP_MISSING}"
ingest --file "${CAP_MISSING}" >/dev/null 2>&1 && fail "(1) missing evidence_pointer must be rejected"
[[ "$(queue_lines)" == "${before}" ]] || fail "(1) rejected missing-field capsule still wrote to queue"

# blob (raw content, not a pointer) evidence_pointer rejected — outbound stays
# pointer-only and inbound carries pointers, not inlined originals.
CAP_BLOB="${LOCAL}/orchestrator/inbox/blob.yaml"
blob="$(head -c 900 < /dev/zero | tr '\0' 'A')"
{ echo "source: hermes"; echo "kind: hotspot"; echo "evidence_pointer: ${blob}"; echo "confidence: 0.5"; echo "ts: 2026-06-24T10:00:00Z"; } > "${CAP_BLOB}"
ingest --file "${CAP_BLOB}" >/dev/null 2>&1 && fail "(1) blob (non-pointer) evidence must be rejected"
[[ "$(queue_lines)" == "${before}" ]] || fail "(1) rejected blob capsule still wrote to queue"

# ── (2) suggest-only: only the queue exists — no loop-authoritative state ─────
[[ ! -e "${LOCAL}/lessons.md" ]] || fail "(2) ingest created a lessons ledger (must be suggest-only)"
[[ ! -e "${LOCAL}/harness/evolution-ledger.md" ]] || fail "(2) ingest wrote the evolution ledger"
[[ ! -d "${LOCAL}/skills" ]] || fail "(2) ingest created a skills dir"

# ── (3) standalone: disabled / absent section -> refuse, NO queue created ─────
LOCAL2="${TMP_DIR}/standalone/.sfs-local"
mkdir -p "${LOCAL2}/orchestrator/inbox"
cp "${MP_TEMPLATE}" "${LOCAL2}/model-profiles.yaml"   # default enabled:false
write_capsule "${LOCAL2}/orchestrator/inbox/ok.yaml"
( cd "${TMP_DIR}/standalone" && SFS_LOCAL_DIR=".sfs-local" SFS_MODEL_PROFILES=".sfs-local/model-profiles.yaml" \
    bash "${ORCH}" ingest --file ".sfs-local/orchestrator/inbox/ok.yaml" ) >/dev/null 2>&1 \
  && fail "(3) ingest must refuse when the seam is disabled"
[[ ! -e "${LOCAL2}/orchestrator/signal-queue.md" ]] || fail "(3) disabled ingest still created a queue (standalone leak)"

# section stripped entirely -> still refuses, no crash, no queue.
LOCAL3="${TMP_DIR}/stripped/.sfs-local"
mkdir -p "${LOCAL3}/orchestrator/inbox"
awk '
  /^external_orchestrator:/ { drop=1; next }
  drop && /^[[:space:]]/ { next }
  drop && /^[[:space:]]*#/ { next }
  drop && /^[[:space:]]*$/ { next }
  drop { drop=0 }
  { print }
' "${MP_TEMPLATE}" > "${LOCAL3}/model-profiles.yaml"
write_capsule "${LOCAL3}/orchestrator/inbox/ok.yaml"
( cd "${TMP_DIR}/stripped" && SFS_LOCAL_DIR=".sfs-local" SFS_MODEL_PROFILES=".sfs-local/model-profiles.yaml" \
    bash "${ORCH}" ingest --file ".sfs-local/orchestrator/inbox/ok.yaml" ) >/dev/null 2>&1 \
  && fail "(3) ingest with stripped section must refuse"
[[ ! -e "${LOCAL3}/orchestrator/signal-queue.md" ]] || fail "(3) stripped-section ingest created a queue"

# ── (4) read-only resolver + no-execution-path invariants carried ────────────
[[ "$(SFS_MODEL_PROFILES="${MP}" bash "${ORCH}" resolve-transport)" == "file-drop" ]] \
  || fail "(4) resolve surface broke after adding ingest"
grep -Eq '(^|[^_])eval([[:space:]]|$)' "${ORCH}" && fail "(4) ingest path introduced 'eval'"
grep -Eq '\b(claude|codex|agy|gemini)\b[[:space:]]+(exec|-p|-)' "${ORCH}" && fail "(4) ingest spawns a runtime CLI"
grep -Eq '\b(git[[:space:]]+(push|merge)|--gate)\b' "${ORCH}" && fail "(4) ingest carries a gate/push/merge path"

echo "test-hermes-seam-p2: OK"
