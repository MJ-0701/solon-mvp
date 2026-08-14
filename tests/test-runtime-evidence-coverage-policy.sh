#!/usr/bin/env bash
# BLOG-2026-08-13-1 — declare the evidence ledger's coverage AND its blind spots.
#
# The whole value of this contract is the second list. A declaration that names
# only the covered runtimes reads as full coverage and is worse than none, so
# the test fails unless BOTH lists are present and the known-blind side names
# concrete runtimes.
#
# Also locks: the completion claim from an undeclared runtime is unverified, the
# orchestrator ingest seam carries a coverage tier, that the "one unified record
# per session" idea was NOT minted as a new anchor (cross-ref only, per the
# report), verdict/exit invariance, budgets, and a compliance-vendor lockout.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POL="${CTX}/policies"
FCP="${POL}/flow-conformance-postflight.md"
EOE="${POL}/external-orchestrator-entry.md"
SCC="${POL}/sub-agent-capsule-contract.md"
CH="${POL}/credential-hygiene.md"
SCD="${POL}/skill-catalog-discipline.md"
INDEX="${CTX}/_INDEX.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fanchor() { grep -Ewq -- "$2" "$1" || fail "$3: missing anchor '$2'"; }
fnot() { grep -Fq -- "$2" "$1" && fail "$3: forbidden '$2' present"; return 0; }

# ── (a) anchor + single owner ───────────────────────────────────────
fanchor "${FCP}" "RUNTIME_EVIDENCE_COVERAGE" "runtime-coverage anchor"
owners=0
while IFS= read -r f; do
  grep -Eq '^#{1,6}[[:space:]]+RUNTIME_EVIDENCE_COVERAGE' "$f" && owners=$((owners + 1))
done < <(find "${CTX}" "${DIST_DIR}/docs" -name '*.md' -type f)
[[ "${owners}" -eq 1 ]] || fail "RUNTIME_EVIDENCE_COVERAGE must be defined once (found ${owners})"

sect="$(awk '/^## RUNTIME_EVIDENCE_COVERAGE/{f=1;next} f&&/^## /{exit} f' "${FCP}")"
[[ -n "${sect}" ]] || fail "RUNTIME_EVIDENCE_COVERAGE section is empty"

# ── (b) BOTH lists — a one-sided declaration must fail ──────────────
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq '**covered**' \
  || fail "the covered-runtime list is missing"
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq '**known-blind**' \
  || fail "the known-blind list is missing — a one-sided declaration reads as full coverage"
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq '한쪽만 적힌 선언은 선언이 아니다' \
  || fail "the both-lists requirement must be stated, not merely demonstrated"
# each side names concrete runtimes rather than gesturing at the idea
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq 'events.jsonl' \
  || fail "the covered side must name the ledger it is covered by"
for s in "CLI 세션" "무인 스케줄 러너"; do
  LC_ALL=C printf '%s\n' "${sect}" | grep -Fq -- "$s" || fail "covered side missing runtime: $s"
done
for s in "호스트 UI" "파일버스" "외부 오케스트레이터"; do
  LC_ALL=C printf '%s\n' "${sect}" | grep -Fq -- "$s" || fail "known-blind side missing runtime: $s"
done

# ── (c) the consequence of not being declared ──────────────────────
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq 'unverified' \
  || fail "an undeclared runtime's completion claim must be classed unverified"
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq '거짓이 아니라' \
  || fail "unverified must be distinguished from false"
# the external-signal seam carries its tier, both here and at the seam itself
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq '커버리지 티어' \
  || fail "the external SIGNAL seam's coverage tier obligation is missing"
fhas "${EOE}" "RUNTIME_EVIDENCE_COVERAGE" "the ingest seam points back at the coverage contract"
fhas "${EOE}" "coverage tier" "the seam states the tier obligation where signals arrive"

# ── (d) the unified-record idea stays a cross-ref, not a new anchor ─
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq 'run 단위로 합쳐 읽을 수 있어야' \
  || fail "the run-grain readability cross-ref is missing"
for a in EVENT_LOG_RECONSTRUCTION_SSOT DONE_IS_ARTIFACT_ON_DISK; do
  LC_ALL=C printf '%s\n' "${sect}" | grep -Fq "$a" || fail "missing cross-ref to existing owner ${a}"
done
fanchor "${FCP}" "EVENT_LOG_RECONSTRUCTION_SSOT" "ledger-authority anchor preserved"
fhas "${SCC}" "DONE_IS_ARTIFACT_ON_DISK" "artifact-on-disk anchor preserved in its owner"
# these must NOT have been minted as rival anchors
for a in UNIFIED_SESSION_RECORD SESSION_EVIDENCE_RECORD COMPLIANCE_EXPORT_SURFACE \
         RUNTIME_LOGGING_TIER; do
  n="$( { grep -rlF "$a" "${CTX}" || true; } | wc -l | tr -d ' ')"
  [[ "$n" -eq 0 ]] || fail "deferred/covered item '$a' was minted as a new anchor"
done

# ── (e) already-covered items explicitly deferred ──────────────────
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq '재기안하지 않는다' \
  || fail "the already-covered items must be explicitly deferred"
for a in VERSIONED_EXTENSION_SURFACE AGENT_IDENTITY GRANT_LIFECYCLE; do
  LC_ALL=C printf '%s\n' "${sect}" | grep -Fq "$a" || fail "missing deferral cross-ref to ${a}"
done
fanchor "${SCD}" "VERSIONED_EXTENSION_SURFACE" "additive-extension anchor preserved in its owner"
fanchor "${CH}" "AGENT_IDENTITY" "identity anchor preserved in its owner"

# ── (f) verdict/exit invariance, both directions ───────────────────
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq 'verdict/exit 양방향 불변' \
  || fail "exit-code invariance must be stated in both directions"
rows="$(awk '/^\| id \| 기대 \| class \|/{f=1;next} f&&/^\|/{n++} f&&!/^\|/{exit} END{print n+0}' "${FCP}")"
[[ "${rows}" -eq 9 ]] \
  || fail "the FCP invariant registry changed size (expected 9 rows incl. separator, found ${rows})"

# ── (g) negative control on the doc surface ────────────────────────
# A declaration that lists only covered runtimes is the failure mode; assert the
# known-blind bullet is not empty prose.
blind="$(LC_ALL=C printf '%s\n' "${sect}" | grep -F '**known-blind**')"
[[ "${#blind}" -ge 40 ]] || fail "the known-blind entry is too thin to be a real declaration"

# ── (h) vendor lockout, scoped to the touched files ────────────────
for f in "${FCP}" "${EOE}"; do
  for s in "Compliance API" "eDiscovery" "Bedrock" "Vertex" "Foundry" \
           "Enterprise plan" "SOC 2" "Cowork"; do
    fnot "$f" "$s" "vendor lockout in $(basename "$f")"
  done
done

# ── (i) routed index + budgets ─────────────────────────────────────
fanchor "${INDEX}" "RUNTIME_EVIDENCE_COVERAGE" "index route"
for f in "${FCP}" "${EOE}" "${SCC}" "${CH}" "${SCD}" "${INDEX}"; do
  n="$(wc -l < "$f" | tr -d '[:space:]')"
  [[ "${n}" -le 200 ]] || fail "$(basename "$f") exceeds the 200-line budget: ${n}"
done

echo "PASS: runtime evidence coverage (covered + known-blind) locked"
