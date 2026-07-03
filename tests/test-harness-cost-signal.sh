#!/usr/bin/env bash
# DESIGN-2026-07-03 P2 (cost-signal-readiness-adapter) — headline.
#
# Locks the session-log cost-signal seam, decisions confirmed 2026-07-03:
#   D1 entry point = doctor section (no new subcommand)
#   D2 unsupported schema / missing parser / no log -> detect-fail degrade
#      ("no cost signal source"), never an error
#   D3+: signal-only (ALT-INV-3) — cost signals are info/ok only and NEVER
#      change doctor's exit code
# Adapter contract: scripts/sfs-harness-cost-adapters/<runtime>.sh detect|emit,
# emit = k=v lines (runtime= / schema=1 / metrics). jq and python3 parsers must
# agree byte-for-byte. Synthetic fixtures only — never a real session log.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
ADAPTER="${DIST_DIR}/scripts/sfs-harness-cost-adapters/claude-code.sh"
TOKEN_POLICY="${DIST_DIR}/templates/.sfs-local-template/context/policies/token-harness.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
has() { grep -Fq -- "$2" <<<"$1" || fail "$3: missing '$2'"; }

[[ -f "${ADAPTER}" ]] || fail "missing adapter scripts/sfs-harness-cost-adapters/claude-code.sh"
grep -Fq "signal-only advisories" "${TOKEN_POLICY}" \
  || fail "token-harness must route the cost-signal advisory (anchor 'signal-only advisories')"
# No private absolute path may leak into the shipped adapter.
if grep -Eq '/Users/|/home/[a-z]' "${ADAPTER}"; then
  fail "cost adapter leaks an absolute private path"
fi

tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/sfs-cost-signal.XXXXXX")"
trap 'rm -rf "${tmp_root}"' EXIT

