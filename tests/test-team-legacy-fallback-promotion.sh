#!/usr/bin/env bash
# Multi-agent team topology — 0.8.53 legacy UNMARKED deprecated-fallback promotion.
#
# 0.8.53 headline lock (eval-first). 0.8.52 promotes a fallback binding back to
# canonical ONLY when it carries the `# sfs-fallback: <canonical>` provenance
# marker — but that marker is written at materialize time, so it only exists on
# bindings that fell back AFTER 0.8.52. A project that hardened to the deprecated
# `gemini` runtime BEFORE 0.8.52 (no marker — e.g. a hand-spliced binding) was
# classified user-custom and preserved forever, with no product-level path back
# to canonical once `agy` was installed. 0.8.53 adds a 2nd detection signal:
# an UNMARKED binding pointing at a runtime the registry marks `deprecated`, whose
# active-preset catalog canonical differs and is now capable, is inferred to be a
# legacy fallback and promoted via the SAME detect -> offer -> consent -> apply path.
#
#   T1: legacy unmarked researcher=gemini + agy capable -> `sfs team refresh --yes`
#       (and `team use trio`) promotes researcher->antigravity; no pin written.
#   T2 (R2): explicit decline -> `# sfs-pinned: gemini (user)` written -> researcher
#       stays gemini AND a later capable+promote-yes refresh does NOT promote
#       (pin honored = 영영 재제안 안 함). resolve-runtime unaffected by the comment.
#   T3 (R3): user override to a NON-deprecated runtime (researcher=claude) -> never
#       offered/changed, no pin, even with everything capable + promote-yes.
#   T4 (R4): agy installed but UNAUTHED -> not promoted, NO pin (auth-aware gate);
#       once authed (SFS_ANTIGRAVITY_AUTH_READY=1) -> promoted.
#   T5 (R5): non-interactive without consent = byte-for-byte no change, NO pin.
#   T6: the activatable-states registry enumerates this state and the meta-test passes.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
RESOLVER="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-team.sh"
APPLY="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-team-apply.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
[[ -f "${SFS_BIN}" ]]  || fail "bin/sfs not found"
[[ -f "${APPLY}" ]]    || fail "sfs-team-apply.sh (shared core) not found"
[[ -f "${RESOLVER}" ]] || fail "resolver not found"

TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/sfs-team-legacy.XXXXXX")"
cleanup() { rm -rf "${TMP_ROOT}"; }
trap cleanup EXIT

mp_of()   { echo "$1/.sfs-local/model-profiles.yaml"; }
resolve() { SFS_MODEL_PROFILES="$1" bash "${RESOLVER}" resolve-runtime "$2"; }
sha()     { shasum "$1" | awk '{print $1}'; }
sed_i()   { if [ "$(uname)" = "Darwin" ]; then sed -i '' "$@"; else sed -i "$@"; fi; }

init_project() {
  local dir="$1"
  ( cd "${dir}" \
    && git init -q \
    && git config user.email legacy@solon.invalid \
    && git config user.name "Solon Legacy Test" \
    && printf '# legacy\n' > README.md \
    && git add . && git commit -qm init ) >/dev/null 2>&1
  ( cd "${dir}" \
    && SFS_DIST_DIR="${DIST_DIR}" SFS_INSTALL_LLM_WIKI=0 SFS_SKIP_CLI_DISCOVERY=1 \
       bash "${SFS_BIN}" init --layout thin --yes ) >"${dir}/init.log" 2>&1 </dev/null \
    || fail "init failed (see ${dir}/init.log)"
}

