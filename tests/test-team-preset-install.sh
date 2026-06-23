#!/usr/bin/env bash
# Multi-agent team topology P2 — install --team preset headline lock.
#
# AC (design §7, P2 표면):
#   - `--team trio` 설치 → model-profiles 에 team_preset=trio + agent_runtime_bindings
#     (lead/worker/researcher) 가 채워지고, resolver 가 그 binding 으로 resolve 한다.
#   - 어댑터 3종(CLAUDE/AGENTS/GEMINI.md)에 `team_dispatch:` role-scoped rule 이
#     주입되고, frontmatter-only 가 유지된다(body 텍스트 0).
#   - `--team pair` 는 lead/worker 만, researcher 는 selected_runtime fallback.
#   - 기본(solo) 설치는 무변경: team_preset=solo, bindings `{}`, 어댑터에 dispatch 키 부재.
#   - OCP(§4.5 preset 신설): 카탈로그에 4번째 preset 추가 → preset-bindings 가 그
#     묶음을 방출(install/resolver 코드 diff 0).
#   - 잘못된 --team 값은 거부(exit 99).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
INSTALL="${DIST_DIR}/install.sh"
RESOLVER="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-team.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f "${INSTALL}" ]] || fail "install.sh not found"
[[ -f "${RESOLVER}" ]] || fail "resolver not found"

TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/sfs-team-preset.XXXXXX")"
cleanup() { rm -rf "${TMP_ROOT}"; }
trap cleanup EXIT

# Run install.sh locally into a fresh git project. Network/wiki/discovery off.
do_install() {
  local dir="$1"; shift
  ( cd "${dir}" \
    && git init -q \
    && git config user.email team-preset@solon.invalid \
    && git config user.name "Solon Team Preset Test" \
    && printf '# team preset\n' > README.md \
    && git add . && git commit -qm init ) >/dev/null 2>&1
  ( cd "${dir}" \
    && SFS_INSTALL_LLM_WIKI=0 SFS_SKIP_CLI_DISCOVERY=1 \
       bash "${INSTALL}" --yes --layout thin "$@" ) >"${dir}/install.log" 2>&1 </dev/null
}

resolve() {
  local dir="$1" token="$2"
  SFS_MODEL_PROFILES="${dir}/.sfs-local/model-profiles.yaml" \
    bash "${RESOLVER}" resolve-runtime "${token}"
}

mp_of()  { echo "$1/.sfs-local/model-profiles.yaml"; }
preset_of() { awk '/^team_preset:/ {v=$0; sub(/^team_preset:[[:space:]]*/,"",v); sub(/[[:space:]]*#.*/,"",v); gsub(/[[:space:]]/,"",v); print v; exit}' "$1"; }

assert_frontmatter_only() {
  local file="$1"
  [[ "$(sed -n '1p' "${file}")" == "---" ]] || fail "${file}: missing opening frontmatter"
  if awk '
    NR==1 && $0=="---" { in_fm=1; next }
    in_fm && $0=="---" { in_fm=0; seen=1; next }
    seen && $0 ~ /[^[:space:]]/ { found=1 }
    END { exit found ? 0 : 1 }
  ' "${file}"; then
    fail "${file}: team injection must stay in frontmatter (no body text)"
  fi
}

# ── trio ───────────────────────────────────────────────────────────────────
TRIO="${TMP_ROOT}/trio"; mkdir -p "${TRIO}"
do_install "${TRIO}" --team trio || fail "trio install failed (see ${TRIO}/install.log)"
MP="$(mp_of "${TRIO}")"
[[ -f "${MP}" ]] || fail "trio: model-profiles.yaml missing"
[[ "$(preset_of "${MP}")" == "trio" ]] || fail "trio: team_preset not trio"
grep -Eq '^agent_runtime_bindings:[[:space:]]*$' "${MP}" || fail "trio: bindings block not materialized (still inline?)"

