#!/usr/bin/env bash
# BLOG-2026-08-08-1 — approval fatigue and the hard-deny layer.
#
# Locks two delta anchors and one waiver rule: APPROVAL_FATIGUE_DECAY (a
# per-step human approval gate's detection power falls as the session runs, so
# human consent is not the safety argument that keeps a standing rule in a
# prompt — the quantitative twin of INVARIANT_LIVES_IN_HARNESS, stated in the
# same bullet), NEVER_APPROVE_CLASS (the third layer above judge/allow: classes
# never routed to discretion, declared on a config data surface, not unlockable
# by a user request, and carrying OUTBOUND_COMMUNICATION_NEVER_AUTO), and the
# audit rule that a blanket waiver is gate removal rather than an exception.
#
# Also locks single-SSoT ownership (NEVER_APPROVE_CLASS is defined in exactly
# one file; everyone else points), preservation of the pre-existing anchors the
# new prose is woven into, the 200-line budget of every touched .md, and a
# vendor lockout: product mode names and the source's study/threshold figures
# must not appear in product prose.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POL="${CTX}/policies"
HA="${POL}/harness-autonomy.md"
CRED="${POL}/credential-hygiene.md"
AUDIT="${CTX}/commands/audit.md"
M7="${DIST_DIR}/docs/maintenance/methodology-7-step.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fhasu() { LC_ALL=C grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fanchor() { grep -Ewq -- "$2" "$1" || fail "$3: missing anchor '$2'"; }
fnot() { grep -Fq -- "$2" "$1" && fail "$3: forbidden '$2' present"; return 0; }

# ── (a) anchors in their owning files ───────────────────────────────
fanchor "${HA}" "APPROVAL_FATIGUE_DECAY" "approval-fatigue anchor"
fanchor "${CRED}" "NEVER_APPROVE_CLASS" "never-approve-class anchor"
fanchor "${CRED}" "OUTBOUND_COMMUNICATION_NEVER_AUTO" "outbound-communication anchor"

# ── (b) APPROVAL_FATIGUE_DECAY substance, not just the name ─────────
fhas "${HA}" "fewer the longer the session" "session-length decay stated"
fhas "${HA}" "always-on classifier layer holds its rate" "classifier-layer contrast"
fhas "${HA}" "not the safety argument" "the discarded assumption named"
fhas "${HA}" "NEVER_APPROVE_CLASS" "cross-ref to the hard-deny owner"

# The anchor must be the *quantitative twin* of the existing one, in the same
# bullet — not a free-floating restatement elsewhere in the file.
awk '/INVARIANT_LIVES_IN_HARNESS/{f=1} f&&/APPROVAL_FATIGUE_DECAY/{found=1} /^- [A-Z]/&&!/INVARIANT_LIVES_IN_HARNESS/&&f&&!found{f=0} END{exit !found}' \
  "${HA}" || fail "APPROVAL_FATIGUE_DECAY not stated inside the INVARIANT_LIVES_IN_HARNESS bullet"
fhas "${HA}" "quantitative twin" "twin relationship named"

# ── (c) NEVER_APPROVE_CLASS substance ───────────────────────────────
fhas "${CRED}" "three layers, not one" "the three-layer split"
fhas "${CRED}" "never routed to discretion" "the discretion carve-out"
fhas "${CRED}" "config data surface" "declared as data, not remembered"
fhas "${CRED}" "does not unlock the class" "not user-overridable"
fhas "${CRED}" "credential or source exfiltration" "member 1"
fhas "${CRED}" "to a person that leaves the machine" "member 2"
fhas "${CRED}" "APPROVAL_FATIGUE_DECAY" "back-reference to the fatigue anchor"

# ── (d) single SSoT: defined once, referenced elsewhere ─────────────
owners=0
while IFS= read -r f; do
  # a *definition* is a heading; a mention in prose is a pointer
  grep -Eq '^#{1,6}[[:space:]]+NEVER_APPROVE_CLASS[[:space:]]*$' "$f" && owners=$((owners + 1))
done < <(find "${CTX}" "${DIST_DIR}/docs" -name '*.md' -type f)
[[ "${owners}" -eq 1 ]] || fail "NEVER_APPROVE_CLASS must be defined in exactly one file (found ${owners})"
grep -Eq '^#{1,6}[[:space:]]+NEVER_APPROVE_CLASS[[:space:]]*$' "${CRED}" \
  || fail "NEVER_APPROVE_CLASS owner must be credential-hygiene.md"