# Activate trio with agy INCAPABLE so researcher falls back to gemini, THEN strip
# the `# sfs-fallback:` marker — reproducing a pre-0.8.52 unmarked legacy binding.
seed_legacy() {
  local dir="$1" mp
  ( cd "${dir}" \
    && SFS_DIST_DIR="${DIST_DIR}" SFS_SKIP_SELF_UPGRADE=1 SFS_SKIP_CLI_DISCOVERY=1 \
       SFS_TEAM_FORCE_CAPABLE_CLAUDE=1 SFS_TEAM_FORCE_CAPABLE_CODEX=1 \
       SFS_TEAM_FORCE_CAPABLE_ANTIGRAVITY=0 SFS_TEAM_FORCE_CAPABLE_GEMINI=1 \
       bash "${SFS_BIN}" team use trio ) >"${dir}/seed.log" 2>&1 </dev/null \
    || fail "seed: team use trio failed (see ${dir}/seed.log)"
  mp="$(mp_of "${dir}")"
  sed_i 's/[[:space:]]*# sfs-fallback:.*$//' "${mp}"
  grep -q '# sfs-fallback:' "${mp}" && fail "seed: marker not stripped (legacy not reproduced)"
  [[ "$(resolve "${mp}" researcher)" == "gemini" ]] || fail "seed: researcher not gemini"
}

refresh() { # <dir> <extra-env...> -- runs `sfs team refresh [--yes via env]`
  local dir="$1"; shift
  ( cd "${dir}" \
    && SFS_DIST_DIR="${DIST_DIR}" SFS_SKIP_SELF_UPGRADE=1 SFS_SKIP_CLI_DISCOVERY=1 \
       "$@" bash "${SFS_BIN}" team refresh ) </dev/null
}

# ── T1: legacy unmarked gemini + agy capable -> promoted (refresh --yes) ──────
T1="${TMP_ROOT}/t1"; mkdir -p "${T1}"; init_project "${T1}"; seed_legacy "${T1}"
MP1="$(mp_of "${T1}")"
refresh "${T1}" env SFS_TEAM_FORCE_CAPABLE_ANTIGRAVITY=1 SFS_TEAM_PROMOTE_YES=1 \
  >"${T1}/refresh.log" 2>&1 || fail "T1: refresh failed (see ${T1}/refresh.log)"
[[ "$(resolve "${MP1}" researcher)" == "antigravity" ]] || fail "T1: legacy gemini not promoted to antigravity (got '$(resolve "${MP1}" researcher)')"
grep -q '# sfs-pinned:' "${MP1}" && fail "T1: pin written on a promotion (should only pin on decline)"
[[ "$(resolve "${MP1}" worker)" == "codex" ]] || fail "T1: worker binding disturbed"
# `team use trio` reaches the same promotion on a fresh legacy seed.
T1b="${TMP_ROOT}/t1b"; mkdir -p "${T1b}"; init_project "${T1b}"; seed_legacy "${T1b}"
( cd "${T1b}" \
  && SFS_DIST_DIR="${DIST_DIR}" SFS_SKIP_SELF_UPGRADE=1 SFS_SKIP_CLI_DISCOVERY=1 \
     SFS_TEAM_FORCE_CAPABLE_CLAUDE=1 SFS_TEAM_FORCE_CAPABLE_CODEX=1 \
     SFS_TEAM_FORCE_CAPABLE_ANTIGRAVITY=1 SFS_TEAM_FORCE_CAPABLE_GEMINI=1 \
     SFS_TEAM_PROMOTE_YES=1 \
     bash "${SFS_BIN}" team use trio ) >"${T1b}/use.log" 2>&1 </dev/null \
  || fail "T1b: team use trio (promote) failed (see ${T1b}/use.log)"
[[ "$(resolve "$(mp_of "${T1b}")" researcher)" == "antigravity" ]] || fail "T1b: legacy not promoted via team use"

# ── T2 (R2): explicit decline -> pin -> never re-offered ──────────────────────
T2="${TMP_ROOT}/t2"; mkdir -p "${T2}"; init_project "${T2}"; seed_legacy "${T2}"
MP2="$(mp_of "${T2}")"
refresh "${T2}" env SFS_TEAM_FORCE_CAPABLE_ANTIGRAVITY=1 SFS_TEAM_PROMOTE_DECLINE=1 \
  >"${T2}/decline.log" 2>&1 || fail "T2: decline refresh failed (see ${T2}/decline.log)"
