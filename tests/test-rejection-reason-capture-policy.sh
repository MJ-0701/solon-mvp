#!/usr/bin/env bash
# BLOG-2026-08-12-1 — rejection-reason capture + the time axis of context rot.
#
# Locks four things and their boundaries:
#   * REJECTION_REASON_CAPTURE as a self-improvement-loop INVARIANT, declared in
#     exactly one file (the other two policies may only point at it) — the whole
#     risk of this delta is a second copy of the rule growing in
#     lessons-accumulation or skill-promotion-loop.
#   * STALE_CONTEXT_CANDIDATES driven through the REAL `sfs harness doctor`,
#     inside the EXISTING Context Conflict Gate section (no new subcommand),
#     info-only, exit-code invariant in both directions.
#   * SCHEDULED_RUN_CONTRACT's processed-work ledger obligation.
#   * GENERALIZATION_BEFORE_SHARING as a precondition on the promotion edit.
#
# The clean fixture must emit a POSITIVE clean-state line; asserting the absence
# of a warning would pass even if the detector never ran.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POL="${CTX}/policies"
SIL="${POL}/self-improvement-loop.md"
LES="${POL}/lessons-accumulation.md"
SPL="${POL}/skill-promotion-loop.md"
CCG="${POL}/context-conflict-gate.md"
WD="${POL}/work-delegation-and-startup.md"
SCD="${POL}/skill-catalog-discipline.md"
INDEX="${CTX}/_INDEX.md"
HARNESS="${DIST_DIR}/scripts/sfs-harness.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fanchor() { grep -Ewq -- "$2" "$1" || fail "$3: missing anchor '$2'"; }
fnot() { grep -Fq -- "$2" "$1" && fail "$3: forbidden '$2' present"; return 0; }

# ── (a) REJECTION_REASON_CAPTURE: one definition, pointers elsewhere ─
fhas "${SIL}" "**REJECTION_REASON_CAPTURE**" "the invariant is defined in the loop map"
definers=0
while IFS= read -r f; do
  grep -Fq -- '**REJECTION_REASON_CAPTURE**' "$f" && definers=$((definers + 1))
done < <(find "${CTX}" "${DIST_DIR}/docs" -name '*.md' -type f)
[[ "${definers}" -eq 1 ]] \
  || fail "REJECTION_REASON_CAPTURE must be defined once (found ${definers} defining copies)"
# ...and never as its own heading: it is an invariant of an existing list, not a
# rival section that would drift from the six it sits beside.
if grep -rEq '^#{1,6}[[:space:]]+REJECTION_REASON_CAPTURE' "${CTX}" "${DIST_DIR}/docs"; then
  fail "REJECTION_REASON_CAPTURE was promoted to a section heading (it is an invariant bullet)"
fi
# The two neighbours reference it without restating the rule.
fhas "${SPL}" "REJECTION_REASON_CAPTURE" "skill-promotion-loop points at the reason owner"
fhas "${LES}" "REJECTION_REASON_CAPTURE" "lessons-accumulation points at the reason owner"

# ── (b) the claim itself, and the invariant list grew by exactly one ─
fhas "${SIL}" "signal loss, not a decision" "a reasonless rejection is signal loss"
fhas "${SIL}" "how often" "the count half of the count/reason split"
grep -Fq "seven rules cut across" "${SIL}" \
  || fail "invariant list intro still claims six rules"
grep -Fq "six rules cut across" "${SIL}" \
  && fail "invariant list intro still claims six rules"
fhas "${SIL}" "No new" "no new file class / command"
# the six pre-existing invariants survive
for s in "suggest-only" "events.jsonl" "L-NNN" "measured-but-not-sufficient" \
         "auto-patch" "SCHEDULED_RUN_CONTRACT"; do
  fhas "${SIL}" "$s" "pre-existing invariant preserved"
done

