#!/usr/bin/env bash
# Multi-agent team topology — `sfs team use` activation + capability gate.
#
# 0.8.49 headline lock (eval-first). 0.8.48 shipped upgrade-time activation
# (`sfs upgrade --team`). 0.8.49 adds an independent write command so a user can
# activate a preset ANY time without an upgrade, sharing ONE materialize core,
# behind a capability preflight (R3).
#
#   T1 (R1): legacy(pre-0.8.42) schema + `sfs team use trio` → zero manual edits;
#            resolve-runtime worker=codex / lead=claude / researcher=antigravity.
#   T2 (R1): `sfs team use` and `sfs upgrade --team` share the same core → the
#            two paths produce identical bindings; trio→pair toggle re-materializes.
#   T3 (R3): agy absent → researcher falls back to gemini (deprecated) with a
#            notice; agy+gemini absent → researcher held (degrades to
#            selected_runtime) with guidance. Never crashes, exits 0.
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

TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/sfs-team-use.XXXXXX")"
cleanup() { rm -rf "${TMP_ROOT}"; }
trap cleanup EXIT

mp_of()  { echo "$1/.sfs-local/model-profiles.yaml"; }
preset_of() { awk '/^team_preset:/ {v=$0; sub(/^team_preset:[[:space:]]*/,"",v); sub(/[[:space:]]*#.*/,"",v); gsub(/[[:space:]]/,"",v); print v; exit}' "$1"; }
resolve() { SFS_MODEL_PROFILES="$1" bash "${RESOLVER}" resolve-runtime "$2"; }

init_project() {
  local dir="$1"
  ( cd "${dir}" \
    && git init -q \
    && git config user.email team-use@solon.invalid \
    && git config user.name "Solon Team Use Test" \
    && printf '# team use\n' > README.md \
    && git add . && git commit -qm init ) >/dev/null 2>&1
  ( cd "${dir}" \
    && SFS_DIST_DIR="${DIST_DIR}" SFS_INSTALL_LLM_WIKI=0 SFS_SKIP_CLI_DISCOVERY=1 \
       bash "${SFS_BIN}" init --layout thin --yes ) >"${dir}/init.log" 2>&1 </dev/null \
    || fail "init failed (see ${dir}/init.log)"
}

write_legacy_profile() {
  cat > "$1" <<'EOF'
# .sfs-local/model-profiles.yaml (legacy pre-0.8.42 — no team keys)
version: 2.1
project: "legacy-fixture"
created: "2026-01-01"
solon_mvp_version: "0.8.40"

configuration:
  status: "default_applied"
  selected_runtime: "claude"
  selected_policy: "solon_recommended"
  confirmed_by: ""
  confirmed_at: ""
  note: "legacy fixture"

runtime_model_settings:
  claude:
    plan: "claude-opus"
  codex:
    code: "gpt-5"
EOF
}

# Run `sfs team use <preset>` in a project dir. Capability is force-injected so
# the gate is deterministic regardless of which CLIs exist on the test host.
# Override per-runtime with FC_CLAUDE/FC_CODEX/FC_AGY/FC_GEMINI (default capable).
team_use() {
  local dir="$1" preset="$2"
  ( cd "${dir}" \
    && SFS_DIST_DIR="${DIST_DIR}" SFS_SKIP_SELF_UPGRADE=1 SFS_SKIP_CLI_DISCOVERY=1 \
       SFS_TEAM_FORCE_CAPABLE_CLAUDE="${FC_CLAUDE:-1}" \
       SFS_TEAM_FORCE_CAPABLE_CODEX="${FC_CODEX:-1}" \
       SFS_TEAM_FORCE_CAPABLE_ANTIGRAVITY="${FC_AGY:-1}" \
       SFS_TEAM_FORCE_CAPABLE_GEMINI="${FC_GEMINI:-1}" \
       bash "${SFS_BIN}" team use "${preset}" ) >"${dir}/use.log" 2>&1 </dev/null
}

# ── T1 (R1): legacy schema + `sfs team use trio` materializes, no upgrade ────
T1="${TMP_ROOT}/t1"; mkdir -p "${T1}"
init_project "${T1}"
write_legacy_profile "$(mp_of "${T1}")"
MP1="$(mp_of "${T1}")"
for k in team_preset runtime_registry agent_runtime_bindings team_preset_catalog; do
  grep -q "^${k}:" "${MP1}" && fail "T1 precondition: legacy fixture already has '${k}'"