[[ "$(resolve "${MP2}" researcher)" == "gemini" ]] || fail "T2: declined legacy was promoted"
grep -q '# sfs-pinned: gemini (user)' "${MP2}" || fail "T2: pin marker not written on decline (R2)"
# Pin must not affect resolution (comment-stripped by read_binding).
[[ "$(resolve "${MP2}" researcher)" == "gemini" ]] || fail "T2: pin comment broke resolve-runtime"
# A later capable + promote-yes refresh must NOT promote a pinned binding.
before2="$(sha "${MP2}")"
refresh "${T2}" env SFS_TEAM_FORCE_CAPABLE_ANTIGRAVITY=1 SFS_TEAM_PROMOTE_YES=1 \
  >"${T2}/reoffer.log" 2>&1 || fail "T2: re-offer refresh failed"
[[ "$(resolve "${MP2}" researcher)" == "gemini" ]] || fail "T2: pinned binding promoted on later refresh (pin not honored)"
[[ "$(sha "${MP2}")" == "${before2}" ]] || fail "T2: pinned binding mutated on later refresh"

# ── T3 (R3): non-deprecated user override is never offered/changed ────────────
T3="${TMP_ROOT}/t3"; mkdir -p "${T3}"; init_project "${T3}"; seed_legacy "${T3}"
MP3="$(mp_of "${T3}")"
# Rewrite researcher to a NON-deprecated runtime the user genuinely chose.
sed_i 's/^\([[:space:]]*\)researcher:.*$/\1researcher: claude/' "${MP3}"
[[ "$(resolve "${MP3}" researcher)" == "claude" ]] || fail "T3 setup: researcher not claude"
before3="$(sha "${MP3}")"
refresh "${T3}" env SFS_TEAM_FORCE_CAPABLE_CLAUDE=1 SFS_TEAM_FORCE_CAPABLE_CODEX=1 \
  SFS_TEAM_FORCE_CAPABLE_ANTIGRAVITY=1 SFS_TEAM_FORCE_CAPABLE_GEMINI=1 \
  SFS_TEAM_PROMOTE_YES=1 >"${T3}/override.log" 2>&1 || fail "T3: refresh failed"
[[ "$(resolve "${MP3}" researcher)" == "claude" ]] || fail "T3: non-deprecated override was clobbered (R3 broken)"
[[ "$(sha "${MP3}")" == "${before3}" ]] || fail "T3: non-deprecated override mutated"
grep -q '# sfs-pinned:' "${MP3}" && fail "T3: pin written on a non-deprecated override (should never offer)"
grep -q '보존' "${T3}/override.log" || fail "T3: no preservation notice emitted"

# ── T4 (R4): agy installed-but-unauthed -> not promoted, no pin; authed -> promote
T4="${TMP_ROOT}/t4"; mkdir -p "${T4}"; init_project "${T4}"; seed_legacy "${T4}"
MP4="$(mp_of "${T4}")"
STUB="${T4}/stubbin"; mkdir -p "${STUB}"
printf '#!/usr/bin/env bash\nexit 0\n' > "${STUB}/agy"; chmod +x "${STUB}/agy"
before4="$(sha "${MP4}")"
refresh "${T4}" env PATH="${STUB}:${PATH}" \
  GEMINI_API_KEY= GOOGLE_API_KEY= GOOGLE_APPLICATION_CREDENTIALS= \
  SFS_TEAM_PROMOTE_YES=1 >"${T4}/unauthed.log" 2>&1 || fail "T4: unauthed refresh crashed"
[[ "$(resolve "${MP4}" researcher)" == "gemini" ]] || fail "T4: promoted on installed-but-unauthed agy (R4 broken)"
grep -q '# sfs-pinned:' "${MP4}" && fail "T4: pin written while canonical incapable (no offer should fire)"
[[ "$(sha "${MP4}")" == "${before4}" ]] || fail "T4: profile mutated while canonical incapable"
refresh "${T4}" env PATH="${STUB}:${PATH}" SFS_ANTIGRAVITY_AUTH_READY=1 \
  SFS_TEAM_PROMOTE_YES=1 >"${T4}/authed.log" 2>&1 || fail "T4: authed refresh failed"
