#!/usr/bin/env bash
# BLOG-2026-08-08-4 — reasoning trace as an audit deliverable.
#
# Locks REASONING_LOG_AS_AUDIT_ARTIFACT with its condition attached. The whole
# risk of this delta is that it reads as a blanket requirement, so the test
# asserts the gating as hard as the anchor: the tier condition must be in the
# body, it must reuse DELEGATION_UNIT_LADDER's tiering rather than invent a new
# one, and the cost rationale for keeping it off elsewhere must be stated.
#
# Also locks: the PRE_WORK_INVARIANT_DECLARATION cross-ref (this is the
# after-the-fact half of that pair), that the deferred items were NOT re-drafted
# (sandbox pre-execution and human sign-off stay owned by Gate 6 / the capsule
# contract), the one-line MODEL_HEAD_TO_HEAD_ON_UPGRADE extension, single-SSoT
# ownership, budgets, and a vendor lockout on the source's firm/sector detail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POL="${CTX}/policies"
FCP="${POL}/flow-conformance-postflight.md"
WD="${POL}/work-delegation-and-startup.md"
MWS="${POL}/model-workaround-sunset.md"
HA="${POL}/harness-autonomy.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fhasu() { LC_ALL=C grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fanchor() { grep -Ewq -- "$2" "$1" || fail "$3: missing anchor '$2'"; }
fnot() { grep -Fq -- "$2" "$1" && fail "$3: forbidden '$2' present"; return 0; }

# ── (a) anchor, single owner ────────────────────────────────────────
fanchor "${FCP}" "REASONING_LOG_AS_AUDIT_ARTIFACT" "reasoning-log anchor"
owners=0
while IFS= read -r f; do
  grep -Eq '^#{1,6}[[:space:]]+REASONING_LOG_AS_AUDIT_ARTIFACT' "$f" && owners=$((owners + 1))
done < <(find "${CTX}" "${DIST_DIR}/docs" -name '*.md' -type f)
[[ "${owners}" -eq 1 ]] || fail "REASONING_LOG_AS_AUDIT_ARTIFACT must be defined once (found ${owners})"

# Section body, isolated — every claim below must live inside it.
sect="$(awk '/^## REASONING_LOG_AS_AUDIT_ARTIFACT/{f=1;next} f&&/^## /{exit} f' "${FCP}")"
[[ -n "${sect}" ]] || fail "REASONING_LOG_AS_AUDIT_ARTIFACT section is empty"

# ── (b) the tier condition — the point of the whole delta ───────────
# It must be visible in the heading itself, so a skim cannot read it as blanket.
LC_ALL=C grep -Eq '^## REASONING_LOG_AS_AUDIT_ARTIFACT.*위험 티어 한정' "${FCP}" \
  || fail "the tier restriction must be on the heading, not only in the body"
for s in "최상위 위험 티어에 한해" "전면 적용 아님" "그 밖에서는 꺼 둔다"; do
  LC_ALL=C printf '%s\n' "${sect}" | grep -Fq -- "$s" \
    || fail "tier condition: body missing '$s'"
done
# ...and it reuses the existing tiering rather than minting one
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq 'DELEGATION_UNIT_LADDER' \
  || fail "tier condition must reuse DELEGATION_UNIT_LADDER"
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq '새 티어를 만들지 않고' \
  || fail "must state that no new tier is introduced"
fanchor "${WD}" "DELEGATION_UNIT_LADDER" "the reused ladder still exists"
# the cost rationale for keeping it off by default
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq '반복 토큰 비용' \
  || fail "missing the cost rationale for the restriction"

# ── (c) the pre-work / post-work pair ───────────────────────────────
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq 'PRE_WORK_INVARIANT_DECLARATION' \
  || fail "missing the PRE_WORK_INVARIANT_DECLARATION cross-ref"
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq '사후 짝' \
  || fail "the pair relationship (after-the-fact half) is not stated"
fanchor "${HA}" "PRE_WORK_INVARIANT_DECLARATION" "the pre-work half still exists in its owner"
# distinguished from the sibling that already lives in this same file
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq 'HONEST_UNKNOWNS' \
  || fail "not distinguished from its in-file sibling HONEST_UNKNOWNS"
fanchor "${FCP}" "HONEST_UNKNOWNS" "HONEST_UNKNOWNS preserved"

# ── (d) no new mechanism; signal-only ───────────────────────────────
for s in "새 파일 클래스도, 새 명령도 없다" "signal-only" "output_paths"; do
  LC_ALL=C printf '%s\n' "${sect}" | grep -Fq -- "$s" || fail "no-new-mechanism: missing '$s'"
done
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq 'verdict/exit 불변' \
  || fail "exit-code invariance not stated"

# ── (e) deferred items must NOT have been re-drafted ────────────────
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq '재기안하지 않는다' \
  || fail "sandbox/sign-off must be explicitly deferred to their existing owners"
for a in SANDBOX_PREEXECUTION HUMAN_SIGNOFF_GATE SESSION_MEMORY_CARRYOVER; do
  n="$( { grep -rlF "$a" "${CTX}" || true; } | wc -l | tr -d ' ')"
  [[ "$n" -eq 0 ]] || fail "deferred item '$a' was re-drafted as a new anchor"
done

# ── (f) MODEL_HEAD_TO_HEAD_ON_UPGRADE one-line extension ────────────
fanchor "${MWS}" "MODEL_HEAD_TO_HEAD_ON_UPGRADE" "head-to-head anchor preserved"
fhas "${MWS}" "fixed reference repository" "the pinned-baseline extension"
fhas "${MWS}" "constant ground" "why the baseline is pinned"
fhas "${MWS}" "HELD_OUT_SCORING" "pre-existing scoring owner preserved"

# ── (g) vendor lockout, scoped to the touched files ─────────────────
for f in "${FCP}" "${MWS}" "${WD}"; do
  for s in "Millennium" "hedge fund" "헤지펀드" "risk analyst at" "AI lab" "digital risk analyst"; do
    fnot "$f" "$s" "vendor lockout in $(basename "$f")"
  done
done

# ── (h) budgets ─────────────────────────────────────────────────────
for f in "${FCP}" "${MWS}" "${WD}"; do
  n="$(wc -l < "$f" | tr -d ' ')"
  [[ "$n" -le 200 ]] || fail "$(basename "$f") exceeds the 200-line budget: ${n}"
done

echo "PASS: reasoning log as a tier-gated audit artifact"
