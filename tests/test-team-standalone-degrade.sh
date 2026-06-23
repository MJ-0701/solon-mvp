#!/usr/bin/env bash
# Multi-agent team topology — standalone regression lock (AC4 + AC6).
#
# Standalone guarantee: team/dispatch 데이터를 전부 떼어내도 solo 로 모든 것이
# 동작해야 한다. resolution 은 dispatch off 일 때 항상 selected_runtime 으로
# 정상 degrade 하고, registry/bindings 가 통째로 없어도 resolver 가 죽지 않는다.
#
#   AC6 — 미배정 token 은 selected_runtime 으로 fallback.
#   AC4 — team_preset/runtime_registry/agent_runtime_bindings 섹션 제거 후에도
#         resolve-runtime 이 selected_runtime 을 돌려주고 exit 0 (crash 없음).
#   solo default — install 직후(solo)엔 모든 token 이 selected_runtime 으로 resolve.
#
# (run-all 전체가 solo 에서 green 인지는 suite 차원에서 검증된다 — 본 테스트는
#  resolver 의 degrade 계약만 잠근다.)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
RESOLVER="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-team.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f "${RESOLVER}" ]] || fail "resolver not found: ${RESOLVER}"

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-team-standalone.XXXXXX")"
cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

cd "${TMP_DIR}"
git init -q
git config user.email "team-standalone@solon.invalid"
git config user.name "Solon Team Standalone Test"
printf '# team standalone\n' > README.md
git add . && git commit -qm "init"
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1

MP=".sfs-local/model-profiles.yaml"
[[ -f "${MP}" ]] || fail "init did not produce ${MP}"
# Resolver runs from the global runtime (thin layout); invoke dist script with
# cwd = consumer project root so it reads ./.sfs-local/model-profiles.yaml.

# Default install must be solo — the zero-behavior-change guarantee.
preset="$(awk '/^team_preset:/ {v=$0; sub(/^team_preset:[[:space:]]*/,"",v); sub(/[[:space:]]*#.*/,"",v); gsub(/[[:space:]]/,"",v); print v; exit}' "${MP}")"
[[ "${preset}" == "solo" ]] || fail "default install not solo (team_preset='${preset}')"

selected="$(awk '
  /^configuration:/ { inc=1; next }
  inc && /^[[:space:]]+selected_runtime:/ {
    v=$0; sub(/^[[:space:]]+selected_runtime:[[:space:]]*/, "", v)
    gsub(/["\047]/, "", v); sub(/[[:space:]]*#.*/, "", v); sub(/[[:space:]]*$/, "", v)
    print v; exit
  }
  inc && /^[A-Za-z_]/ { inc=0 }
' "${MP}")"
[[ -n "${selected}" ]] || fail "could not read configuration.selected_runtime"

# ── solo default: every token resolves to selected_runtime ─────────────────
for token in lead worker researcher ceo implementation-worker some-unmapped-role; do
  got="$(bash "${RESOLVER}" resolve-runtime "${token}")"
  [[ "${got}" == "${selected}" ]] || \
    fail "solo: token '${token}' resolved to '${got}', expected selected_runtime '${selected}'"
done

# ── AC6: explicit binding still falls back when token is unbound ────────────
# Seed only a lead binding; an unbound token must fall back to selected_runtime.
awk '
  /^agent_runtime_bindings:/ { print "agent_runtime_bindings:"; print "  lead:        codex"; skip=1; next }
  skip && /^[[:space:]]+[A-Za-z_]+:[[:space:]]/ { next }
  skip && /^[[:space:]]*$/ { next }
  skip { skip=0 }
  { print }
' "${MP}" > "${MP}.tmp" && mv "${MP}.tmp" "${MP}"
got="$(bash "${RESOLVER}" resolve-runtime researcher)"
[[ "${got}" == "${selected}" ]] || \
  fail "AC6: unbound 'researcher' did not fall back to selected_runtime (got '${got}')"

# ── AC4: strip ALL team/dispatch data — resolver must still degrade cleanly ──
awk '
  /^team_preset:/ { next }
  /^unassigned_role_policy:/ { next }
  /^runtime_registry:/ { drop=1; next }
  /^agent_runtime_bindings:/ { drop=1; next }
  /^team_preset_catalog:/ { drop=1; next }
  drop && /^[[:space:]]/ { next }
  drop && /^[[:space:]]*#/ { next }
  drop && /^[[:space:]]*$/ { next }
  drop { drop=0 }
  { print }
' "${MP}" > "${MP}.tmp" && mv "${MP}.tmp" "${MP}"

grep -q '^runtime_registry:' "${MP}" && fail "strip failed: runtime_registry still present"
grep -q '^agent_runtime_bindings:' "${MP}" && fail "strip failed: agent_runtime_bindings still present"
grep -q '^team_preset_catalog:' "${MP}" && fail "strip failed: team_preset_catalog still present"

# resolve-runtime must not crash and must return selected_runtime.
if ! got="$(bash "${RESOLVER}" resolve-runtime lead)"; then
  fail "AC4: resolver crashed after team data removed (non-zero exit)"
fi
[[ "${got}" == "${selected}" ]] || \
  fail "AC4: post-strip resolve did not degrade to selected_runtime (got '${got}')"

# resolve-invoke for a now-absent registry must degrade quietly (empty, exit 0),
# never crash — dispatch is off in standalone so callers never reach it anyway.
if ! out="$(bash "${RESOLVER}" resolve-invoke "${selected}")"; then
  fail "AC4: resolve-invoke crashed with registry absent"
fi
[[ -z "${out}" ]] || fail "AC4: resolve-invoke returned '${out}' with registry absent (expected empty)"

echo "test-team-standalone-degrade: OK"
