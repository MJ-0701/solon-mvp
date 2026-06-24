#!/usr/bin/env bash
# Multi-agent team topology — R2 deprecated-fallback → canonical auto-promotion.
#
# 0.8.52 headline lock (eval-first). 0.8.49/0.8.50 removed the "must know the
# command/YAML" anti-pattern for activation. But a project that fell back to the
# gemini deprecated runtime (because antigravity/`agy` was absent at activation
# time) had NO product-level path back to canonical after agy was installed:
# re-running `sfs team use trio` hit the 3-way guard's "custom bindings 보존"
# skip, so the user had to hand-edit model-profiles.yaml — the exact anti-pattern
# 0.8.49 killed. 0.8.52 makes the guard 4-way: a fallback-MARKED binding whose
# canonical is now capable is detected → offered → (one consent) → that one line
# promoted. User-chosen bindings (no marker) are never touched.
#
#   T1 (R1+R2): fallback-marked researcher=gemini + agy now capable →
#               `sfs team use trio` re-run promotes researcher→antigravity and
#               strips the marker (one consent via SFS_TEAM_PROMOTE_YES).
#   T2 (R3):    user-custom researcher=gemini (NO marker) → no offer, no change
#               (preservation), even with agy capable + promote-yes.
#   T3:         agy absent → fallback kept, `sfs team refresh` = no change, no crash.
#   T4 (R5):    agy installed but UNAUTHED → not promoted (auth-ready unmet);
#               once authed (SFS_ANTIGRAVITY_AUTH_READY=1) → promoted.
#   T5 (R4):    non-interactive without --yes = byte-for-byte no change; and
#               `sfs upgrade --yes` on a fallback project never force-promotes.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
UPGRADE="${DIST_DIR}/upgrade.sh"
RESOLVER="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-team.sh"
APPLY="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-team-apply.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
[[ -f "${SFS_BIN}" ]]  || fail "bin/sfs not found"
[[ -f "${APPLY}" ]]    || fail "sfs-team-apply.sh (shared core) not found"
[[ -f "${RESOLVER}" ]] || fail "resolver not found"

TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/sfs-team-promote.XXXXXX")"
cleanup() { rm -rf "${TMP_ROOT}"; }
trap cleanup EXIT

mp_of()   { echo "$1/.sfs-local/model-profiles.yaml"; }
resolve() { SFS_MODEL_PROFILES="$1" bash "${RESOLVER}" resolve-runtime "$2"; }
sha()     { shasum "$1" | awk '{print $1}'; }

init_project() {
  local dir="$1"
  ( cd "${dir}" \
    && git init -q \
    && git config user.email promote@solon.invalid \
    && git config user.name "Solon Promote Test" \
    && printf '# promote\n' > README.md \
    && git add . && git commit -qm init ) >/dev/null 2>&1
  ( cd "${dir}" \
    && SFS_DIST_DIR="${DIST_DIR}" SFS_INSTALL_LLM_WIKI=0 SFS_SKIP_CLI_DISCOVERY=1 \
       bash "${SFS_BIN}" init --layout thin --yes ) >"${dir}/init.log" 2>&1 </dev/null \
    || fail "init failed (see ${dir}/init.log)"
}

# Seed a fallback state: activate trio with agy INCAPABLE + gemini capable so
# researcher falls back to gemini and gets the `# sfs-fallback: antigravity` marker.
seed_fallback() {
  local dir="$1"
  ( cd "${dir}" \
    && SFS_DIST_DIR="${DIST_DIR}" SFS_SKIP_SELF_UPGRADE=1 SFS_SKIP_CLI_DISCOVERY=1 \
       SFS_TEAM_FORCE_CAPABLE_CLAUDE=1 SFS_TEAM_FORCE_CAPABLE_CODEX=1 \
       SFS_TEAM_FORCE_CAPABLE_ANTIGRAVITY=0 SFS_TEAM_FORCE_CAPABLE_GEMINI=1 \
       bash "${SFS_BIN}" team use trio ) >"${dir}/seed.log" 2>&1 </dev/null \
    || fail "seed: team use trio failed (see ${dir}/seed.log)"
}

