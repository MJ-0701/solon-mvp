#!/usr/bin/env bash
# Multi-agent team topology — R5 upgrade-time auto-offer + 1-time memory.
#
# 0.8.49 headline lock (eval-first). The user's #1 ask: surface activation
# without the user knowing any command. On `sfs upgrade`, when the project is
# solo AND the environment can actually run a team, offer a one-line [Y/n].
# Remember the decision so we don't nag every upgrade; re-offer once if the
# environment goes incapable→capable. Never force: non-interactive / no-consent
# / incapable = solo, byte-for-byte.
#
#   T4 (R5b/R5c): capable + solo + undecided → interactive upgrade prints the
#                 [Y/n] offer; decline is recorded; a second upgrade at the same
#                 capability does NOT re-offer; an incapable→capable transition
#                 re-offers once.
#   T5 (R5d): --yes (non-interactive) capable upgrade shows no prompt and is
#             byte-for-byte no-op on model-profiles.yaml, writes no state, and
#             injects no team_dispatch (standalone lock). Incapable interactive
#             upgrade shows no prompt either.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
UPGRADE="${DIST_DIR}/upgrade.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
[[ -f "${SFS_BIN}" ]] || fail "bin/sfs not found"
[[ -f "${UPGRADE}" ]] || fail "upgrade.sh not found"

TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/sfs-team-offer.XXXXXX")"
cleanup() { rm -rf "${TMP_ROOT}"; }
trap cleanup EXIT

mp_of()      { echo "$1/.sfs-local/model-profiles.yaml"; }
state_of()   { echo "$1/.sfs-local/team_offer_state"; }
offer_count(){ grep -c '적용? \[Y/n\]' "$1" 2>/dev/null || true; }

init_project() {
  local dir="$1"
  ( cd "${dir}" \
    && git init -q && git config user.email offer@solon.invalid \
    && git config user.name "Solon Offer Test" \
    && printf '# offer\n' > README.md && git add . && git commit -qm init ) >/dev/null 2>&1
  ( cd "${dir}" \
    && SFS_DIST_DIR="${DIST_DIR}" SFS_INSTALL_LLM_WIKI=0 SFS_SKIP_CLI_DISCOVERY=1 \
       bash "${SFS_BIN}" init --layout thin --yes ) >"${dir}/init.log" 2>&1 </dev/null \
    || fail "init failed (see ${dir}/init.log)"
}

# Interactive upgrade (NO --yes) with deterministic capability + a stdin answer.
# FC_* override capability (default all capable). $2 = stdin answer (e.g. n).
upgrade_tty() {
  local dir="$1" answer="${2:-n}" logname="${3:-up}"
  printf '%s\n' "${answer}" | ( cd "${dir}" \
    && SFS_DIST_DIR="${DIST_DIR}" SFS_SKIP_SELF_UPGRADE=1 SFS_SKIP_CLI_DISCOVERY=1 \
       SFS_MODEL_PROFILE_PROMPT=0 SFS_INSTALL_LLM_WIKI=0 \
       SFS_TEAM_FORCE_CAPABLE_CLAUDE="${FC_CLAUDE:-1}" \
       SFS_TEAM_FORCE_CAPABLE_CODEX="${FC_CODEX:-1}" \
       SFS_TEAM_FORCE_CAPABLE_ANTIGRAVITY="${FC_AGY:-1}" \
       SFS_TEAM_FORCE_CAPABLE_GEMINI="${FC_GEMINI:-1}" \
       bash "${UPGRADE}" ) >"${dir}/${logname}.log" 2>&1
}

# Non-interactive upgrade (--yes).
upgrade_yes() {
  local dir="$1" logname="${2:-upy}"
  ( cd "${dir}" \
    && SFS_DIST_DIR="${DIST_DIR}" SFS_SKIP_SELF_UPGRADE=1 SFS_SKIP_CLI_DISCOVERY=1 \
       SFS_MODEL_PROFILE_PROMPT=0 SFS_INSTALL_LLM_WIKI=0 \
       SFS_TEAM_FORCE_CAPABLE_CLAUDE="${FC_CLAUDE:-1}" \
       SFS_TEAM_FORCE_CAPABLE_CODEX="${FC_CODEX:-1}" \
       SFS_TEAM_FORCE_CAPABLE_ANTIGRAVITY="${FC_AGY:-1}" \
       SFS_TEAM_FORCE_CAPABLE_GEMINI="${FC_GEMINI:-1}" \
       bash "${UPGRADE}" --yes ) >"${dir}/${logname}.log" 2>&1 </dev/null
}

