#!/usr/bin/env bash
# DESIGN-2026-07-03 P2 follow-up — Codex + Gemini cost-signal adapters.
#
# Same contract as claude-code.sh (detect|emit, k=v schema=1, decision D2
# detect-fail degrade, signal-only): grounded in real formats surveyed
# 2026-07-03:
#   codex: rollout-*.jsonl under a Y/M/D tree; session_meta.payload.cwd is
#          the project key; token_count events carry CUMULATIVE
#          total_token_usage (last event wins, never summed); model comes
#          from turn_context; apply_patch=edit, web_search=read,
#          exec_command=neutral.
#   gemini: chats/session-*.jsonl; "gemini"-typed lines carry per-turn
#          tokens {input,output,cached,thoughts}; input includes cached;
#          tool names are not persisted (read/edit stay 0, honestly).
# Doctor gains SFS_COST_RUNTIME to pin one adapter. Synthetic fixtures only.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
CODEX="${DIST_DIR}/scripts/sfs-harness-cost-adapters/codex.sh"
GEMINI="${DIST_DIR}/scripts/sfs-harness-cost-adapters/gemini.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
has() { grep -Fq -- "$2" <<<"$1" || fail "$3: missing '$2'"; }

for a in "${CODEX}" "${GEMINI}"; do
  [[ -f "${a}" ]] || fail "missing adapter $(basename "${a}")"
  if grep -Eq '/Users/|/home/[a-z]' "${a}"; then
    fail "$(basename "${a}") leaks an absolute private path"
  fi
done

tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/sfs-cost-multi.XXXXXX")"
trap 'rm -rf "${tmp_root}"' EXIT

