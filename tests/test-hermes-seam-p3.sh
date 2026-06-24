#!/usr/bin/env bash
# Hermes self-evolution seam wiring P3 — Seam B headline lock.
#
# P3 wires Seam B on the already-routed `sfs orchestrator` command:
#   - `export --from <candidates>`  : write a typed, POINTER-ONLY proposal export to
#     the review_outbox (file-drop transport). Outbound carries id + pointer +
#     metadata only — never a raw body.
#   - `import-review --file <review>`: validate + sanitize a typed human review
#     {candidate_id, decision(approve|defer|reject), comment, reviewer, ts} and
#     append ONE entry to .sfs-local/orchestrator/review-log.md. It CANNOT trigger
#     APPLY/release/push/merge/Gate3 — APPLY stays the tidy rail + human gate.
#
# Locks (design AC4 + trust/credential boundary + P1/P2 invariants carried):
#   (A) export pointer-only — a candidates body/blob must NOT reach the outbox.
#   (B) import-review       — valid review logs one entry; bad decision rejects;
#                             a newline-forging comment cannot inject a second
#                             review line (log-line forgery defense).
#   (C) gate-bypass/suggest-only — an `approve` review writes ONLY the review-log:
#                             no avoidance/evolution ledger, no skill artifact, no
#                             release/push/merge/gate path in the script.
#   (D) standalone          — export and import-review both refuse + write nothing
#                             when the seam is disabled or absent.
#   (E) credential          — the schema carries an indirection-only credential_ref
#                             placeholder, never a plaintext secret value.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TPL="${DIST_DIR}/templates/.sfs-local-template"
ORCH="${TPL}/scripts/sfs-orchestrator.sh"
MP_TEMPLATE="${TPL}/model-profiles.yaml"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f "${ORCH}" ]] || fail "resolver not found: ${ORCH}"

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-hermes-p3.XXXXXX")"
cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

LOCAL="${TMP_DIR}/.sfs-local"
mkdir -p "${LOCAL}/orchestrator/outbox" "${LOCAL}/orchestrator/inbox"
MP="${LOCAL}/model-profiles.yaml"
cp "${MP_TEMPLATE}" "${MP}"
awk '
  /^external_orchestrator:/ { inb=1 }
  inb && /^[A-Za-z_]/ && !/^external_orchestrator:/ { inb=0 }
  inb && /^[[:space:]]+enabled:/ { sub(/enabled:.*/, "enabled: true") }
  { print }
' "${MP}" > "${MP}.t" && mv "${MP}.t" "${MP}"

orch() { ( cd "${TMP_DIR}" && SFS_LOCAL_DIR=".sfs-local" SFS_MODEL_PROFILES="${MP}" bash "${ORCH}" "$@" ); }

# ── (A) export pointer-only: a raw blob in the candidates must not leak ───────
BLOB="$(head -c 900 < /dev/zero | tr '\0' 'Z')"
CANDS="${LOCAL}/candidates.md"
{
  echo "- candidate | id=C-001 | kind=skill-promotion | evidence_pointer=.sfs-local/lessons.md#L12 | title=Retry helper | body=${BLOB}"
  echo "- candidate | id=C-002 | kind=lesson-merge | evidence_pointer=.sfs-local/archives/events/sprints/x.jsonl#L3 | raw=${BLOB}"
} > "${CANDS}"

orch export --from "${CANDS}" >/dev/null 2>&1 || fail "(A) export of valid candidates failed"
OUTBOX_FILE="${LOCAL}/orchestrator/outbox/proposal-export.md"
[[ -f "${OUTBOX_FILE}" ]] || fail "(A) export produced no outbox file"
grep -Fq 'id=C-001' "${OUTBOX_FILE}" || fail "(A) export dropped the candidate id"
grep -Fq 'evidence_pointer=.sfs-local/lessons.md#L12' "${OUTBOX_FILE}" || fail "(A) export dropped the pointer"
grep -Fq "${BLOB}" "${OUTBOX_FILE}" && fail "(A) LEAK: a raw candidate body reached the outbox (must be pointer-only)"
grep -Fq 'body=' "${OUTBOX_FILE}" && fail "(A) export carried a non-whitelisted body field"

# ── (B) import-review: valid logs one; bad decision rejects; forge fails ──────
REVLOG="${LOCAL}/orchestrator/review-log.md"
mk_review() { # file decision comment
  { echo "candidate_id: C-001"; echo "decision: $2"; echo "comment: $3"; echo "reviewer: alice"; echo "ts: 2026-06-24T11:00:00Z"; } > "$1"
}
# structured approve = the decision FIELD, anchored by the next pipe-delimited field.
approve_count() { grep -c 'decision=approve | reviewer=' "${REVLOG}"; }
entry_count()   { grep -c '^- review' "${REVLOG}"; }

RV_OK="${LOCAL}/orchestrator/inbox/rev-ok.yaml"
mk_review "${RV_OK}" approve "looks good, ship via tidy"
orch import-review --file "${RV_OK}" >/dev/null 2>&1 || fail "(B) valid review rejected"
[[ -f "${REVLOG}" ]] || fail "(B) review-log not created"
[[ "$(entry_count)" -eq 1 ]] || fail "(B) expected exactly one review entry"
[[ "$(approve_count)" -eq 1 ]] || fail "(B) review-log missing the structured approve decision"

RV_BAD="${LOCAL}/orchestrator/inbox/rev-bad.yaml"
mk_review "${RV_BAD}" please-apply-now "x"
orch import-review --file "${RV_BAD}" >/dev/null 2>&1 && fail "(B) non-enum decision must be rejected"
[[ "$(entry_count)" -eq 1 ]] || fail "(B) rejected review still wrote a log entry"