# ── (c) stale axis: policy text ────────────────────────────────────
fanchor "${CCG}" "STALE_CONTEXT_CANDIDATES" "stale-candidate anchor"
fhas "${CCG}" "dangling routed reference" "the deterministic signal is named"
fhas "${CCG}" "info-only" "the stale axis never gates"
fhas "${CCG}" "operator input rather than a check" "the temporal axis is deliberately not automated"
fhas "${CCG}" "archive rotation, never a silent delete" "removal discipline"
# additive: the two pre-existing sections of this file survive
for a in CONFLICT_KEY_MARKER DETECTION RIGHTSIZE_CONTEXT_PASS RESOLUTION; do
  fanchor "${CCG}" "${a}" "context-conflict-gate anchor preserved"
done

# ── (d) detector wiring: existing section, no new subcommand ───────
fhas "${HARNESS}" "stale_context_check" "detector function exists"
awk '/^print_context_conflict_section\(\)/,/^}/' "${HARNESS}" \
  | grep -q 'stale_context_check' \
  || fail "stale check is not wired into the existing Context Conflict Gate section"
for sibling in conflict_marker_check rightsize_context_check; do
  awk '/^print_context_conflict_section\(\)/,/^}/' "${HARNESS}" \
    | grep -q "${sibling}" || fail "existing sibling check ${sibling} was dropped"
done
# info/ok only — the same structural lock the rightsize pass carries.
if awk '/^stale_context_check\(\)/,/^}$/' "${HARNESS}" \
   | grep -Eq '^\s*(warn|fail|partial|add_issue)[^a-z_]'; then
  fail "stale check must emit info/ok only (found a warn/fail/partial call)"
fi
# no new doctor subcommand: the usage block still lists exactly the two commands.
usage_cmds="$(awk '/^usage\(\)/,/^}/' "${HARNESS}" | grep -cE '^  sfs harness ' || true)"
[[ "${usage_cmds}" -eq 2 ]] \
  || fail "harness usage surface changed (expected 2 'sfs harness' lines, found ${usage_cmds})"

# ── (e) fixtures through the real doctor ──────────────────────────
tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/sfs-stale-ctx.XXXXXX")"
trap 'rm -rf "${tmp_root}"' EXIT

make_project() {
  local dir="$1"
  mkdir -p "${dir}"
  cd "${dir}"
  git init -q
  git config user.email "rr@solon.invalid"
  git config user.name "Solon Stale Test"
  printf '# t\n' > README.md
  git add . && git commit -qm "init"
  SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1
  mkdir -p .sfs-local/context/policies
}
run_doctor() { SFS_DIST_DIR="${DIST_DIR}" bash "${HARNESS}" doctor 2>&1 || true; }
doctor_exit() { SFS_DIST_DIR="${DIST_DIR}" bash "${HARNESS}" doctor >/dev/null 2>&1; echo "$?"; }

# e1) negative control — every cited module resolves, so a POSITIVE clean line.
make_project "${tmp_root}/fresh"
printf '# Local\nDefer to `policies/lessons-accumulation.md` for the ledger schema.\n' \
  > .sfs-local/context/policies/local.md
clean_out="$(run_doctor)"
clean_exit="$(doctor_exit)"
grep -q 'stale-context: every routed module cited by local overrides still resolves' \
  <<<"${clean_out}" || fail "clean fixture did not emit the positive clean-state line"
grep -q 'stale candidate' <<<"${clean_out}" \
  && fail "clean fixture falsely reported a stale candidate"

# e2) a citation that resolves nowhere is surfaced as a candidate.
make_project "${tmp_root}/stale"
printf '# Local\nAlways follow `policies/ghost-module.md` before shipping.\n' \
  > .sfs-local/context/policies/local.md
stale_out="$(run_doctor)"
stale_exit="$(doctor_exit)"
grep -q 'stale-context: 1 stale candidate' <<<"${stale_out}" \
  || fail "dangling routed reference not reported, got:\n${stale_out}"
grep -q 'policies/ghost-module.md' <<<"${stale_out}" \
  || fail "the stale candidate is reported without naming the dangling module"

