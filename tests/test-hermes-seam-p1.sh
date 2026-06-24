#!/usr/bin/env bash
# Hermes self-evolution seam wiring P1 — schema + adapter abstraction headline lock.
#
# P1 ships the contract only (no seam wiring yet): the external_orchestrator schema
# in model-profiles.yaml + a read-only resolver (sfs-orchestrator.sh). Seam A (signal
# ingest) is P2; Seam B (export/import + transport impl) is P3. This test locks the
# four P1 invariants from the design (2026-06-23-hermes-self-evolution-seam-wiring.md
# AC1/AC2/AC5/AC6) so wiring them later cannot silently break them:
#
#   (a) standalone   — enabled:false default + a stripped section both resolve to
#                      disabled with no crash (the loop never presupposes Hermes).
#   (b) no-auto-patch — the resolver is read-only data lookup: no eval, no code-file
#                       write, no CLI spawn, no ledger/skill mutation. The invariant
#                       SSoT marker still stands in self-improvement-loop.md.
#   (c) gate-bypass   — the typed inviolable-gate surface (policy markers) is intact
#                       and the resolver carries no release/push/merge path.
#   (d) OCP           — flipping transport_kind (file-drop->api) changes the resolved
#                       transport with the resolver script SHA unchanged (data = the
#                       single switch point; new orchestrator = config edit).
#
# ASCII anchors so no per-grep LC_ALL juggling is needed.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TPL="${DIST_DIR}/templates/.sfs-local-template"
ORCH="${TPL}/scripts/sfs-orchestrator.sh"
MP_TEMPLATE="${TPL}/model-profiles.yaml"
POLICY="${TPL}/context/policies/external-orchestrator-entry.md"
LOOP="${TPL}/context/policies/self-improvement-loop.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
has() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

[[ -f "${ORCH}" ]]        || fail "resolver not found: ${ORCH}"
[[ -f "${MP_TEMPLATE}" ]] || fail "model-profiles template not found: ${MP_TEMPLATE}"
[[ -x "${ORCH}" ]]        || fail "resolver not executable: ${ORCH}"

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-hermes-p1.XXXXXX")"
cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

MP="${TMP_DIR}/model-profiles.yaml"
cp "${MP_TEMPLATE}" "${MP}"
orch() { SFS_MODEL_PROFILES="${MP}" bash "${ORCH}" "$@"; }

# ── schema present in the shipped template (flat-scalar discipline) ───────────
has "${MP_TEMPLATE}" "external_orchestrator:" "schema block"
has "${MP_TEMPLATE}" "enabled: false" "default-off scalar"
has "${MP_TEMPLATE}" "adapter: hermes" "adapter id scalar"
has "${MP_TEMPLATE}" "transport_kind:" "transport_kind scalar"
has "${MP_TEMPLATE}" "signal_inbox:" "signal_inbox scalar"
has "${MP_TEMPLATE}" "review_outbox:" "review_outbox scalar"
has "${MP_TEMPLATE}" "scope: read-only" "first-permission read-only scalar"

# ── (a) standalone: default off ──────────────────────────────────────────────
[[ "$(orch resolve-enabled)" == "false" ]] || fail "(a) default enabled must be false (opt-in)"
orch show >/dev/null 2>&1 || fail "(a) show must not crash on the default template"

# ── (a) standalone: strip the whole section -> still disabled, no crash ───────
MP_STRIP="${TMP_DIR}/stripped.yaml"
awk '
  /^external_orchestrator:/ { drop=1; next }
  drop && /^[[:space:]]/ { next }
  drop && /^[[:space:]]*#/ { next }
  drop && /^[[:space:]]*$/ { next }
  drop { drop=0 }
  { print }
' "${MP}" > "${MP_STRIP}"
grep -q '^external_orchestrator:' "${MP_STRIP}" && fail "strip helper failed to remove the section"
[[ "$(SFS_MODEL_PROFILES="${MP_STRIP}" bash "${ORCH}" resolve-enabled)" == "false" ]] \
  || fail "(a) stripped section must resolve to disabled, never crash"
SFS_MODEL_PROFILES="${MP_STRIP}" bash "${ORCH}" show >/dev/null 2>&1 \
  || fail "(a) show must degrade cleanly (exit 0) when the section is absent"
# absent profile file entirely -> disabled, exit 0 (never a hard dependency).
[[ "$(SFS_MODEL_PROFILES="${TMP_DIR}/nope.yaml" bash "${ORCH}" resolve-enabled)" == "false" ]] \
  || fail "(a) absent profile must resolve to disabled"

# ── (b) no code auto-patch: resolver is read-only data lookup ─────────────────
# Structural: the P1 resolver must carry no execution / mutation path. (A live
# refusal test belongs to P3's review-import, where an execution path exists.)
grep -Eq '(^|[^_])eval([[:space:]]|$)' "${ORCH}" \
  && fail "(b) resolver contains 'eval' — read-only resolver must not eval"
grep -Eq '\b(claude|codex|agy|gemini)\b[[:space:]]+(exec|-p|-)' "${ORCH}" \
  && fail "(b) resolver spawns an external runtime CLI — P1 must not wire any call"
grep -Eq '(lessons\.md|evolution-ledger|skills?/|promoted)' "${ORCH}" \
  && fail "(b) resolver references a ledger/skill write target — must not auto-write"
grep -Eq '>>?[[:space:]]*"?\$\{?(LEDGER|LESSONS|SKILL)' "${ORCH}" \
  && fail "(b) resolver redirects into a ledger/skill file"
# the invariant SSoT marker still stands where it is declared once.
has "${LOOP}" "no code auto-patch" "(b) no-code-auto-patch invariant SSoT"

# ── (c) inviolable gates: typed surface intact + resolver has no gate path ────
has "${POLICY}" "Inviolable gates" "(c) inviolable-gate section"
has "${POLICY}" "cannot bypass" "(c) gate-bypass prohibition"
grep -Eq '\b(git[[:space:]]+(push|merge)|release|publish|--gate)\b' "${ORCH}" \
  && fail "(c) resolver carries a release/push/merge/gate path — gates must stay human-owned"

# ── (d) OCP: transport_kind is data; flip it, script SHA unchanged ────────────
[[ "$(orch resolve-transport)" == "file-drop" ]] || fail "(d) default transport_kind should be file-drop"
sha_before="$(shasum "${ORCH}" | awk '{print $1}')"
# flip ONLY external_orchestrator.transport_kind (block-scoped so it cannot hit
# runtime_registry.<rt>.transport_kind, which shares the key name).
awk '
  /^external_orchestrator:/ { inb=1 }
  inb && /^[A-Za-z_]/ && !/^external_orchestrator:/ { inb=0 }
  inb && /^[[:space:]]+transport_kind:/ { sub(/transport_kind:.*/, "transport_kind: api") }
  { print }
' "${MP}" > "${MP}.t" && mv "${MP}.t" "${MP}"
[[ "$(orch resolve-transport)" == "api" ]] || fail "(d) transport flip not read back as api"
# the runtime_registry claude entry must be untouched by the block-scoped edit.
[[ "$(SFS_MODEL_PROFILES="${MP}" bash "${TPL}/scripts/sfs-team.sh" resolve-transport claude)" == "argv" ]] \
  || fail "(d) block-scoped flip leaked into runtime_registry.transport_kind"
sha_after="$(shasum "${ORCH}" | awk '{print $1}')"
[[ "${sha_before}" == "${sha_after}" ]] || fail "(d) OCP: resolver script changed to switch transport (must be data-only)"

echo "test-hermes-seam-p1: OK"
