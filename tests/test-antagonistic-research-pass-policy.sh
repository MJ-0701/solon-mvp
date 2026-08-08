#!/usr/bin/env bash
# BLOG-2026-08-08-2 — running broad autonomy in production.
#
# Locks ANTAGONISTIC_RESEARCH_PASS (attack the conclusion you found yourself,
# once, after research and before implementation; the refutation trace is the
# deliverable and its absence is a review finding) as a distinct third member
# of a family Solon already had two of — HONEST_UNKNOWNS ("say what you do not
# know") and BLIND_SPOT_PASS ("ask what was never said") — so the three are
# discriminable rather than three names for one pass.
#
# Also locks: the plan rail routing the pass at the right moment, the research
# step being folded into DONE_IS_ARTIFACT_ON_DISK rather than given a new
# artifact contract, DELEGATION_UNIT_LADDER's measurable-signal input for
# unattended delegation, `sfs harness doctor`'s new gate-activity signal being
# info-only with the exit code unchanged, single-SSoT ownership, budgets, and a
# vendor lockout on the source's company names and figures.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POL="${CTX}/policies"
SPC="${POL}/source-pointer-citation.md"
UAD="${POL}/unknowns-and-deviations.md"
CAP="${POL}/sub-agent-capsule-contract.md"
WD="${POL}/work-delegation-and-startup.md"
PLAN="${CTX}/commands/plan.md"
HARNESS="${DIST_DIR}/scripts/sfs-harness.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fanchor() { grep -Ewq -- "$2" "$1" || fail "$3: missing anchor '$2'"; }
fnot() { grep -Fq -- "$2" "$1" && fail "$3: forbidden '$2' present"; return 0; }

# ── (a) the anchor, and its single owner ────────────────────────────
fanchor "${SPC}" "ANTAGONISTIC_RESEARCH_PASS" "antagonistic-research anchor"
owners=0
while IFS= read -r f; do
  grep -Eq '^#{1,6}[[:space:]]+ANTAGONISTIC_RESEARCH_PASS[[:space:]]*$' "$f" && owners=$((owners + 1))
done < <(find "${CTX}" "${DIST_DIR}/docs" -name '*.md' -type f)
[[ "${owners}" -eq 1 ]] || fail "ANTAGONISTIC_RESEARCH_PASS must be defined once (found ${owners})"
grep -Eq '^#{1,6}[[:space:]]+ANTAGONISTIC_RESEARCH_PASS[[:space:]]*$' "${SPC}" \
  || fail "ANTAGONISTIC_RESEARCH_PASS owner must be source-pointer-citation.md"

# ── (b) it is the *third* member, discriminated from the other two ──
# All three names must appear in the owning section, each with its own gloss,
# so the file distinguishes them instead of aliasing them.
sect="$(awk '/^## ANTAGONISTIC_RESEARCH_PASS/{f=1;next} f&&/^## /{exit} f' "${SPC}")"
[[ -n "${sect}" ]] || fail "ANTAGONISTIC_RESEARCH_PASS section is empty"
for n in HONEST_UNKNOWNS BLIND_SPOT_PASS ANTAGONISTIC_RESEARCH_PASS; do
  printf '%s\n' "${sect}" | grep -Fq -- "$n" || fail "discrimination: section never names ${n}"
done
printf '%s\n' "${sect}" | grep -Fq 'say what you do not' || fail "gloss for HONEST_UNKNOWNS missing"
printf '%s\n' "${sect}" | grep -Fq 'ask what was never said' || fail "gloss for BLIND_SPOT_PASS missing"
printf '%s\n' "${sect}" | grep -Fq 'attack the answer you already found' || fail "gloss for the new pass missing"
# The distinguishing claim: it covers the gap the other two cannot see.
printf '%s\n' "${sect}" | grep -Fq 'neither can see' || fail "the gap-neither-covers claim missing"

# ── (c) substance: timing, trace, and the finding on absence ────────
fhas "${SPC}" "before implementation begins" "the pass runs pre-implementation"
fhas "${SPC}" "refute" "the pass is adversarial, not confirmatory"
fhas "${SPC}" "no** refutation trace is a review finding" "absent trace is a finding"
fhas "${SPC}" "nothing is a valid result" "a clean pass is a result, not a failure"
fhas "${SPC}" "never exit codes" "signal-only"

# ── (d) the two siblings still own their own anchors (no takeover) ──
fanchor "${UAD}" "BLIND_SPOT_PASS" "BLIND_SPOT_PASS stays in unknowns-and-deviations"
fhas "${UAD}" "ANTAGONISTIC_RESEARCH_PASS" "sibling cross-ref from unknowns-and-deviations"
grep -Eq '^#{1,6}[[:space:]]+ANTAGONISTIC_RESEARCH_PASS' "${UAD}" \
  && fail "unknowns-and-deviations must point at the pass, not redefine it"
fanchor "${POL}/flow-conformance-postflight.md" "HONEST_UNKNOWNS" "HONEST_UNKNOWNS owner preserved"