[[ "$(resolve "${MP4}" researcher)" == "antigravity" ]] || fail "T4: not promoted after agy authed"

# ── T5 (R5): non-interactive without consent = byte-for-byte, no pin ──────────
T5="${TMP_ROOT}/t5"; mkdir -p "${T5}"; init_project "${T5}"; seed_legacy "${T5}"
MP5="$(mp_of "${T5}")"
before5="$(sha "${MP5}")"
refresh "${T5}" env SFS_TEAM_FORCE_CAPABLE_ANTIGRAVITY=1 SFS_FORCE_NONINTERACTIVE=1 \
  >"${T5}/noyes.log" 2>&1 || fail "T5: non-interactive refresh failed"
[[ "$(resolve "${MP5}" researcher)" == "gemini" ]] || fail "T5: non-interactive refresh promoted without consent"
grep -q '# sfs-pinned:' "${MP5}" && fail "T5: pin written without an explicit decline (R5 broken)"
[[ "$(sha "${MP5}")" == "${before5}" ]] || fail "T5: non-interactive refresh mutated profile"

# ── T5b (R6): upgrade surface detects a legacy candidate (no marker) ──────────
# The handoff's live user-verification is `sfs upgrade` on a legacy gemini project.
# Lock both halves TTY-free: (1) --promotable-fp infers the legacy candidate, and
# (2) `upgrade --yes` hints only and leaves the binding byte-for-byte unchanged.
T5b="${TMP_ROOT}/t5b"; mkdir -p "${T5b}"; init_project "${T5b}"; seed_legacy "${T5b}"
MP5b="$(mp_of "${T5b}")"
fp="$(SFS_TEAM_TARGET="${T5b}" SFS_TEAM_RESOLVER="${RESOLVER}" \
  SFS_TEAM_FORCE_CAPABLE_ANTIGRAVITY=1 bash "${APPLY}" --promotable-fp 2>/dev/null)"
[[ "${fp}" == "fp=antigravity" ]] || fail "T5b: --promotable-fp did not infer legacy candidate (got '${fp}')"
before5b="$(sha "${MP5b}")"
( cd "${T5b}" \
  && SFS_DIST_DIR="${DIST_DIR}" SFS_SKIP_SELF_UPGRADE=1 SFS_SKIP_CLI_DISCOVERY=1 \
     SFS_MODEL_PROFILE_PROMPT=0 SFS_INSTALL_LLM_WIKI=0 \
     SFS_TEAM_FORCE_CAPABLE_CLAUDE=1 SFS_TEAM_FORCE_CAPABLE_CODEX=1 \
     SFS_TEAM_FORCE_CAPABLE_ANTIGRAVITY=1 SFS_TEAM_FORCE_CAPABLE_GEMINI=1 \
     bash "${DIST_DIR}/upgrade.sh" --yes ) >"${T5b}/upy.log" 2>&1 </dev/null \
  || fail "T5b: upgrade --yes failed (see ${T5b}/upy.log)"
[[ "$(resolve "${MP5b}" researcher)" == "gemini" ]] || fail "T5b: upgrade --yes force-promoted legacy (R4/R5 broken)"
[[ "$(sha "${MP5b}")" == "${before5b}" ]] || fail "T5b: upgrade --yes mutated legacy binding"
grep -q '승격 가능' "${T5b}/upy.log" || fail "T5b: upgrade --yes emitted no promotion hint"

# ── T6: registry enumerates this state + meta-test passes ─────────────────────
grep -Eq '^legacy-fallback-promotion\|test-team-legacy-fallback-promotion\.sh\|' \
  "${SCRIPT_DIR}/activatable-states.registry" \
  || fail "T6: activatable-states.registry missing legacy-fallback-promotion row"
bash "${SCRIPT_DIR}/test-activatable-states-registry.sh" >/dev/null 2>&1 \
  || fail "T6: activatable-states registry meta-test failed"

echo "test-team-legacy-fallback-promotion: OK"
