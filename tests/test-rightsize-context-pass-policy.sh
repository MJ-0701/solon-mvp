#!/usr/bin/env bash
# BLOG-2026-07-24-3 — overconstraint as a defect: rightsize pass + rule vs guardrail.
#
# Locks RIGHTSIZE_CONTEXT_PASS (info-only redundant-guidance + narrative-absolute
# scan, run inside the existing Context Conflict Gate doctor section rather than
# as a new subcommand), RULE_VS_GUARDRAIL (inviolable gate never trimmed vs
# narrative advisory as a trim candidate, discriminated by what one violation
# costs), REFERENCE_FIDELITY_LADDER, and the deferred-loading rationale.
#
# The detector is driven through the REAL `sfs harness doctor` on synthetic
# fixtures, including a negative control: a clean install must NOT report
# redundancy, and the pass must never move doctor's exit code.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POL="${CTX}/policies"
CCG="${POL}/context-conflict-gate.md"
SST="${POL}/steering-surface-taxonomy.md"
UAD="${POL}/unknowns-and-deviations.md"
M7="${DIST_DIR}/docs/maintenance/methodology-7-step.md"
INDEX="${CTX}/_INDEX.md"
HARNESS="${DIST_DIR}/scripts/sfs-harness.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
kfhas() { LC_ALL=C grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fanchor() { grep -Ewq -- "$2" "$1" || fail "$3: missing anchor '$2'"; }

# ── (a) anchors ─────────────────────────────────────────────────────
fanchor "${CCG}" "RIGHTSIZE_CONTEXT_PASS" "rightsize pass anchor"
fanchor "${SST}" "RULE_VS_GUARDRAIL" "rule-vs-guardrail anchor"
fanchor "${UAD}" "REFERENCE_FIDELITY_LADDER" "reference fidelity anchor"

# ── (b) the diagnostic claim, and that it is a lens not a mechanism ─
fhas "${CCG}" "overconstraint is itself a defect" "the diagnostic claim"
fhas "${CCG}" "the delta is the diagnostic lens" "lens, not a second disclosure mechanism"
fhas "${CCG}" "redundant guidance" "signal 1"
fhas "${CCG}" "narrative absolutes" "signal 2"
fhas "${CCG}" "info-only" "signals never gate"
fhas "${CCG}" "Frontmatter is excluded" "frontmatter exclusion documented"
fhas "${CCG}" "Trimming is never automatic" "operator owns the trim"

# ── (c) inviolable gates are preserved, not trimmed ─────────────────
fhas "${SST}" "Inviolable gate" "inviolable class named"
fhas "${SST}" "never**" "inviolable is never trimmed"
fhas "${SST}" "rules-as-tests" "deterministic locks named as inviolable"
fhas "${SST}" "happens on one violation" "the discriminating question"
fhas "${SST}" "trim candidate" "advisory class is the trim candidate"
fhas "${SST}" "labelling is not" "labelling != deletion"
fhas "${SST}" "RIGHTSIZE_CONTEXT_PASS" "points at the surfacing pass"
fhas "${CCG}" "RULE_VS_GUARDRAIL" "pass points at the classification rule"

# ── (d) fidelity ladder + deferred-loading rationale ────────────────
fhas "${UAD}" "artifact that behaves" "ladder rung 1"
fhas "${UAD}" "frozen depiction" "ladder rung 2"
fhas "${UAD}" "description in prose" "ladder rung 3"
fhas "${UAD}" "rubric" "rubric as the quality rung"
fhas "${UAD}" "no new field" "additive-only, no schema change"
kfhas "${M7}" "deferred loading" "deferred-loading rationale recorded"
kfhas "${M7}" "RIGHTSIZE_CONTEXT_PASS" "methodology points at the pass"
fanchor "${M7}" "ARTIFACT_FITS_IN_HEAD" "shared decomposition root named"

# ── (e) routed index ────────────────────────────────────────────────
for a in RIGHTSIZE_CONTEXT_PASS RULE_VS_GUARDRAIL REFERENCE_FIDELITY_LADDER; do
  fanchor "${INDEX}" "${a}" "index route"
done

# ── (f) additive guarantee ──────────────────────────────────────────
fanchor "${CCG}" "CONFLICT_KEY_MARKER" "conflict-gate anchor preserved"
fanchor "${CCG}" "DETECTION" "conflict-gate anchor preserved"
fanchor "${CCG}" "RESOLUTION" "conflict-gate anchor preserved"
fanchor "${SST}" "FOUR_AXES" "steering anchor preserved"
fanchor "${SST}" "PLACEMENT_RULES" "steering anchor preserved"
fanchor "${SST}" "DECISION_TABLE" "steering anchor preserved"
fanchor "${UAD}" "REFERENCES_FIELD" "unknowns anchor preserved"
fanchor "${UAD}" "PROTOTYPE_FORK" "unknowns anchor preserved"

# ── (g) the pass extends the existing section, no new subcommand ────
fhas "${HARNESS}" "rightsize_context_check" "detector function exists"
fhas "${HARNESS}" "conflict_marker_check" "existing marker check kept as a sibling"
awk '/^print_context_conflict_section\(\)/,/^}/' "${HARNESS}" \
  | grep -q 'rightsize_context_check' \
  || fail "rightsize pass is not wired into the existing Context Conflict Gate section"
grep -Eq '^\s*(warn|add_issue)[^a-z_]' <(awk '/^rightsize_context_check\(\)/,/^}$/' "${HARNESS}") \
  && fail "rightsize pass must emit info/ok only (found warn/add_issue)"

# ── (h) fixtures through the real doctor ────────────────────────────
tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/sfs-rightsize.XXXXXX")"
trap 'rm -rf "${tmp_root}"' EXIT

make_project() {
  local dir="$1"
  mkdir -p "${dir}"
  cd "${dir}"
  git init -q
  git config user.email "rs@solon.invalid"
  git config user.name "Solon Rightsize Test"
  printf '# t\n' > README.md
  git add . && git commit -qm "init"
  SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1
}
run_doctor() {
  SFS_DIST_DIR="${DIST_DIR}" bash "${HARNESS}" doctor 2>&1 || true
}
doctor_exit() {
  SFS_DIST_DIR="${DIST_DIR}" bash "${HARNESS}" doctor >/dev/null 2>&1
  echo "$?"
}

# h1) negative control — a clean install must not report redundancy.
make_project "${tmp_root}/clean"
clean_out="$(run_doctor)"
clean_exit="$(doctor_exit)"
printf '%s' "${clean_out}" | grep -q 'rightsize-context: no standing directive restated' \
  || fail "clean install falsely reports redundant guidance (frontmatter/boilerplate leak)"

# h2) a genuine restatement across two surfaces is reported.
make_project "${tmp_root}/dup"
mkdir -p .sfs-local/context/policies
printf '# A\n- You must always run the full test suite before shipping anything.\n' \
  > .sfs-local/context/policies/a.md
printf -- '- You must always run the full test suite before shipping anything.\n' >> CLAUDE.md
dup_out="$(run_doctor)"
dup_exit="$(doctor_exit)"
printf '%s' "${dup_out}" | grep -q 'restated across 2+ agent-visible surfaces' \
  || fail "restated directive not reported as redundant guidance"
printf '%s' "${dup_out}" | grep -q 'narrative always/never line' \
  || fail "narrative-absolute count not reported"

# h3) formatting difference must not defeat the match (normalization works).
make_project "${tmp_root}/fmt"
mkdir -p .sfs-local/context/policies
printf '# A\n- You must **always** run the full test suite before shipping anything!\n' \
  > .sfs-local/context/policies/a.md
printf -- '* you must always run the full test suite before shipping anything\n' >> CLAUDE.md
printf '%s' "$(run_doctor)" | grep -q 'restated across 2+ agent-visible surfaces' \
  || fail "normalization failed: same directive with different formatting not matched"

# h4) the pass is exit-code neutral.
[[ "${clean_exit}" == "${dup_exit}" ]] \
  || fail "rightsize pass changed doctor's exit code (${clean_exit} vs ${dup_exit})"

cd "${DIST_DIR}"

# ── (i) vendor lockout ──────────────────────────────────────────────
for f in "${POL}"/*.md "${CTX}"/commands/*.md "${CTX}"/kernel.md "${INDEX}"; do
  if grep -Eiq 'thariq|claude doctor' "${f}"; then
    fail "$(basename "${f}"): vendor tooling name or author name leaked"
  fi
done
for f in "${CCG}" "${SST}" "${UAD}"; do
  if grep -Eq '80%|8[05] percent' "${f}"; then
    fail "$(basename "${f}"): removal figure leaked"
  fi
done

# ── (j) line budget ─────────────────────────────────────────────────
for f in "${CCG}" "${SST}" "${UAD}" "${M7}" "${INDEX}"; do
  lines="$(wc -l < "${f}" | tr -d '[:space:]')"
  [[ "${lines}" -le 200 ]] || fail "$(basename "${f}") exceeds 200-line budget (${lines})"
done

echo "PASS: rightsize context pass + rule-vs-guardrail locked"