[[ "$(resolve "${TRIO}" lead)" == "claude" ]]      || fail "trio: lead != claude"
[[ "$(resolve "${TRIO}" worker)" == "codex" ]]     || fail "trio: worker != codex"
[[ "$(resolve "${TRIO}" researcher)" == "antigravity" ]] || fail "trio: researcher != antigravity"
# unbound token still degrades to selected_runtime.
sel="$(awk '/^configuration:/{c=1;next} c&&/^[[:space:]]+selected_runtime:/{v=$0;sub(/^[[:space:]]+selected_runtime:[[:space:]]*/,"",v);gsub(/["\047]/,"",v);sub(/[[:space:]]*#.*/,"",v);sub(/[[:space:]]*$/,"",v);print v;exit} c&&/^[A-Za-z_]/{c=0}' "${MP}")"
[[ "$(resolve "${TRIO}" some-unmapped-role)" == "${sel}" ]] || fail "trio: unmapped role did not fall back to selected_runtime"

for a in CLAUDE.md AGENTS.md GEMINI.md; do
  f="${TRIO}/${a}"
  [[ -f "${f}" ]] || fail "trio: adapter ${a} missing"
  grep -q '^team_dispatch:' "${f}" || fail "trio: ${a} missing team_dispatch injection"
  grep -q 'preset: trio' "${f}"    || fail "trio: ${a} missing preset marker"
  grep -Fq 'sfs route' "${f}"      || fail "trio: ${a} missing dispatch helper reference"
  grep -Fq 'sfs team resolve-runtime' "${f}" || fail "trio: ${a} missing resolve-runtime reference"
  assert_frontmatter_only "${f}"
done

# ── pair ───────────────────────────────────────────────────────────────────
PAIR="${TMP_ROOT}/pair"; mkdir -p "${PAIR}"
do_install "${PAIR}" --team pair || fail "pair install failed (see ${PAIR}/install.log)"
[[ "$(preset_of "$(mp_of "${PAIR}")")" == "pair" ]] || fail "pair: team_preset not pair"
[[ "$(resolve "${PAIR}" lead)" == "claude" ]]   || fail "pair: lead != claude"
[[ "$(resolve "${PAIR}" worker)" == "codex" ]]  || fail "pair: worker != codex"
pair_sel="$(awk '/^configuration:/{c=1;next} c&&/^[[:space:]]+selected_runtime:/{v=$0;sub(/^[[:space:]]+selected_runtime:[[:space:]]*/,"",v);gsub(/["\047]/,"",v);sub(/[[:space:]]*#.*/,"",v);sub(/[[:space:]]*$/,"",v);print v;exit} c&&/^[A-Za-z_]/{c=0}' "$(mp_of "${PAIR}")")"
[[ "$(resolve "${PAIR}" researcher)" == "${pair_sel}" ]] || fail "pair: researcher should fall back (not bound)"

# ── solo (default) — zero behavior change ───────────────────────────────────
SOLO="${TMP_ROOT}/solo"; mkdir -p "${SOLO}"
do_install "${SOLO}" || fail "solo install failed (see ${SOLO}/install.log)"
MPS="$(mp_of "${SOLO}")"
[[ "$(preset_of "${MPS}")" == "solo" ]] || fail "solo: default team_preset not solo"
grep -Eq '^agent_runtime_bindings:[[:space:]]*\{\}[[:space:]]*$' "${MPS}" || fail "solo: bindings not empty {}"
solo_sel="$(awk '/^configuration:/{c=1;next} c&&/^[[:space:]]+selected_runtime:/{v=$0;sub(/^[[:space:]]+selected_runtime:[[:space:]]*/,"",v);gsub(/["\047]/,"",v);sub(/[[:space:]]*#.*/,"",v);sub(/[[:space:]]*$/,"",v);print v;exit} c&&/^[A-Za-z_]/{c=0}' "${MPS}")"
for token in lead worker researcher; do
  [[ "$(resolve "${SOLO}" "${token}")" == "${solo_sel}" ]] || fail "solo: ${token} not selected_runtime (behavior changed!)"
done
for a in CLAUDE.md AGENTS.md GEMINI.md; do
  ! grep -q '^team_dispatch:' "${SOLO}/${a}" || fail "solo: ${a} unexpectedly carries team_dispatch (not zero-change)"
  assert_frontmatter_only "${SOLO}/${a}"
done

# ── upgrade --team re-apply (solo install → upgrade pivots to trio) ──────────
UPG="${TMP_ROOT}/upgrade"; mkdir -p "${UPG}"
do_install "${UPG}" || fail "upgrade-case base install failed"
[[ "$(preset_of "$(mp_of "${UPG}")")" == "solo" ]] || fail "upgrade-case: base install not solo"
( cd "${UPG}" && SFS_SKIP_CLI_DISCOVERY=1 SFS_MODEL_PROFILE_PROMPT=0 \
    bash "${DIST_DIR}/upgrade.sh" --yes --team trio ) >"${UPG}/upgrade.log" 2>&1 </dev/null \
  || fail "upgrade --team trio failed (see ${UPG}/upgrade.log)"
[[ "$(preset_of "$(mp_of "${UPG}")")" == "trio" ]] || fail "upgrade: team_preset not pivoted to trio"
[[ "$(resolve "${UPG}" lead)" == "claude" ]]   || fail "upgrade: lead != claude after pivot"
[[ "$(resolve "${UPG}" worker)" == "codex" ]]  || fail "upgrade: worker != codex after pivot"
for a in CLAUDE.md AGENTS.md GEMINI.md; do
  grep -q '^team_dispatch:' "${UPG}/${a}" || fail "upgrade: ${a} missing team_dispatch after pivot"
  # idempotent: exactly one injection (re-run must not duplicate).
  [[ "$(grep -c '^team_dispatch:' "${UPG}/${a}")" == "1" ]] || fail "upgrade: ${a} has duplicate team_dispatch"
done
# a second upgrade --team trio must not double-inject (idempotency lock).
( cd "${UPG}" && SFS_SKIP_CLI_DISCOVERY=1 SFS_MODEL_PROFILE_PROMPT=0 \
    bash "${DIST_DIR}/upgrade.sh" --yes --team trio ) >/dev/null 2>&1 </dev/null || true
[[ "$(grep -c '^team_dispatch:' "${UPG}/CLAUDE.md")" == "1" ]] || fail "upgrade: re-run duplicated team_dispatch (not idempotent)"

# ── OCP: 4th preset = catalog edit only, code diff 0 ────────────────────────
# Snapshot the surfaces that must NOT change to add a preset.
install_before="$(shasum "${INSTALL}" | awk '{print $1}')"
resolver_before="$(shasum "${RESOLVER}" | awk '{print $1}')"
OCP_MP="${TMP_ROOT}/ocp-model-profiles.yaml"
cp "${MP}" "${OCP_MP}"   # any materialized profile carries the catalog
# Append a brand-new 4th preset under team_preset_catalog (pure data).
awk '
  /^team_preset_catalog:/ {
    print
    print "  quad:"
    print "    lead: claude"
    print "    worker: codex"
    print "    researcher: antigravity"
    print "    helper: mycli"
    next
  }
  { print }
' "${OCP_MP}" > "${OCP_MP}.tmp" && mv "${OCP_MP}.tmp" "${OCP_MP}"
quad_out="$(SFS_MODEL_PROFILES="${OCP_MP}" bash "${RESOLVER}" preset-bindings quad)"
echo "${quad_out}" | grep -Fxq 'helper: mycli' || fail "OCP: new catalog preset 'quad' not emitted by resolver"
echo "${quad_out}" | grep -Fxq 'lead: claude'  || fail "OCP: quad preset missing lead binding"
[[ "$(shasum "${INSTALL}" | awk '{print $1}')" == "${install_before}" ]] || fail "OCP: install.sh changed to add a preset (should be data-only)"
[[ "$(shasum "${RESOLVER}" | awk '{print $1}')" == "${resolver_before}" ]] || fail "OCP: resolver changed to add a preset (should be data-only)"

# ── invalid --team rejected ─────────────────────────────────────────────────
BAD="${TMP_ROOT}/bad"; mkdir -p "${BAD}"
( cd "${BAD}" && git init -q && git config user.email b@b.invalid && git config user.name b && echo x>README.md && git add . && git commit -qm init ) >/dev/null 2>&1
# Wrap in a subshell cd — validation exits before any write today, but never run
# install in the test's own cwd (= repo root under run-all): defense against
# silent repo-root pollution if a future bad value gets past arg validation.
if ( cd "${BAD}" && SFS_INSTALL_LLM_WIKI=0 SFS_SKIP_CLI_DISCOVERY=1 \
      bash "${INSTALL}" --yes --layout thin --team quintet ) >/dev/null 2>&1 </dev/null; then
  fail "invalid --team value was accepted (expected non-zero exit)"
fi

echo "test-team-preset-install: OK"