# ── Codex fixture: cumulative token_count, 2 model tiers, mixed tools ──
proj="${tmp_root}/proj"
mkdir -p "${proj}"
# Normalize (mktemp templates can carry '//' from a trailing-slash TMPDIR);
# the fixture cwd string must equal $PWD as the adapter will see it.
proj="$(cd "${proj}" && pwd)"
cx_dir="${tmp_root}/codex-logs/2026/07/03"
mkdir -p "${cx_dir}"
cx_file="${cx_dir}/rollout-2026-07-03T00-00-00-test.jsonl"
cat > "${cx_file}" <<EOF
{"type":"session_meta","payload":{"id":"t","cwd":"${proj}","cli_version":"0.0.0","originator":"test"}}
{"type":"turn_context","payload":{"turn_id":"1","cwd":"${proj}","model":"gpt-5.4-codex","effort":"low"}}
{"type":"event_msg","payload":{"type":"token_count","info":{"total_token_usage":{"input_tokens":1000,"cached_input_tokens":600,"output_tokens":100,"reasoning_output_tokens":40,"total_tokens":1100}}}}
{"type":"response_item","payload":{"type":"function_call","name":"apply_patch","arguments":"{}"}}
{"type":"response_item","payload":{"type":"function_call","name":"web_search","arguments":"{}"}}
{"type":"response_item","payload":{"type":"function_call","name":"exec_command","arguments":"{}"}}
{"type":"turn_context","payload":{"turn_id":"2","cwd":"${proj}","model":"gpt-5.5","effort":"high"}}
{oops
{"type":"event_msg","payload":{"type":"token_count","info":{"total_token_usage":{"input_tokens":16160,"cached_input_tokens":13000,"output_tokens":1800,"reasoning_output_tokens":500,"total_tokens":17960}}}}
EOF

expected_codex="runtime=codex
schema=1
session_file=rollout-2026-07-03T00-00-00-test.jsonl
usage_lines=2
input_tokens=3160
output_tokens=1800
cache_read_tokens=13000
cache_write_tokens=0
cache_read_ratio_pct=80
read_tool_uses=1
edit_tool_uses=1
sidechain_output_tokens=0
sidechain_share_pct=0
model_count=2
models=gpt-5.4-codex:0,gpt-5.5:0"

# A lexically-newer rollout for ANOTHER project must not win cwd matching.
other_dir="${tmp_root}/codex-logs/2026/07/04"
mkdir -p "${other_dir}"
printf '%s\n' '{"type":"session_meta","payload":{"id":"o","cwd":"/somewhere/else"}}' \
  > "${other_dir}/rollout-2026-07-04T00-00-00-other.jsonl"

run_codex() { # $1=parser
  (cd "${proj}" && SFS_COST_LOG_DIR="${tmp_root}/codex-logs" SFS_COST_FORCE_PARSER="$1" \
    bash "${CODEX}" emit)
}
if command -v python3 >/dev/null 2>&1; then
  out="$(run_codex python3)"
  [[ "${out}" == "${expected_codex}" ]] || fail "codex python3 emit mismatch:
--- expected ---
${expected_codex}
--- got ---
${out}"
fi
if command -v jq >/dev/null 2>&1; then
  out="$(run_codex jq)"
  [[ "${out}" == "${expected_codex}" ]] || fail "codex jq emit mismatch:
--- expected ---
${expected_codex}
--- got ---
${out}"
fi

# cwd mismatch -> detect fail (degrade), never an error.
if (cd "${tmp_root}" && SFS_COST_LOG_DIR="${tmp_root}/codex-logs" bash "${CODEX}" detect >/dev/null 2>&1); then
  fail "codex detect must fail when no session matches the cwd"
fi

# ── Gemini fixture: per-turn tokens, single model, checkpoint noise ────
gm_dir="${tmp_root}/gemini-chats"
mkdir -p "${gm_dir}"
cat > "${gm_dir}/session-2026-07-03T00-00-test.jsonl" <<'EOF'
{"sessionId":"s","type":"user","content":{"role":"user"},"timestamp":"2026-07-03T00:00:00Z"}
{"sessionId":"s","type":"gemini","model":"gemini-3-pro","tokens":{"input":5000,"output":400,"cached":4000,"thoughts":100,"tool":0,"total":5500}}
{"$set":{"kind":"checkpoint"}}
{oops
{"sessionId":"s","type":"gemini","model":"gemini-3-pro","tokens":{"input":7000,"output":300,"cached":5000,"thoughts":0,"tool":0,"total":7300}}
EOF

expected_gemini="runtime=gemini
schema=1
session_file=session-2026-07-03T00-00-test.jsonl
usage_lines=2
input_tokens=3000
output_tokens=800
cache_read_tokens=9000
cache_write_tokens=0
cache_read_ratio_pct=75
read_tool_uses=0
edit_tool_uses=0
sidechain_output_tokens=0
sidechain_share_pct=0
model_count=1
models=gemini-3-pro:800"

run_gemini() { # $1=parser
  SFS_COST_LOG_DIR="${gm_dir}" SFS_COST_FORCE_PARSER="$1" bash "${GEMINI}" emit
}
if command -v python3 >/dev/null 2>&1; then
  out="$(run_gemini python3)"
  [[ "${out}" == "${expected_gemini}" ]] || fail "gemini python3 emit mismatch:
--- expected ---
${expected_gemini}
--- got ---
${out}"
fi
if command -v jq >/dev/null 2>&1; then
  out="$(run_gemini jq)"
  [[ "${out}" == "${expected_gemini}" ]] || fail "gemini jq emit mismatch:
--- expected ---
${expected_gemini}
--- got ---
${out}"
fi
command -v jq >/dev/null 2>&1 || command -v python3 >/dev/null 2>&1 \
  || fail "test host needs jq or python3"

# schema drift: gemini file with no tokens anywhere -> emit degrades.
drift="${tmp_root}/gemini-drift"
mkdir -p "${drift}"
printf '%s\n' '{"type":"gemini","model":"m"}' > "${drift}/session-x.jsonl"
if SFS_COST_LOG_DIR="${drift}" bash "${GEMINI}" emit >/dev/null 2>&1; then
  fail "gemini emit must fail (degrade) when no tokens fields are present"
fi

# ── Doctor integration: SFS_COST_RUNTIME pins one adapter ──────────────
cd "${proj}"
git init -q && git config user.email "m@solon.invalid" && git config user.name "M"
printf '# t\n' > README.md
git add . && git commit -qm "init"
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1

out_cx="$(SFS_DIST_DIR="${DIST_DIR}" SFS_COST_RUNTIME=codex \
  SFS_COST_LOG_DIR="${tmp_root}/codex-logs" \
  bash "${DIST_DIR}/scripts/sfs-harness.sh" doctor 2>&1 || true)"
has "${out_cx}" "cost-signal: runtime=codex" "doctor picks the codex adapter"
has "${out_cx}" "cache_read_ratio=80%" "codex cache ratio surfaces"
has "${out_cx}" "model_mix" "codex 2-tier session raises model_mix"

out_gm="$(SFS_DIST_DIR="${DIST_DIR}" SFS_COST_RUNTIME=gemini \
  SFS_COST_LOG_DIR="${gm_dir}" \
  bash "${DIST_DIR}/scripts/sfs-harness.sh" doctor 2>&1 || true)"
has "${out_gm}" "cost-signal: runtime=gemini" "doctor picks the gemini adapter"
has "${out_gm}" "cache_read_ratio=75%" "gemini cache ratio surfaces"

# pinned runtime with no source -> degrade line, and claude adapter must
# NOT answer for a pinned foreign runtime.
out_pin="$(SFS_DIST_DIR="${DIST_DIR}" SFS_COST_RUNTIME=codex \
  SFS_COST_LOG_DIR="${gm_dir}" \
  bash "${DIST_DIR}/scripts/sfs-harness.sh" doctor 2>&1 || true)"
has "${out_pin}" "no cost signal source" "pinned runtime without source degrades"

echo "test-harness-cost-adapter-codex-gemini: OK"
