#!/usr/bin/env bash
# Multi-agent team topology — upgrade-path legacy migration headline lock.
#
# Patch release follow-up to the 0.8.42..0.8.47 team-topology cut. The cut
# shipped install --team correctly but left the upgrade path broken for
# legacy (pre-0.8.42) consumers. This file is the eval-first regression lock
# for the four fixes:
#
#   T1 (F2): legacy schema (zero team keys) → `upgrade --team trio` scaffolds
#            the team block AND fills agent_runtime_bindings from the trio
#            catalog; resolver then resolves worker=codex.
#   T2 (F1): `sfs upgrade --team trio` (front-door flag) == env SFS_AGENT_TEAM
#            path. Before the fix bin/sfs rejected --team with "unknown arg".
#   T3 (F3): bindings-fill guard is 3-way (absent vs literal {} vs custom) with
#            corrected warning strings (no "not default {}" for an absent key).
#   T4 (inv): non-interactive `upgrade --yes` (no --team) on a current-schema
#            solo project is byte-for-byte no-op on model-profiles.yaml and
#            never injects team_dispatch into adapters (standalone lock).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
UPGRADE="${DIST_DIR}/upgrade.sh"
RESOLVER="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-team.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f "${UPGRADE}" ]]  || fail "upgrade.sh not found"
[[ -f "${SFS_BIN}" ]]  || fail "bin/sfs not found"
[[ -f "${RESOLVER}" ]] || fail "resolver not found"

TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/sfs-team-upgrade.XXXXXX")"
cleanup() { rm -rf "${TMP_ROOT}"; }
trap cleanup EXIT

mp_of()  { echo "$1/.sfs-local/model-profiles.yaml"; }
preset_of() { awk '/^team_preset:/ {v=$0; sub(/^team_preset:[[:space:]]*/,"",v); sub(/[[:space:]]*#.*/,"",v); gsub(/[[:space:]]/,"",v); print v; exit}' "$1"; }
resolve() { SFS_MODEL_PROFILES="$1" bash "${RESOLVER}" resolve-runtime "$2"; }

# Initialize a fresh current-schema project (thin layout, solo default).
init_project() {
  local dir="$1"
  ( cd "${dir}" \
    && git init -q \
    && git config user.email team-upgrade@solon.invalid \
    && git config user.name "Solon Team Upgrade Test" \
    && printf '# team upgrade\n' > README.md \
    && git add . && git commit -qm init ) >/dev/null 2>&1
  ( cd "${dir}" \
    && SFS_DIST_DIR="${DIST_DIR}" SFS_INSTALL_LLM_WIKI=0 SFS_SKIP_CLI_DISCOVERY=1 \
       bash "${SFS_BIN}" init --layout thin --yes ) >"${dir}/init.log" 2>&1 </dev/null \
    || fail "init failed (see ${dir}/init.log)"
}

# Overwrite the project's profile with a legacy (pre-0.8.42) one: configuration
# block present, ZERO team keys, no external_orchestrator. selected_runtime is
# claude so a trio worker=codex binding is provably the binding, not fallback.
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

run_upgrade() {
  local dir="$1"; shift
  ( cd "${dir}" \
    && SFS_DIST_DIR="${DIST_DIR}" SFS_SKIP_CLI_DISCOVERY=1 SFS_MODEL_PROFILE_PROMPT=0 \
       SFS_INSTALL_LLM_WIKI=0 \
       bash "${UPGRADE}" --yes "$@" ) >"${dir}/upgrade.log" 2>&1 </dev/null
}

# ── T1 (F2): legacy schema → upgrade --team trio scaffolds + fills ──────────
T1="${TMP_ROOT}/t1"; mkdir -p "${T1}"
init_project "${T1}"
write_legacy_profile "$(mp_of "${T1}")"
MP1="$(mp_of "${T1}")"
# precondition: truly legacy — none of the team keys present.
for k in team_preset runtime_registry agent_runtime_bindings team_preset_catalog unassigned_role_policy; do
  grep -q "^${k}:" "${MP1}" && fail "T1 precondition: legacy fixture already has '${k}'"
done
run_upgrade "${T1}" --team trio || fail "T1: upgrade --team trio failed (see ${T1}/upgrade.log)"
# all team keys now scaffolded.
for k in team_preset runtime_registry agent_runtime_bindings team_preset_catalog unassigned_role_policy; do
  grep -q "^${k}:" "${MP1}" || fail "T1: team key '${k}' not scaffolded into legacy profile"