# OUTBOUND_COMMUNICATION_NEVER_AUTO is a *member* of that class, not a rival anchor.
# So: it must never get a heading of its own anywhere, and its substantive statement
# must sit inside the NEVER_APPROVE_CLASS section. `_INDEX.md` naming it is routing,
# which is required elsewhere in this suite — not a second SSoT.
while IFS= read -r f; do
  grep -Eq '^#{1,6}[[:space:]]+OUTBOUND_COMMUNICATION_NEVER_AUTO' "$f" \
    && fail "OUTBOUND_COMMUNICATION_NEVER_AUTO is a member of NEVER_APPROVE_CLASS, not its own anchor (heading in ${f#${DIST_DIR}/})"
done < <(find "${CTX}" "${DIST_DIR}/docs" -name '*.md' -type f)

nac_sect="$(awk '/^## NEVER_APPROVE_CLASS/{f=1;next} f&&/^## /{exit} f' "${CRED}")"
[[ -n "${nac_sect}" ]] || fail "NEVER_APPROVE_CLASS section is empty"
printf '%s\n' "${nac_sect}" | grep -Fq 'OUTBOUND_COMMUNICATION_NEVER_AUTO' \
  || fail "OUTBOUND_COMMUNICATION_NEVER_AUTO must be stated inside the NEVER_APPROVE_CLASS section"

# No policy file other than the owner may state it (the routing index may name it).
while IFS= read -r f; do
  [[ "$f" == "${CRED}" ]] && continue
  grep -Fq 'OUTBOUND_COMMUNICATION_NEVER_AUTO' "$f" \
    && fail "rival statement of OUTBOUND_COMMUNICATION_NEVER_AUTO in ${f#${DIST_DIR}/}"
done < <(find "${CTX}/policies" "${CTX}/commands" -name '*.md' -type f)

# ── (e) blanket waiver = gate removal (audit.md) ────────────────────
fhasu "${AUDIT}" "광역 waiver 는 예외가 아니라 게이트 폐지다" "audit blanket-waiver rule"
fhasu "${AUDIT}" "NEVER_APPROVE_CLASS" "audit points at the hard-deny owner"
fhasu "${AUDIT}" "waiver 대상이 아니다" "hard-deny class is not waivable"

# ── (f) methodology pointer, by-reference only (no policy body) ─────
fhasu "${M7}" "APPROVAL_FATIGUE_DECAY" "methodology pointer to the fatigue anchor"
fhasu "${M7}" "여기서 재나열하지 않는다" "methodology stays a pointer, not a copy"

# ── (g) pre-existing anchors preserved (additive, not a rewrite) ────
for a in PROMPTS_ARE_SUGGESTIONS INVARIANT_LIVES_IN_HARNESS BOUNDS_OUTLIVE_MODEL_LIMITS \
         FIX_THE_LOOP_NOT_THE_CODE PRE_WORK_INVARIANT_DECLARATION SPEC_IS_THE_ARTIFACT \
         CONTROL_LOGIC_AS_DATA JUDGE_NEGATIVE_CONTROL; do
  fanchor "${HA}" "${a}" "preserved harness-autonomy anchor"
done
for a in PLACEHOLDER_ONLY_SURFACES BOUNDARY_ATTACHMENT AGENT_IDENTITY GRANT_LIFECYCLE \
         ROTATION_SINGLE_POINT FOUR_QUESTION_RISK_PREFLIGHT INGRESS_TRUST_CHECKPOINT; do
  fanchor "${CRED}" "${a}" "preserved credential-hygiene anchor"
done
fhasu "${AUDIT}" "VULNERABILITY_CLASS_CLOSED_LOOP" "preserved audit anchor"
fhasu "${AUDIT}" "FIX_THE_LOOP_NOT_THE_CODE" "preserved audit upstream-fix pointer"

# ── (h) vendor lockout, scoped to the files this WU touched ─────────
for f in "${HA}" "${CRED}" "${AUDIT}" "${M7}"; do
  for s in "auto mode" "Auto mode" "13.6%" "89%" "1,053" "Pro, Max" "Max plan" \
           "Bash(python"; do
    fnot "$f" "$s" "vendor/product lockout in $(basename "$f")"
  done
done

# ── (i) 200-line budget on every touched .md ────────────────────────
for f in "${HA}" "${CRED}" "${AUDIT}" "${M7}"; do
  n="$(wc -l < "$f" | tr -d ' ')"
  # 199 is the effective ceiling: existing locks assert `-lt 200`, not `-le 200`.
  [[ "$n" -lt 200 ]] || fail "$(basename "$f") exceeds the 200-line budget: ${n}"
done

echo "PASS: approval-fatigue decay + never-approve class policy"
