#!/usr/bin/env bash
# Writing discipline policy contract (0.7.8).
#
# 0.7.0~0.7.7 added agent-facing surfaces but the agent's output writing
# quality for user-facing artifacts (README.md, GUIDE.md, RELEASE-NOTES,
# study notes, reports) was not pinned. codex was observed shipping a
# README full of preamble / hedging / self-congratulation / re-statement,
# because the existing kernel rule was a compactness *floor* (do not
# lose evidence) without a fluff *ceiling*.
#
# 0.7.8 closes that gap with policies/writing-discipline.md (+ .ko.md),
# a kernel.md cross-link, an _INDEX.md entry, and a disambiguation note
# in docs/ko/10x-value/06-token-diet-10x.md that clarifies the existing
# "Caveman" reference is the persona/style toggle, not the writing-
# quality contract. This test locks the entire wiring.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

POL_EN="${DIST_DIR}/templates/.sfs-local-template/context/policies/writing-discipline.md"
POL_KO="${DIST_DIR}/templates/.sfs-local-template/context/policies/writing-discipline.ko.md"
KERNEL="${DIST_DIR}/templates/.sfs-local-template/context/kernel.md"
INDEX="${DIST_DIR}/templates/.sfs-local-template/context/_INDEX.md"
TOKEN_DIET="${DIST_DIR}/docs/ko/10x-value/06-token-diet-10x.md"

fail() { echo "FAIL: $*" >&2; exit 1; }

# ── 1) Both policy files exist with proper frontmatter ──────────────
for f in "${POL_EN}" "${POL_KO}"; do
  [[ -f "${f}" ]] || fail "missing policy file: ${f}"
  [[ "$(sed -n '1p' "${f}")" == "---" ]] \
    || fail "${f} missing opening frontmatter"
  grep -qE '^id:[[:space:]]*writing-discipline' "${f}" \
    || fail "${f} must declare id: writing-discipline (or writing-discipline-ko)"
  grep -qE '^summary:' "${f}" || fail "${f} missing summary"
  grep -qE '^load_when:' "${f}" || fail "${f} missing load_when triggers"
done

# ── 2) load_when triggers must include the high-signal user-facing
#       artifact keywords so the routed loader picks the policy up
#       automatically for the common cases. ─────────────────────────
en_triggers=( '"readme"' '"writing"' '"report"' '"documentation"' '"docs"' '"caveman"' '"README.md"' '"RELEASE-NOTES.md"' )
for trigger in "${en_triggers[@]}"; do
  grep -qF -- "${trigger}" "${POL_EN}" \
    || fail "EN policy load_when missing trigger: ${trigger}"
done
ko_triggers=( '"보고서"' '"문서 작성"' '"안내서"' '"미사여구"' )
for trigger in "${ko_triggers[@]}"; do
  grep -qF -- "${trigger}" "${POL_KO}" \
    || fail "KO policy load_when missing trigger: ${trigger}"
done

# ── 3) Body enumerates each forbidden fluff category. Without the
#       explicit list, the rule reads aspirational and codex / Claude /
#       Gemini cannot pattern-match against it during review. ───────
en_forbidden=( 'Preamble' 'Self-congratulation' 'Hedging' 'Re-statement' 'Filler conclusions' 'Marketing prose' )
for forbidden in "${en_forbidden[@]}"; do
  grep -qF -- "${forbidden}" "${POL_EN}" \
    || fail "EN policy body missing forbidden category: ${forbidden}"
done
ko_forbidden=( '서두' '자기 칭찬' 'hedging' '재진술' '마무리 상투구' '마케팅 톤' )
for forbidden in "${ko_forbidden[@]}"; do
  grep -qF -- "${forbidden}" "${POL_KO}" \
    || fail "KO policy body missing forbidden category: ${forbidden}"
done

# ── 4) Body enumerates what to KEEP. The policy must not read as a
#       pure list of prohibitions — the reader needs to know what
#       earns its place. ────────────────────────────────────────────
for keep_label in 'Facts' 'Decisions' 'Evidence' 'Boundaries'; do
  grep -qF -- "${keep_label}" "${POL_EN}" \
    || fail "EN policy must enumerate keep-category: ${keep_label}"
done
for keep_label in '사실' '결정' '근거' '경계'; do
  grep -qF -- "${keep_label}" "${POL_KO}" \
    || fail "KO policy must enumerate keep-category: ${keep_label}"
done

# ── 5) Caveman vs writing-discipline disambiguation present in both. ─
for f in "${POL_EN}" "${POL_KO}"; do
  grep -qF 'Caveman vs writing-discipline' "${f}" \
    || fail "${f} must keep the 'Caveman vs writing-discipline' disambiguation heading"
  grep -qF '06-token-diet-10x' "${f}" \
    || fail "${f} must cross-link the existing token-diet Caveman reference"
done

# ── 6) kernel.md cross-links the new policy. ────────────────────────
grep -qF 'writing-discipline' "${KERNEL}" \
  || fail "kernel.md must cross-link policies/writing-discipline.md"
grep -qE 'preamble.*hedging.*self-congratulation' "${KERNEL}" \
  || fail "kernel.md cross-link must enumerate the forbidden fluff categories so an agent reading kernel alone has the rule"

# ── 7) _INDEX.md lists the new policy alongside the other policies. ──
grep -qF 'policies/writing-discipline.md' "${INDEX}" \
  || fail "_INDEX.md missing writing-discipline policy entry"

# ── 8) token-diet-10x.md adds the disambiguation so a reader who lands
#       on the existing 'Caveman persona' row knows it is not the
#       writing-quality contract. ─────────────────────────────────────
grep -qF 'policies/writing-discipline.md' "${TOKEN_DIET}" \
  || fail "06-token-diet-10x.md must clarify that the Caveman persona row is a style toggle and link to policies/writing-discipline.md for the quality contract"
grep -qiE '스타일 토글|style toggle' "${TOKEN_DIET}" \
  || fail "06-token-diet-10x.md must label Caveman as a 'style toggle' to disambiguate from the writing-discipline quality contract"

# ── 9) Routed `sfs context cat policies/writing-discipline` resolves
#       to the EN policy (positive smoke). ──────────────────────────
if [[ -x "${DIST_DIR}/bin/sfs" ]]; then
  out="$(SFS_DIST_DIR="${DIST_DIR}" bash "${DIST_DIR}/bin/sfs" context cat policies/writing-discipline 2>&1)"
  grep -qF 'Writing Discipline (user-facing artifacts)' <<<"${out}" \
    || fail "sfs context cat policies/writing-discipline must resolve to the EN policy"
fi

echo "test-writing-discipline-policy: OK"
