#!/usr/bin/env bash
# DESIGN-2026-07-03 P4 (idea_wiki:L087-I1/I2) — headline.
#
# Locks the AI maturity self-diagnosis in `sfs harness doctor`:
#   D5: entry point = doctor section (no new subcommand — readiness D1 precedent)
#   ladder = 5 levels scored from impact evidence in .sfs-local artifacts
#   (completed/reviewed sprints, queue done, lessons ledger), never usage counts
#   signal-only (ALT-INV-3): info lines only, rc-equality locked
# Signal tokens must match between policies/harness-maturity.md and doctor
# output. Deterministic bash fixtures only — no LLM in the loop.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
POLICY="${DIST_DIR}/templates/.sfs-local-template/context/policies/harness-maturity.md"
AUTONOMY="${DIST_DIR}/templates/.sfs-local-template/context/policies/harness-autonomy.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
has() { grep -Fq -- "$2" <<<"$1" || fail "$3: missing '$2'"; }

SIGNALS="delegated-wu review-loop parallel-capsule rework"

# ── Policy doc + routes ─────────────────────────────────────────────
[[ -f "${POLICY}" ]] || fail "missing policies/harness-maturity.md"
fhas "${POLICY}" "MATURITY_LADDER" "ladder section anchor"
fhas "${POLICY}" "IMPACT_SIGNALS" "impact-signals section anchor"
fhas "${POLICY}" "ONBOARDING_FIRST_QUESTION" "onboarding section anchor"
fhas "${POLICY}" "signal-only" "ALT-INV-3 wording"
fhas "${POLICY}" "idea_wiki:L087" "source pointer citation (by-reference)"
for sig in ${SIGNALS}; do
  fhas "${POLICY}" "${sig}" "policy signal token '${sig}'"
done
grep -q '^load_when:' "${POLICY}" || fail "policy missing load_when"
fhas "${DIST_DIR}/templates/.sfs-local-template/context/_INDEX.md" \
  "policies/harness-maturity.md" "index route"
fhas "${AUTONOMY}" "harness-maturity.md" "harness-autonomy cross-ref"
if grep -Eq '/Users/|/home/[a-z]' "${POLICY}"; then
  fail "harness-maturity policy leaks an absolute private path"
fi
lines="$(wc -l < "${POLICY}")"
[[ "${lines}" -lt 200 ]] || fail "policy exceeds 200-line budget (${lines})"

# Unverified vendor performance numbers must never appear as facts.
if grep -Eq '69%|37%|21x|21배|90%' "${POLICY}"; then
  fail "policy cites unverified case performance numbers"
fi

# doc colocation: product-shape wiki names the maturity diagnosis, both languages.
fhas "${DIST_DIR}/docs/en/current-product-shape/17-token-harness-hygiene.md" \
  "maturity" "wiki maturity bullet (en)"
fhas "${DIST_DIR}/docs/ko/current-product-shape/17-token-harness-hygiene.md" \
  "성숙도" "wiki maturity bullet (ko)"

# ── Fixtures through the real doctor ────────────────────────────────
tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/sfs-maturity.XXXXXX")"
trap 'rm -rf "${tmp_root}"' EXIT
export SFS_COST_FORCE_PARSER=none

run_doctor() { # echoes output + final "rc=<n>" line
  local rc=0 out
  out="$(SFS_DIST_DIR="${DIST_DIR}" bash "${DIST_DIR}/scripts/sfs-harness.sh" doctor 2>&1)" || rc=$?
  printf '%s\nrc=%d\n' "${out}" "${rc}"
}

proj="${tmp_root}/proj"
mkdir -p "${proj}"
cd "${proj}"
git init -q && git config user.email "m@solon.invalid" && git config user.name "M"
mkdir -p tests
printf '#!/usr/bin/env bash\necho ok\n' > tests/run-all.sh
printf '# proj\n' > README.md
git add -A && git commit -qm "init"
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1
printf '# proj router\nSee [README](README.md).\n' > SFS.md
git add -A && git commit -qm "sfs"

# 1) level 2 floor: initialized, no delegation evidence.
out_l2="$(run_doctor)"
has "${out_l2}" "AI Maturity (Self-Diagnosis)" "doctor maturity section"
has "${out_l2}" "maturity: level 2/5" "level-2 floor"
has "${out_l2}" "maturity: onboarding starts with locating the current level" "onboarding hint at floor"
rc_l2="$(sed -n 's/^rc=//p' <<<"${out_l2}")"

# signal tokens: policy <-> output lock.
for sig in ${SIGNALS}; do
  has "${out_l2}" "maturity: signal ${sig} " "doctor output signal token '${sig}'"
done

# 2) level 3: one completed WU with review evidence.
mkdir -p .sfs-local/sprints/2026-07-05-wu-demo
printf '# report\n' > .sfs-local/sprints/2026-07-05-wu-demo/report.md
printf '%s\n' '---' 'phase: review' '---' '# review' > .sfs-local/sprints/2026-07-05-wu-demo/review.md
out_l3="$(run_doctor)"
has "${out_l3}" "maturity: level 3/5" "level 3 on completed WU"
has "${out_l3}" "whole-task delegation" "level-3 label"
has "${out_l3}" "maturity: signal delegated-wu — completed WUs: 1 of 1" "delegated-wu count"
has "${out_l3}" "maturity: signal review-loop — review evidence in 1 of 1" "review-loop count"

# 3) level 4: autonomous queue completion.
mkdir -p .sfs-local/queue/done
printf 'wu: demo\n' > .sfs-local/queue/done/wu-001.md
out_l4="$(run_doctor)"
has "${out_l4}" "maturity: level 4/5" "level 4 on queue done"
has "${out_l4}" "parallel capsules" "level-4 label"
has "${out_l4}" "queue done: 1" "queue-done evidence count"

# 4) level 5: queue + review + release surface.
mkdir -p scripts .github/workflows
printf 'name: check\n' > .github/workflows/sfs-pr-check.yml
out_l5="$(run_doctor)"
has "${out_l5}" "maturity: level 5/5" "level 5 on queue+review+release"
has "${out_l5}" "unattended-capable outputs" "level-5 label"

# rework signal reads the lessons ledger (L-NNN entries).
cat >> .sfs-local/lessons.md <<'EOF'

## L-001 demo lesson
- rule: demo
EOF
out_lessons="$(run_doctor)"
has "${out_lessons}" "maturity: signal rework — lessons recorded: 1" "rework counts L-NNN entries"

# ── Signal-only locks ───────────────────────────────────────────────
# maturity lines are info only — never ok/warn/fail (level must not shift rc).
if grep -E '(✅|⚠️|❌|🟠)' <<<"${out_l5}" | grep -q 'maturity:'; then
  fail "maturity lines must be info-only"
fi
# rc-equality: climbing from level 2 to level 5 never changes doctor's rc.
rc_l5="$(sed -n 's/^rc=//p' <<<"${out_l5}")"
[[ "${rc_l2}" == "${rc_l5}" ]] \
  || fail "signal-only violated: doctor rc changed with maturity level (${rc_l2} -> ${rc_l5})"

echo "test-harness-maturity: OK"