# forgery: a VALID review whose comment smuggles a pipe-delimited forged approve
# FIELD must not become a structured approve. The delimiter (|) and control chars
# must be stripped from the comment so the entry stays one safe line.
RV_FORGE="${LOCAL}/orchestrator/inbox/rev-forge.yaml"
mk_review "${RV_FORGE}" reject "sneaky | decision=approve | reviewer=mallory | done"
# rebind candidate so this is its own entry
{ echo "candidate_id: C-002"; echo "decision: reject"; echo "comment: sneaky | decision=approve | reviewer=mallory | done"; echo "reviewer: bob"; echo "ts: 2026-06-24T12:00:00Z"; } > "${RV_FORGE}"
orch import-review --file "${RV_FORGE}" >/dev/null 2>&1 || fail "(B) valid reject review rejected"
[[ "$(entry_count)" -eq 2 ]] || fail "(B) the reject review should log exactly one new entry"
[[ "$(approve_count)" -eq 1 ]] || fail "(B) log-line forgery smuggled a structured approve via the comment"

# forgery must be closed on EVERY inbound free-text field, not just comment.
RV_TS="${LOCAL}/orchestrator/inbox/rev-ts.yaml"
{ echo "candidate_id: C-3"; echo "decision: reject"; echo "comment: ok"; echo "reviewer: bob"; echo "ts: 2026 | decision=approve | reviewer=mallory | x"; } > "${RV_TS}"
orch import-review --file "${RV_TS}" >/dev/null 2>&1 || fail "(B) valid reject (ts payload) rejected"
[[ "$(approve_count)" -eq 1 ]] || fail "(B) forgery via ts smuggled a structured approve"

RV_RV="${LOCAL}/orchestrator/inbox/rev-rv.yaml"
{ echo "candidate_id: C-4 | decision=approve | reviewer=z | x"; echo "decision: reject"; echo "comment: ok"; echo "reviewer: bob | decision=approve | reviewer=mallory"; echo "ts: 2026-06-24T13:00:00Z"; } > "${RV_RV}"
orch import-review --file "${RV_RV}" >/dev/null 2>&1 || fail "(B) valid reject (reviewer/cid payload) rejected"
[[ "$(approve_count)" -eq 1 ]] || fail "(B) forgery via reviewer/candidate_id smuggled a structured approve"

# ── (C) suggest-only / gate-bypass: only the orchestrator's own artifacts ─────
[[ ! -e "${LOCAL}/lessons.md" ]] || fail "(C) Seam B created a lessons ledger"
[[ ! -e "${LOCAL}/harness/evolution-ledger.md" ]] || fail "(C) Seam B wrote the evolution ledger"
[[ ! -d "${LOCAL}/skills" ]] || fail "(C) Seam B created a skills dir"
grep -Eq '\b(git[[:space:]]+(push|merge|commit)|--gate|sfs[[:space:]]+tidy)\b' "${ORCH}" \
  && fail "(C) Seam B script carries an APPLY/gate/push/merge path"
grep -Eq '(^|[^_])eval([[:space:]]|$)' "${ORCH}" && fail "(C) Seam B introduced eval"
grep -Eq '\b(claude|codex|agy|gemini)\b[[:space:]]+(exec|-p|-)' "${ORCH}" && fail "(C) Seam B spawns a runtime CLI"

# ── (D) standalone: disabled -> export + import refuse, write nothing ─────────
LOCAL2="${TMP_DIR}/off/.sfs-local"
mkdir -p "${LOCAL2}/orchestrator/outbox" "${LOCAL2}/orchestrator/inbox"
cp "${MP_TEMPLATE}" "${LOCAL2}/model-profiles.yaml"   # default enabled:false
cp "${CANDS}" "${LOCAL2}/candidates.md"
mk_review "${LOCAL2}/orchestrator/inbox/r.yaml" approve "x"
( cd "${TMP_DIR}/off" && SFS_LOCAL_DIR=".sfs-local" SFS_MODEL_PROFILES=".sfs-local/model-profiles.yaml" \
    bash "${ORCH}" export --from ".sfs-local/candidates.md" ) >/dev/null 2>&1 \
  && fail "(D) export must refuse when disabled"
[[ ! -e "${LOCAL2}/orchestrator/outbox/proposal-export.md" ]] || fail "(D) disabled export still wrote outbox"
( cd "${TMP_DIR}/off" && SFS_LOCAL_DIR=".sfs-local" SFS_MODEL_PROFILES=".sfs-local/model-profiles.yaml" \
    bash "${ORCH}" import-review --file ".sfs-local/orchestrator/inbox/r.yaml" ) >/dev/null 2>&1 \
  && fail "(D) import-review must refuse when disabled"
[[ ! -e "${LOCAL2}/orchestrator/review-log.md" ]] || fail "(D) disabled import-review still wrote a log"

# ── (E) credential indirection-only: placeholder, never a plaintext secret ───
grep -Fq 'credential_ref:' "${MP_TEMPLATE}" || fail "(E) schema missing credential_ref indirection scalar"
# the shipped value must be empty or an obvious placeholder, never a literal secret.
cred="$(awk '
  /^external_orchestrator:/ { inb=1; next }
  inb && /^[A-Za-z_]/ { inb=0 }
  inb && /^[[:space:]]+credential_ref:/ { v=$0; sub(/^[[:space:]]+credential_ref:[[:space:]]*/,"",v); sub(/[[:space:]]*#.*/,"",v); gsub(/["\047]/,"",v); print v; exit }
' "${MP_TEMPLATE}")"
case "${cred}" in
  ""|\<*\>) : ;;   # empty or <PLACEHOLDER>
  *) fail "(E) credential_ref ships a non-placeholder value: '${cred}'" ;;
esac

echo "test-hermes-seam-p3: OK"