# ── T1 (R1+R2): marked fallback + agy capable → promote on `team use` re-run ──
T1="${TMP_ROOT}/t1"; mkdir -p "${T1}"; init_project "${T1}"; seed_fallback "${T1}"
MP1="$(mp_of "${T1}")"
[[ "$(resolve "${MP1}" researcher)" == "gemini" ]] || fail "T1 seed: researcher not gemini fallback"
grep -q '# sfs-fallback: antigravity' "${MP1}" || fail "T1 seed: fallback marker not written (R1)"
( cd "${T1}" \
  && SFS_DIST_DIR="${DIST_DIR}" SFS_SKIP_SELF_UPGRADE=1 SFS_SKIP_CLI_DISCOVERY=1 \
     SFS_TEAM_FORCE_CAPABLE_CLAUDE=1 SFS_TEAM_FORCE_CAPABLE_CODEX=1 \
     SFS_TEAM_FORCE_CAPABLE_ANTIGRAVITY=1 SFS_TEAM_FORCE_CAPABLE_GEMINI=1 \
     SFS_TEAM_PROMOTE_YES=1 \
     bash "${SFS_BIN}" team use trio ) >"${T1}/promote.log" 2>&1 </dev/null \
  || fail "T1: team use trio (promote) failed (see ${T1}/promote.log)"
[[ "$(resolve "${MP1}" researcher)" == "antigravity" ]] || fail "T1: researcher not promoted to antigravity (got '$(resolve "${MP1}" researcher)')"
grep -q '# sfs-fallback:' "${MP1}" && fail "T1: marker not stripped after promotion"
[[ "$(resolve "${MP1}" worker)" == "codex" ]] || fail "T1: worker binding disturbed by promotion"

# ── T2 (R3): user-custom gemini (NO marker) → never touched ──────────────────
T2="${TMP_ROOT}/t2"; mkdir -p "${T2}"; init_project "${T2}"; seed_fallback "${T2}"
MP2="$(mp_of "${T2}")"
# Strip the marker to simulate a deliberate user choice of gemini.
if [ "$(uname)" = "Darwin" ]; then sed -i '' 's/[[:space:]]*# sfs-fallback:.*$//' "${MP2}"; else sed -i 's/[[:space:]]*# sfs-fallback:.*$//' "${MP2}"; fi
grep -q '# sfs-fallback:' "${MP2}" && fail "T2 setup: marker not stripped"
[[ "$(resolve "${MP2}" researcher)" == "gemini" ]] || fail "T2 setup: researcher not gemini"
before2="$(sha "${MP2}")"
( cd "${T2}" \
  && SFS_DIST_DIR="${DIST_DIR}" SFS_SKIP_SELF_UPGRADE=1 SFS_SKIP_CLI_DISCOVERY=1 \
     SFS_TEAM_FORCE_CAPABLE_CLAUDE=1 SFS_TEAM_FORCE_CAPABLE_CODEX=1 \
     SFS_TEAM_FORCE_CAPABLE_ANTIGRAVITY=1 SFS_TEAM_FORCE_CAPABLE_GEMINI=1 \
     SFS_TEAM_PROMOTE_YES=1 \
     bash "${SFS_BIN}" team use trio ) >"${T2}/use.log" 2>&1 </dev/null \
  || fail "T2: team use trio failed (see ${T2}/use.log)"
[[ "$(resolve "${MP2}" researcher)" == "gemini" ]] || fail "T2: user-custom gemini was clobbered (preservation broken)"
[[ "$(sha "${MP2}")" == "${before2}" ]] || fail "T2: user-custom bindings mutated"
grep -q '보존' "${T2}/use.log" || fail "T2: no preservation notice emitted"

# ── T3: agy absent → refresh = no change, no crash ───────────────────────────
T3="${TMP_ROOT}/t3"; mkdir -p "${T3}"; init_project "${T3}"; seed_fallback "${T3}"
MP3="$(mp_of "${T3}")"
before3="$(sha "${MP3}")"
( cd "${T3}" \
  && SFS_DIST_DIR="${DIST_DIR}" SFS_SKIP_SELF_UPGRADE=1 SFS_SKIP_CLI_DISCOVERY=1 \
     SFS_TEAM_FORCE_CAPABLE_ANTIGRAVITY=0 SFS_TEAM_FORCE_CAPABLE_GEMINI=1 \
     SFS_TEAM_PROMOTE_YES=1 \
     bash "${SFS_BIN}" team refresh --yes ) >"${T3}/refresh.log" 2>&1 </dev/null \
  || fail "T3: team refresh crashed/non-zero (see ${T3}/refresh.log)"
[[ "$(resolve "${MP3}" researcher)" == "gemini" ]] || fail "T3: fallback not kept while agy incapable"
[[ "$(sha "${MP3}")" == "${before3}" ]] || fail "T3: refresh mutated profile despite incapable canonical"

