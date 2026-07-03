#!/usr/bin/env bash
# Cost-signal adapter: Gemini CLI chat session log (JSONL).
#
# Same contract as claude-code.sh (detect|emit, k=v schema=1). Format
# surveyed 2026-07-03 (unofficial, version-dependent):
#   - the CLI's projects registry (a JSON map of absolute project path ->
#     slug under its tmp tree) locates <tmp>/<slug>/chats/session-*.jsonl;
#   - "gemini"-typed lines carry per-turn model + tokens
#     {input,output,cached,thoughts,tool,total}; input INCLUDES cached
#     (fresh = input - cached); thoughts are reasoning output and count
#     into output_tokens; per-turn figures are summed;
#   - no cache-write figure (cache_write_tokens=0), no sidechain concept;
#   - tool-call names are not persisted in the chat log, so read/edit tool
#     counts stay 0 — honest absence, not a measurement;
#   - checkpoint fragments (untyped lines) and malformed lines are skipped.
# Env: SFS_COST_LOG_DIR (the chats dir itself), SFS_COST_SESSION_FILE,
#      SFS_COST_FORCE_PARSER — same semantics as claude-code.sh.
# Aggregate token counts only — never message text; only the session file
# basename is printed.
set -u

MODE="${1:-}"

pick_parser() {
  case "${SFS_COST_FORCE_PARSER:-auto}" in
    jq) command -v jq >/dev/null 2>&1 && { printf 'jq'; return 0; } || return 1 ;;
    python3) command -v python3 >/dev/null 2>&1 && { printf 'python3'; return 0; } || return 1 ;;
    none) return 1 ;;
    auto)
      if command -v jq >/dev/null 2>&1; then printf 'jq'; return 0; fi
      if command -v python3 >/dev/null 2>&1; then printf 'python3'; return 0; fi
      return 1
      ;;
    *) return 1 ;;
  esac
}

project_chats_dir() {
  if [ -n "${SFS_COST_LOG_DIR:-}" ]; then
    printf '%s' "${SFS_COST_LOG_DIR}"
    return 0
  fi
  local reg="${HOME}/.gemini/projects.json" slug=""
  [ -f "${reg}" ] || return 1
  if command -v jq >/dev/null 2>&1; then
    slug="$(jq -r --arg p "${PWD}" '.projects[$p] // empty' "${reg}" 2>/dev/null)"
  elif command -v python3 >/dev/null 2>&1; then
    slug="$(python3 -c '
import json, sys
try:
    o = json.load(open(sys.argv[1]))
except Exception:
    sys.exit(0)
print((o.get("projects") or {}).get(sys.argv[2]) or "")
' "${reg}" "${PWD}" 2>/dev/null)"
  fi
  [ -n "${slug}" ] || return 1
  printf '%s/.gemini/tmp/%s/chats' "${HOME}" "${slug}"
}

session_file() {
  if [ -n "${SFS_COST_SESSION_FILE:-}" ]; then
    [ -f "${SFS_COST_SESSION_FILE}" ] || return 1
    printf '%s' "${SFS_COST_SESSION_FILE}"
    return 0
  fi
  local dir file
  dir="$(project_chats_dir)" || return 1
  [ -d "${dir}" ] || return 1
  file="$(ls -t "${dir}"/session-*.jsonl 2>/dev/null | head -1)"
  [ -n "${file}" ] && [ -f "${file}" ] || return 1
  printf '%s' "${file}"
}

emit_jq() { # $1=file
  jq -rRn '
    reduce (inputs | fromjson? // empty) as $l (
      {u:0, inp:0, cr:0, out:0, models:{}};
      if ($l.type? // "") == "gemini" and (($l.tokens? // null) != null) then
        (($l.tokens.output // 0) + ($l.tokens.thoughts // 0)) as $o
        | ($l.model // "unknown") as $m
        | .u += 1
        | .inp += ($l.tokens.input // 0)
        | .cr += ($l.tokens.cached // 0)
        | .out += $o
        | .models[$m] = ((.models[$m] // 0) + $o)
      else . end
    )
    | if .u == 0 then halt_error(3) else . end
    | ((.inp - .cr) | if . < 0 then 0 else . end) as $fresh
    | "usage_lines=\(.u)",
      "input_tokens=\($fresh)",
      "output_tokens=\(.out)",
      "cache_read_tokens=\(.cr)",
      "cache_write_tokens=0",
      "cache_read_ratio_pct=\(if .inp > 0 then (100 * .cr / .inp | floor) else 0 end)",
      "read_tool_uses=0",
      "edit_tool_uses=0",
      "sidechain_output_tokens=0",
      "sidechain_share_pct=0",
      "model_count=\(.models | length)",
      "models=\(.models | to_entries | sort_by(.key) | map("\(.key):\(.value)") | join(","))"
  ' < "$1"
}

emit_python3() { # $1=file
  python3 - "$1" <<'PYEOF'
import json, sys

u = inp = cr = out = 0
models = {}
with open(sys.argv[1], encoding="utf-8", errors="replace") as fh:
    for line in fh:
        try:
            o = json.loads(line)
        except ValueError:
            continue
        if not isinstance(o, dict) or o.get("type") != "gemini":
            continue
        t = o.get("tokens")
        if not isinstance(t, dict):
            continue
        u += 1
        inp += t.get("input") or 0
        cr += t.get("cached") or 0
        turn_out = (t.get("output") or 0) + (t.get("thoughts") or 0)
        out += turn_out
        key = o.get("model") or "unknown"
        models[key] = models.get(key, 0) + turn_out

if u == 0:
    sys.exit(3)
fresh = max(inp - cr, 0)
print(f"usage_lines={u}")
print(f"input_tokens={fresh}")
print(f"output_tokens={out}")
print(f"cache_read_tokens={cr}")
print("cache_write_tokens=0")
print(f"cache_read_ratio_pct={100 * cr // inp if inp > 0 else 0}")
print("read_tool_uses=0")
print("edit_tool_uses=0")
print("sidechain_output_tokens=0")
print("sidechain_share_pct=0")
print(f"model_count={len(models)}")
print("models=" + ",".join(f"{k}:{v}" for k, v in sorted(models.items())))
PYEOF
}

case "${MODE}" in
  detect)
    pick_parser >/dev/null || exit 1
    session_file >/dev/null || exit 1
    exit 0
    ;;
  emit)
    parser="$(pick_parser)" || exit 1
    file="$(session_file)" || exit 1
    if [ "${parser}" = "jq" ]; then
      metrics="$(emit_jq "${file}" 2>/dev/null)" || exit 1
    else
      metrics="$(emit_python3 "${file}")" || exit 1
    fi
    printf 'runtime=gemini\nschema=1\nsession_file=%s\n' "$(basename "${file}")"
    printf '%s\n' "${metrics}"
    ;;
  *)
    echo "usage: gemini.sh detect|emit" >&2
    exit 2
    ;;
esac