done
[[ "$(preset_of "${MP1}")" == "trio" ]] || fail "T1: team_preset not trio after migrate (got '$(preset_of "${MP1}")')"
grep -Eq '^agent_runtime_bindings:[[:space:]]*$' "${MP1}" || fail "T1: bindings block not materialized (still inline {}?)"
[[ "$(resolve "${MP1}" lead)" == "claude" ]]       || fail "T1: lead != claude"
[[ "$(resolve "${MP1}" worker)" == "codex" ]]      || fail "T1: worker != codex (binding not filled)"
[[ "$(resolve "${MP1}" researcher)" == "antigravity" ]] || fail "T1: researcher != antigravity"
# configuration block preserved (no clobber of existing keys).
grep -q '^  selected_runtime: "claude"' "${MP1}" || fail "T1: configuration.selected_runtime clobbered"
grep -q '^runtime_model_settings:' "${MP1}"       || fail "T1: pre-existing runtime_model_settings dropped"
# adapters got dispatch injection (trio != solo).
for a in CLAUDE.md AGENTS.md GEMINI.md; do
  [[ -f "${T1}/${a}" ]] && { grep -q '^team_dispatch:' "${T1}/${a}" || fail "T1: ${a} missing team_dispatch after migrate"; }
done

# ── T2 (F1): front-door --team flag == env SFS_AGENT_TEAM ────────────────────
FLAG="${TMP_ROOT}/t2-flag"; mkdir -p "${FLAG}"; init_project "${FLAG}"
ENVP="${TMP_ROOT}/t2-env";  mkdir -p "${ENVP}"; init_project "${ENVP}"
( cd "${FLAG}" && SFS_DIST_DIR="${DIST_DIR}" SFS_SKIP_SELF_UPGRADE=1 SFS_UPDATE_SELF=0 \
    SFS_SKIP_CLI_DISCOVERY=1 SFS_MODEL_PROFILE_PROMPT=0 SFS_INSTALL_LLM_WIKI=0 \
    bash "${SFS_BIN}" upgrade --team trio ) >"${FLAG}/up.log" 2>&1 </dev/null \
  || fail "T2: bin/sfs upgrade --team trio failed (see ${FLAG}/up.log) — front-door still rejects flag?"
( cd "${ENVP}" && SFS_DIST_DIR="${DIST_DIR}" SFS_SKIP_SELF_UPGRADE=1 SFS_UPDATE_SELF=0 \
    SFS_SKIP_CLI_DISCOVERY=1 SFS_MODEL_PROFILE_PROMPT=0 SFS_INSTALL_LLM_WIKI=0 \
    SFS_AGENT_TEAM=trio bash "${SFS_BIN}" upgrade ) >"${ENVP}/up.log" 2>&1 </dev/null \
  || fail "T2: bin/sfs upgrade (env) failed (see ${ENVP}/up.log)"
[[ "$(preset_of "$(mp_of "${FLAG}")")" == "trio" ]] || fail "T2: flag path did not set trio"
[[ "$(preset_of "$(mp_of "${ENVP}")")" == "trio" ]] || fail "T2: env path did not set trio"
for tok in lead worker researcher; do
  fv="$(resolve "$(mp_of "${FLAG}")" "${tok}")"
  ev="$(resolve "$(mp_of "${ENVP}")" "${tok}")"
  [[ "${fv}" == "${ev}" ]] || fail "T2: flag/env divergence for '${tok}' (flag=${fv} env=${ev})"
done
# invalid value rejected at the front door.
if ( cd "${FLAG}" && SFS_DIST_DIR="${DIST_DIR}" SFS_SKIP_SELF_UPGRADE=1 SFS_UPDATE_SELF=0 \
      SFS_SKIP_CLI_DISCOVERY=1 bash "${SFS_BIN}" upgrade --team quintet ) >/dev/null 2>&1 </dev/null; then
  fail "T2: front-door accepted invalid --team value (expected non-zero)"
fi

# ── T3 (F3): 3-way bindings guard + corrected warning strings ───────────────
# (a) custom bindings preserved + "사용자 커스텀 ... 보존" warning.
# Use a NON-deprecated deliberate choice (lead: codex). As of 0.8.53 an unmarked
# binding to a *deprecated* runtime is inferred to be a legacy fallback (offered,
# not silently preserved — see test-team-legacy-fallback-promotion.sh), so the
# durable "user-custom preserved" invariant rides on a non-deprecated override.
T3C="${TMP_ROOT}/t3-custom"; mkdir -p "${T3C}"; init_project "${T3C}"
MP3C="$(mp_of "${T3C}")"
# Hand-customize bindings (team_preset present so scaffold skips, 3-way runs).
awk '
  /^agent_runtime_bindings:/ { print "agent_runtime_bindings:"; print "  lead: codex"; skip=1; next }
  skip && /^[[:space:]]+[A-Za-z_]+:[[:space:]]/ { next }
  skip && /^[[:space:]]*$/ { next }
  skip { skip=0 }
  { print }