# ── Fixture A: mixed session (2 model tiers, sidechain, malformed line) ──
fx_a="${tmp_root}/logs-a"
mkdir -p "${fx_a}"
cat > "${fx_a}/session-a.jsonl" <<'EOF'
{"type":"queue-operation","operation":"enqueue","timestamp":"2026-07-03T00:00:00Z"}
{"type":"assistant","isSidechain":false,"version":"2.1.0","message":{"model":"claude-fable-5","usage":{"input_tokens":100,"output_tokens":1000,"cache_read_input_tokens":5000,"cache_creation_input_tokens":2000},"content":[{"type":"text","text":"x"},{"type":"tool_use","name":"Read","id":"1","input":{}},{"type":"tool_use","name":"Grep","id":"2","input":{}}]}}
{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":"1"}]}}
{"type":"assistant","message":{"model":"claude-fable-5","usage":{"input_tokens":50,"output_tokens":500,"cache_read_input_tokens":8000,"cache_creation_input_tokens":0},"content":[{"type":"tool_use","name":"Edit","id":"3","input":{}}]}}
{"type":"assistant","isSidechain":true,"message":{"model":"claude-haiku-4-5","usage":{"input_tokens":10,"output_tokens":300,"cache_read_input_tokens":0,"cache_creation_input_tokens":1000},"content":[{"type":"tool_use","name":"Read","id":"4","input":{}}]}}
{oops
{"type":"assistant","message":{"model":"claude-fable-5","content":[{"type":"text","text":"no usage"}]}}
EOF

expected_a="runtime=claude-code
schema=1
session_file=session-a.jsonl
usage_lines=3
input_tokens=160
output_tokens=1800
cache_read_tokens=13000
cache_write_tokens=3000
cache_read_ratio_pct=80
read_tool_uses=3
edit_tool_uses=1
sidechain_output_tokens=300
sidechain_share_pct=16
model_count=2
models=claude-fable-5:1500,claude-haiku-4-5:300"

# ── Adapter unit: exact k=v output, parser parity, latest-file pick ─────
run_emit() { # $1=parser
  SFS_COST_LOG_DIR="${fx_a}" SFS_COST_FORCE_PARSER="$1" bash "${ADAPTER}" emit
}

if command -v python3 >/dev/null 2>&1; then
  out_py="$(run_emit python3)"
  [[ "${out_py}" == "${expected_a}" ]] \
    || fail "python3 emit mismatch:
--- expected ---
${expected_a}
--- got ---
${out_py}"
fi
if command -v jq >/dev/null 2>&1; then
  out_jq="$(run_emit jq)"
  [[ "${out_jq}" == "${expected_a}" ]] \
    || fail "jq emit mismatch:
--- expected ---
${expected_a}
--- got ---
${out_jq}"
fi
command -v jq >/dev/null 2>&1 || command -v python3 >/dev/null 2>&1 \
  || fail "test host needs jq or python3"

# latest-file pick: an older sibling jsonl must not win.
printf '%s\n' '{"type":"assistant","message":{"model":"old","usage":{"input_tokens":1,"output_tokens":1,"cache_read_input_tokens":0,"cache_creation_input_tokens":0},"content":[]}}' \
  > "${fx_a}/session-old.jsonl"
touch -t 200001010000 "${fx_a}/session-old.jsonl"
out_latest="$(SFS_COST_LOG_DIR="${fx_a}" bash "${ADAPTER}" emit)"
has "${out_latest}" "session_file=session-a.jsonl" "latest jsonl must be selected"

# ── Fixture B: exploration-heavy, cold-cache, no sidechain, big output ──
fx_b="${tmp_root}/logs-b"
mkdir -p "${fx_b}"
i=0
while [ "${i}" -lt 25 ]; do
  printf '%s\n' '{"type":"assistant","message":{"model":"claude-fable-5","usage":{"input_tokens":1000,"output_tokens":3000,"cache_read_input_tokens":0,"cache_creation_input_tokens":0},"content":[{"type":"tool_use","name":"Read","id":"r","input":{}}]}}'
  i=$((i + 1))
done > "${fx_b}/session-b.jsonl"

# ── Fixture C: schema drift (no usage anywhere) -> emit must degrade ────
fx_c="${tmp_root}/logs-c"
mkdir -p "${fx_c}"
printf '%s\n' '{"type":"assistant","message":{"model":"claude-fable-5","content":[]}}' \
  > "${fx_c}/session-c.jsonl"
if SFS_COST_LOG_DIR="${fx_c}" bash "${ADAPTER}" emit >/dev/null 2>&1; then
  fail "emit must fail (degrade) when no known usage fields are present"
fi

# ── Doctor integration: fixtures through the real doctor ───────────────
proj="${tmp_root}/proj"
mkdir -p "${proj}"
cd "${proj}"
git init -q
git config user.email "cost@solon.invalid"
git config user.name "Solon Cost Test"
printf '# t\n' > README.md
git add . && git commit -qm "init"
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1

run_doctor() { # $1=log dir; echoes output, appends "rc=<n>" last line
  local rc=0 out
  out="$(SFS_DIST_DIR="${DIST_DIR}" SFS_COST_LOG_DIR="$1" \
    bash "${DIST_DIR}/scripts/sfs-harness.sh" doctor 2>&1)" || rc=$?
  printf '%s\nrc=%d\n' "${out}" "${rc}"
}

out_a="$(run_doctor "${fx_a}")"
has "${out_a}" "Cost Signals (Session Log)" "doctor cost section"
has "${out_a}" "cost-signal: runtime=claude-code" "doctor headline metric line"
has "${out_a}" "cache_read_ratio=80%" "doctor cache ratio"
has "${out_a}" "model_mix" "2 model tiers must raise the model_mix signal"
has "${out_a}" "token-harness.md" "model_mix signal routes to cache-prefix discipline"

out_b="$(run_doctor "${fx_b}")"
has "${out_b}" "cache_read_ratio 0% below" "cold cache must raise the low-cache signal"
has "${out_b}" "exploration-heavy session" "read-dominant session must raise the exploration signal"
has "${out_b}" "delegation unused" "no-sidechain big session must raise the delegation signal"
grep -qE '(⚠️|❌).*cost-signal' <<<"${out_b}" \
  && fail "cost signals must be info/ok only (found warn/fail cost-signal line)"

empty="${tmp_root}/logs-empty"
mkdir -p "${empty}"
out_none="$(run_doctor "${empty}")"
has "${out_none}" "no cost signal source" "empty log dir must degrade to no-source info"
out_np="$(SFS_DIST_DIR="${DIST_DIR}" SFS_COST_LOG_DIR="${fx_a}" SFS_COST_FORCE_PARSER=none \
  bash "${DIST_DIR}/scripts/sfs-harness.sh" doctor 2>&1 || true)"
has "${out_np}" "no cost signal source" "missing parser must degrade to no-source info"
out_c="$(run_doctor "${fx_c}")"
has "${out_c}" "no cost signal source" "schema drift must degrade to no-source info"

# ── Signal-only lock (ALT-INV-3): metrics never move the exit code ──────
rc_b="$(sed -n 's/^rc=//p' <<<"${out_b}")"
rc_none="$(sed -n 's/^rc=//p' <<<"${out_none}")"
[[ "${rc_b}" == "${rc_none}" ]] \
  || fail "signal-only violated: doctor rc with signals (${rc_b}) != rc without source (${rc_none})"

echo "test-harness-cost-signal: OK"