# ── T4 (R5b/R5c): offer → decline → no re-offer → transition re-offer ───────
T4="${TMP_ROOT}/t4"; mkdir -p "${T4}"; init_project "${T4}"
[[ "$(awk '/^team_preset:/{print $2;exit}' "$(mp_of "${T4}")")" == "solo" ]] || fail "T4: fresh init not solo"
# capable + undecided → offer shown; decline.
upgrade_tty "${T4}" n up1 || fail "T4: interactive upgrade #1 failed (see ${T4}/up1.log)"
[[ "$(offer_count "${T4}/up1.log")" -ge 1 ]] || fail "T4: capable+undecided did not surface the [Y/n] offer"
[[ -f "$(state_of "${T4}")" ]] || fail "T4: decline did not record team_offer_state"
grep -q '^decision=declined' "$(state_of "${T4}")" || fail "T4: state not 'declined'"
# same capability → no re-offer (no nag).
upgrade_tty "${T4}" n up2 || fail "T4: interactive upgrade #2 failed"
[[ "$(offer_count "${T4}/up2.log")" -eq 0 ]] || fail "T4: re-offered at unchanged capability (nag)"
# incapable→capable transition → re-offer once. Simulate decline at a lower fp.
printf 'decision=declined\ncapability_fp=claude,codex\n' > "$(state_of "${T4}")"
upgrade_tty "${T4}" n up3 || fail "T4: interactive upgrade #3 failed"
[[ "$(offer_count "${T4}/up3.log")" -ge 1 ]] || fail "T4: did not re-offer after incapable→capable transition"

# ── T5 (R5d): --yes byte-for-byte no-op + standalone lock; incapable silent ──
T5="${TMP_ROOT}/t5"; mkdir -p "${T5}"; init_project "${T5}"
MP5="$(mp_of "${T5}")"
before="$(shasum "${MP5}" | awk '{print $1}')"
upgrade_yes "${T5}" upy || fail "T5: --yes upgrade failed (see ${T5}/upy.log)"
after="$(shasum "${MP5}" | awk '{print $1}')"
[[ "${before}" == "${after}" ]] || fail "T5: capable --yes upgrade mutated model-profiles.yaml (not byte-for-byte)"
[[ "$(offer_count "${T5}/upy.log")" -eq 0 ]] || fail "T5: --yes upgrade prompted (must never prompt)"
[[ ! -f "$(state_of "${T5}")" ]] || fail "T5: --yes upgrade wrote offer state (must not)"
for a in CLAUDE.md AGENTS.md GEMINI.md; do
  [[ -f "${T5}/${a}" ]] && { ! grep -q '^team_dispatch:' "${T5}/${a}" || fail "T5: ${a} got team_dispatch on --yes solo upgrade (standalone lock broken)"; }
done
# incapable interactive upgrade → no prompt, no state, no mutation.
T5I="${TMP_ROOT}/t5-incap"; mkdir -p "${T5I}"; init_project "${T5I}"
MP5I="$(mp_of "${T5I}")"
b2="$(shasum "${MP5I}" | awk '{print $1}')"
FC_CODEX=0 upgrade_tty "${T5I}" Y upinc || fail "T5: incapable interactive upgrade failed"
[[ "$(offer_count "${T5I}/upinc.log")" -eq 0 ]] || fail "T5: offered despite incapable environment"
[[ ! -f "$(state_of "${T5I}")" ]] || fail "T5: incapable upgrade wrote offer state"
[[ "$(shasum "${MP5I}" | awk '{print $1}')" == "${b2}" ]] || fail "T5: incapable upgrade mutated model-profiles.yaml"

echo "test-team-auto-offer: OK"