' "${MP3C}" > "${MP3C}.tmp" && mv "${MP3C}.tmp" "${MP3C}"
sed_i() { if sed --version >/dev/null 2>&1; then sed -i "$@"; else sed -i '' "$@"; fi; }
sed_i 's|^team_preset:.*|team_preset: solo|' "${MP3C}"   # leave preset solo; ask trio at upgrade
run_upgrade "${T3C}" --team trio || fail "T3-custom: upgrade failed (see ${T3C}/upgrade.log)"
grep -q '^  lead: codex' "${MP3C}" || fail "T3-custom: custom binding 'lead: codex' was clobbered"
grep -q '사용자 커스텀' "${T3C}/upgrade.log" || fail "T3-custom: missing '사용자 커스텀' warning"
grep -q '보존' "${T3C}/upgrade.log"       || fail "T3-custom: missing '보존' (preserve) warning"

# (b) absent bindings key (partial schema) → "키 부재" warning, not "not {}".
T3A="${TMP_ROOT}/t3-absent"; mkdir -p "${T3A}"; init_project "${T3A}"
MP3A="$(mp_of "${T3A}")"
# Strip ONLY agent_runtime_bindings (keep team_preset so scaffold is skipped).
awk '
  /^agent_runtime_bindings:/ { drop=1; next }
  drop && /^[[:space:]]/ { next }
  drop && /^[[:space:]]*$/ { print; drop=0; next }
  drop { drop=0 }
  { print }
' "${MP3A}" > "${MP3A}.tmp" && mv "${MP3A}.tmp" "${MP3A}"
grep -q '^agent_runtime_bindings:' "${MP3A}" && fail "T3-absent: precondition strip failed"
run_upgrade "${T3A}" --team trio || true   # may warn; must not crash the run fatally
grep -q '키 부재' "${T3A}/upgrade.log" || fail "T3-absent: missing '키 부재' (absent-key) warning"
# the OLD wrong message must NOT appear for an absent key.
if grep -q '기본 {} 가 아님' "${T3A}/upgrade.log"; then
  fail "T3-absent: emitted the misdiagnosing 'not default {}' message for an absent key"
fi

# (c) literal {} fill is covered by T1 (legacy scaffolds to {} then fills).

# ── T4 (inv): non-interactive solo upgrade is byte-for-byte no-op ───────────
T4="${TMP_ROOT}/t4"; mkdir -p "${T4}"; init_project "${T4}"
MP4="$(mp_of "${T4}")"
[[ "$(preset_of "${MP4}")" == "solo" ]] || fail "T4: fresh init not solo"
before="$(shasum "${MP4}" | awk '{print $1}')"
run_upgrade "${T4}" || fail "T4: plain upgrade --yes failed (see ${T4}/upgrade.log)"
after="$(shasum "${MP4}" | awk '{print $1}')"
[[ "${before}" == "${after}" ]] || fail "T4: model-profiles.yaml mutated by no-flag solo upgrade (not byte-for-byte)"
for a in CLAUDE.md AGENTS.md GEMINI.md; do
  [[ -f "${T4}/${a}" ]] && { ! grep -q '^team_dispatch:' "${T4}/${a}" || fail "T4: ${a} got team_dispatch on solo upgrade (standalone lock broken)"; }
done
sel4="$(awk '/^configuration:/{c=1;next} c&&/^[[:space:]]+selected_runtime:/{v=$0;sub(/^[[:space:]]+selected_runtime:[[:space:]]*/,"",v);gsub(/["\047]/,"",v);sub(/[[:space:]]*#.*/,"",v);sub(/[[:space:]]*$/,"",v);print v;exit} c&&/^[A-Za-z_]/{c=0}' "${MP4}")"
for tok in lead worker researcher; do
  [[ "$(resolve "${MP4}" "${tok}")" == "${sel4}" ]] || fail "T4: solo '${tok}' no longer degrades to selected_runtime"
done

echo "test-team-upgrade-migration: OK"