# ── (e) routed from the plan rail at the right moment ───────────────
fhas "${PLAN}" "ANTAGONISTIC_RESEARCH_PASS" "plan rail routes the pass"
fhas "${PLAN}" "refutation trace" "plan carries the trace slot"
fhas "${PLAN}" "source-pointer-citation.md" "plan points at the owner, not a copy"

# ── (f) research folded into the existing artifact contract ─────────
fanchor "${CAP}" "DONE_IS_ARTIFACT_ON_DISK" "capsule artifact contract preserved"
fhas "${CAP}" "The research step is inside" "research is inside the existing contract"
fhas "${CAP}" "committed" "explored context is committed as a file"
# ...and no rival principle was minted for it
rivals="$( { grep -rlF 'CONTEXT_FILE_COMMIT_STEP' "${CTX}" || true; } | wc -l | tr -d ' ')"
[[ "${rivals}" -eq 0 ]] || fail "research artifact must extend DONE_IS_ARTIFACT_ON_DISK, not mint a new anchor"

# ── (g) delegation ladder gains the measurable-signal input ─────────
fanchor "${WD}" "DELEGATION_UNIT_LADDER" "delegation ladder preserved"
fhas "${WD}" "Input 3 — a measurable signal" "third ladder input"
fhas "${WD}" "hill-climb" "the signal is something the agent can climb"
fhas "${WD}" "while I sleep" "the unattended-delegation practical test"
for i in "Input 1 — verification" "Input 2 — risk tier"; do
  fhas "${WD}" "$i" "pre-existing ladder input preserved"
done

# ── (h) doctor: info-only, exit code unchanged ──────────────────────
fhas "${HARNESS}" "gate_activity_check" "doctor gate-activity function"
grep -n 'gate_activity_check' "${HARNESS}" | grep -q 'gate_activity_check$' \
  || fail "gate_activity_check is never called"
# The function must emit only info/ok — never warn or fail, which move the rc.
body="$(awk '/^gate_activity_check\(\)/{f=1} f{print} f&&/^}/{exit}' "${HARNESS}")"
[[ -n "${body}" ]] || fail "gate_activity_check body not found"
printf '%s\n' "${body}" | grep -Eq '^[[:space:]]*(warn|fail|err)[[:space:]]' \
  && fail "gate_activity_check must not warn/fail — it would move the exit code"
printf '%s\n' "${body}" | grep -Fq 'signal-only' || fail "gate-activity signal not marked signal-only"

# rc-equality: the same project scores the same exit code whether the ledger is
# empty or full. Drives the real doctor, both directions.
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT
mkdir -p "${tmp}/.sfs-local/sprints/s1" "${tmp}/tests"
printf '# SFS\n' > "${tmp}/SFS.md"
printf '# report\n' > "${tmp}/.sfs-local/sprints/s1/report.md"
doctor_out=""   # doctor exits non-zero on advisory warnings; capture, then grep
run_doctor() { doctor_out="$( cd "$1" && bash "${HARNESS}" doctor 2>&1 )" && return 0 || return $?; }

run_doctor "${tmp}" && rc_empty=0 || rc_empty=$?
grep -Fq 'gate activity: 0/1' <<<"${doctor_out}" \
  || fail "empty-ledger fixture did not report zero gate activity"
grep -Fq 'a gate with no recorded activity is unverified' <<<"${doctor_out}" \
  || fail "empty-ledger fixture did not emit the dead-gate reading"

printf '## Deviations\n\n- plan said X, territory showed Y; conservative path taken.\n' \
  > "${tmp}/.sfs-local/sprints/s1/implement.md"
run_doctor "${tmp}" && rc_full=0 || rc_full=$?
grep -Fq '1 recorded an actual deviation' <<<"${doctor_out}" \
  || fail "populated-ledger fixture did not count the deviation"
grep -Fq 'a gate with no recorded activity is unverified' <<<"${doctor_out}" \
  && fail "dead-gate reading must disappear once the ledger has entries"
[[ "${rc_empty}" -eq "${rc_full}" ]] \
  || fail "gate-activity signal moved the exit code (${rc_empty} vs ${rc_full})"

# negative control on the fixture itself: a sprint-less tree skips, not counts
mkdir -p "${tmp}/bare/.sfs-local" && printf '# SFS\n' > "${tmp}/bare/SFS.md"
run_doctor "${tmp}/bare" || true
grep -Fq 'no sprint workbench yet' <<<"${doctor_out}" \
  || fail "sprint-less tree should skip the gate-activity signal"

# ── (i) vendor lockout, scoped to the files this WU touched ─────────
for f in "${SPC}" "${UAD}" "${CAP}" "${WD}" "${PLAN}" "${HARNESS}"; do
  for s in "Nuro" "Gusto" "Garner" "Adobe" "auto mode" "Auto mode" "10% of" "9x" "25% of"; do
    fnot "$f" "$s" "vendor lockout in $(basename "$f")"
  done
done

# ── (j) 200-line budget on every touched .md ────────────────────────
for f in "${SPC}" "${UAD}" "${CAP}" "${WD}" "${PLAN}"; do
  n="$(wc -l < "$f" | tr -d ' ')"
  [[ "$n" -le 200 ]] || fail "$(basename "$f") exceeds the 200-line budget: ${n}"
done

echo "PASS: antagonistic research pass + unattended delegation signal"