# ── T4 (R5): agy installed but UNAUTHED → not promoted until authed ──────────
T4="${TMP_ROOT}/t4"; mkdir -p "${T4}"; init_project "${T4}"; seed_fallback "${T4}"
MP4="$(mp_of "${T4}")"
# Stub `agy` on PATH so `command -v agy` succeeds, but provide NO Google creds.
STUB="${T4}/stubbin"; mkdir -p "${STUB}"
printf '#!/usr/bin/env bash\nexit 0\n' > "${STUB}/agy"; chmod +x "${STUB}/agy"
# No FORCE override for antigravity → the real R5 probe runs. Unauthed → incapable.
( cd "${T4}" \
  && PATH="${STUB}:${PATH}" \
     SFS_DIST_DIR="${DIST_DIR}" SFS_SKIP_SELF_UPGRADE=1 SFS_SKIP_CLI_DISCOVERY=1 \
     GEMINI_API_KEY= GOOGLE_API_KEY= GOOGLE_APPLICATION_CREDENTIALS= \
     SFS_TEAM_PROMOTE_YES=1 \
     bash "${SFS_BIN}" team refresh --yes ) >"${T4}/unauthed.log" 2>&1 </dev/null \
  || fail "T4: refresh (unauthed) crashed (see ${T4}/unauthed.log)"
[[ "$(resolve "${MP4}" researcher)" == "gemini" ]] || fail "T4: promoted on installed-but-unauthed agy (R5 broken)"
# Now authed via the explicit ready flag → promote.
( cd "${T4}" \
  && PATH="${STUB}:${PATH}" \
     SFS_DIST_DIR="${DIST_DIR}" SFS_SKIP_SELF_UPGRADE=1 SFS_SKIP_CLI_DISCOVERY=1 \
     SFS_ANTIGRAVITY_AUTH_READY=1 \
     SFS_TEAM_PROMOTE_YES=1 \
     bash "${SFS_BIN}" team refresh --yes ) >"${T4}/authed.log" 2>&1 </dev/null \
  || fail "T4: refresh (authed) failed (see ${T4}/authed.log)"
[[ "$(resolve "${MP4}" researcher)" == "antigravity" ]] || fail "T4: not promoted after agy authed"

# ── T5 (R4): non-interactive w/o --yes = no change; upgrade --yes never forces ─
T5="${TMP_ROOT}/t5"; mkdir -p "${T5}"; init_project "${T5}"; seed_fallback "${T5}"
MP5="$(mp_of "${T5}")"
before5="$(sha "${MP5}")"
# refresh, agy capable, but NO promote-yes and no tty → must be byte-for-byte.
( cd "${T5}" \
  && SFS_DIST_DIR="${DIST_DIR}" SFS_SKIP_SELF_UPGRADE=1 SFS_SKIP_CLI_DISCOVERY=1 \
     SFS_TEAM_FORCE_CAPABLE_ANTIGRAVITY=1 SFS_FORCE_NONINTERACTIVE=1 \
     bash "${SFS_BIN}" team refresh ) >"${T5}/noyes.log" 2>&1 </dev/null \
  || fail "T5: refresh (no-yes) failed (see ${T5}/noyes.log)"
[[ "$(resolve "${MP5}" researcher)" == "gemini" ]] || fail "T5: non-interactive refresh promoted without consent"
[[ "$(sha "${MP5}")" == "${before5}" ]] || fail "T5: non-interactive refresh mutated profile"
# `sfs upgrade --yes` on a fallback project: hint only, byte-for-byte, no force.
( cd "${T5}" \
  && SFS_DIST_DIR="${DIST_DIR}" SFS_SKIP_SELF_UPGRADE=1 SFS_SKIP_CLI_DISCOVERY=1 \
     SFS_MODEL_PROFILE_PROMPT=0 SFS_INSTALL_LLM_WIKI=0 \
     SFS_TEAM_FORCE_CAPABLE_CLAUDE=1 SFS_TEAM_FORCE_CAPABLE_CODEX=1 \
     SFS_TEAM_FORCE_CAPABLE_ANTIGRAVITY=1 SFS_TEAM_FORCE_CAPABLE_GEMINI=1 \
     bash "${UPGRADE}" --yes ) >"${T5}/upy.log" 2>&1 </dev/null \
  || fail "T5: upgrade --yes failed (see ${T5}/upy.log)"
[[ "$(resolve "${MP5}" researcher)" == "gemini" ]] || fail "T5: upgrade --yes force-promoted (R4 broken)"
[[ "$(sha "${MP5}")" == "${before5}" ]] || fail "T5: upgrade --yes mutated fallback binding"

echo "test-team-fallback-promotion: OK"