# e3) a citation resolving against the consumer's OWN override tree is not stale.
make_project "${tmp_root}/localonly"
printf '# Local\nSee `policies/house-rule.md`.\n' > .sfs-local/context/policies/local.md
printf '# House rule\nProject-local policy.\n' > .sfs-local/context/policies/house-rule.md
grep -q 'still resolves' <<<"$(run_doctor)" \
  || fail "a module defined only in the local override tree must not read as stale"

# e4) exit-code invariance in both directions.
[[ "${clean_exit}" == "${stale_exit}" ]] \
  || fail "stale check moved doctor's exit code (${clean_exit} vs ${stale_exit})"

cd "${DIST_DIR}"

# ── (f) scheduled-run processed-work ledger ───────────────────────
fanchor "${WD}" "SCHEDULED_RUN_CONTRACT" "scheduled-run anchor preserved"
fhas "${WD}" "processed-work ledger" "the ledger obligation"
fhas "${WD}" "by construction" "dedup is structural, not prompt discipline"
fhas "${WD}" "design finding" "a ledgerless recurring job is a finding"
for s in "Every fire is a fresh session" "Four operational controls exist" \
         "Credentials by indirection only" "Periodic schedule audit"; do
  fhas "${WD}" "$s" "pre-existing SCHEDULED_RUN_CONTRACT item preserved"
done

# ── (g) generalization pass at promotion time ─────────────────────
fanchor "${SCD}" "GENERALIZATION_BEFORE_SHARING" "generalization anchor"
owners=0
while IFS= read -r f; do
  grep -Eq '^#{1,6}[[:space:]]+GENERALIZATION_BEFORE_SHARING' "$f" && owners=$((owners + 1))
done < <(find "${CTX}" "${DIST_DIR}/docs" -name '*.md' -type f)
[[ "${owners}" -eq 1 ]] || fail "GENERALIZATION_BEFORE_SHARING must be defined once (found ${owners})"
fhas "${SCD}" "the promotion is" "the hold branch exists"
fhas "${SCD}" "held" "an unparameterizable particular holds the promotion"
fhas "${SCD}" "SETUP_VIA_PLACEHOLDER" "reuses the existing placeholder mechanism"
fhas "${SCD}" "not a new gate" "adds a precondition, not a rival gate"
fhas "${SPL}" "GENERALIZATION_BEFORE_SHARING" "promotion rail points at the precondition"
fanchor "${SCD}" "SHADOW_MODE_TRUST_LADDER" "catalog anchor preserved"
fanchor "${SCD}" "VERSIONED_EXTENSION_SURFACE" "catalog anchor preserved"

# ── (h) vendor lockout, scoped to the touched files ───────────────
for f in "${SIL}" "${LES}" "${SPL}" "${CCG}" "${WD}" "${SCD}"; do
  for s in "Salesforce" "HubSpot" "Gong" "Outreach.io" "BDR" "CRM" \
           "inbound and outbound" "business development" "pipeline generation" \
           "call coaching" "sales team"; do
    fnot "$f" "$s" "vendor/use-case lockout in $(basename "$f")"
  done
  if grep -Eq '[0-9]+x (more|faster|pipeline)|[0-9]+% (more|of) (meetings|replies)' "$f"; then
    fail "$(basename "$f"): a source performance figure leaked"
  fi
done

# ── (i) routed index ──────────────────────────────────────────────
for a in REJECTION_REASON_CAPTURE STALE_CONTEXT_CANDIDATES GENERALIZATION_BEFORE_SHARING; do
  fanchor "${INDEX}" "${a}" "index route"
done
fhas "${INDEX}" "processed-work ledger" "index routes the scheduled-run ledger duty"

# ── (j) line budgets ──────────────────────────────────────────────
for f in "${SIL}" "${LES}" "${SPL}" "${CCG}" "${WD}" "${SCD}" "${INDEX}"; do
  n="$(wc -l < "$f" | tr -d '[:space:]')"
  [[ "${n}" -le 200 ]] || fail "$(basename "$f") exceeds the 200-line budget: ${n}"
done

echo "PASS: rejection-reason capture + stale context candidates locked"