done
team_use "${T1}" trio || fail "T1: 'sfs team use trio' failed (see ${T1}/use.log)"
[[ "$(preset_of "${MP1}")" == "trio" ]] || fail "T1: team_preset not trio (got '$(preset_of "${MP1}")')"
grep -Eq '^agent_runtime_bindings:[[:space:]]*$' "${MP1}" || fail "T1: bindings block not materialized"
[[ "$(resolve "${MP1}" lead)" == "claude" ]]            || fail "T1: lead != claude"
[[ "$(resolve "${MP1}" worker)" == "codex" ]]           || fail "T1: worker != codex"
[[ "$(resolve "${MP1}" researcher)" == "antigravity" ]] || fail "T1: researcher != antigravity"
grep -q '^  selected_runtime: "claude"' "${MP1}" || fail "T1: configuration.selected_runtime clobbered"
for a in CLAUDE.md AGENTS.md GEMINI.md; do
  [[ -f "${T1}/${a}" ]] && { grep -q '^team_dispatch:' "${T1}/${a}" || fail "T1: ${a} missing team_dispatch"; }
done

# ── T2 (R1): `team use` and `upgrade --team` share one core (identical) ──────
USEP="${TMP_ROOT}/t2-use"; mkdir -p "${USEP}"; init_project "${USEP}"
UPGP="${TMP_ROOT}/t2-upg"; mkdir -p "${UPGP}"; init_project "${UPGP}"
team_use "${USEP}" trio || fail "T2: team use trio failed (see ${USEP}/use.log)"
( cd "${UPGP}" && SFS_DIST_DIR="${DIST_DIR}" SFS_SKIP_CLI_DISCOVERY=1 SFS_MODEL_PROFILE_PROMPT=0 \
    SFS_INSTALL_LLM_WIKI=0 bash "${UPGRADE}" --yes --team trio ) >"${UPGP}/up.log" 2>&1 </dev/null \
  || fail "T2: upgrade --team trio failed (see ${UPGP}/up.log)"
for tok in lead worker researcher; do
  uv="$(resolve "$(mp_of "${USEP}")" "${tok}")"
  gv="$(resolve "$(mp_of "${UPGP}")" "${tok}")"
  [[ "${uv}" == "${gv}" ]] || fail "T2: use/upgrade divergence for '${tok}' (use=${uv} upgrade=${gv})"
done
# trio→pair toggle re-materializes (worker stays codex; researcher drops to fallback).
team_use "${USEP}" pair || fail "T2: toggle trio→pair failed (see ${USEP}/use.log)"
[[ "$(preset_of "$(mp_of "${USEP}")")" == "pair" ]] || fail "T2: toggle did not set pair"
[[ "$(resolve "$(mp_of "${USEP}")" worker)" == "codex" ]] || fail "T2: pair worker != codex after toggle"

# ── T3 (R3): capability gate — agy absent → gemini fallback / hold ───────────
# (a) agy absent, gemini capable → researcher = gemini (deprecated notice).
T3F="${TMP_ROOT}/t3-fallback"; mkdir -p "${T3F}"; init_project "${T3F}"
MP3F="$(mp_of "${T3F}")"
FC_AGY=0 FC_GEMINI=1 team_use "${T3F}" trio || fail "T3-fallback: crashed/non-zero (see ${T3F}/use.log)"
[[ "$(resolve "${MP3F}" researcher)" == "gemini" ]] || fail "T3-fallback: researcher not gemini fallback (got '$(resolve "${MP3F}" researcher)')"
[[ "$(resolve "${MP3F}" worker)" == "codex" ]]      || fail "T3-fallback: worker != codex"
grep -qi 'fallback\|DEPRECATED' "${T3F}/use.log" || fail "T3-fallback: no fallback/deprecated notice emitted"
# (b) agy absent AND gemini absent → researcher held → degrades to selected_runtime.
T3H="${TMP_ROOT}/t3-hold"; mkdir -p "${T3H}"; init_project "${T3H}"
MP3H="$(mp_of "${T3H}")"
sel3="$(awk '/^configuration:/{c=1;next} c&&/^[[:space:]]+selected_runtime:/{v=$0;sub(/^[[:space:]]+selected_runtime:[[:space:]]*/,"",v);gsub(/["\047]/,"",v);sub(/[[:space:]]*#.*/,"",v);sub(/[[:space:]]*$/,"",v);print v;exit} c&&/^[A-Za-z_]/{c=0}' "${MP3H}")"
FC_AGY=0 FC_GEMINI=0 team_use "${T3H}" trio || fail "T3-hold: crashed/non-zero (see ${T3H}/use.log)"
[[ "$(resolve "${MP3H}" researcher)" == "${sel3}" ]] || fail "T3-hold: researcher not degraded to selected_runtime '${sel3}'"
[[ "$(resolve "${MP3H}" worker)" == "codex" ]]       || fail "T3-hold: capable worker binding dropped"
grep -q '보류' "${T3H}/use.log" || fail "T3-hold: no '보류' (held) guidance emitted"

echo "test-team-use-activation: OK"
