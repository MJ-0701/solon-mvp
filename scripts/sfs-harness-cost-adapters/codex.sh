#!/usr/bin/env bash
# Cost-signal adapter: Codex CLI rollout log (JSONL).
#
# Same contract as claude-code.sh (detect|emit, k=v schema=1). Format
# surveyed 2026-07-03 (unofficial, version-dependent):
#   - sessions live under a Y/M/D tree as rollout-*.jsonl; line 1 is
#     session_meta whose payload.cwd identifies the project;
#   - event_msg/token_count carries CUMULATIVE info.total_token_usage —
#     the last event wins; events are counted, never summed;
#   - input_tokens INCLUDES cached_input_tokens (fresh = input - cached);
#     no cache-write figure is reported (cache_write_tokens=0);
#   - model comes from turn_context payloads; with 2+ distinct models the
#     per-model token split is unknowable from the log, so models list as
#     name:0 (model_count still drives the model_mix signal);
#   - function_call names: apply_patch=edit, web_search/view_image=read,
#     exec_command and friends are neutral (could be either);
#   - no sidechain concept (0).
# Env: SFS_COST_LOG_DIR (tree root), SFS_COST_SESSION_FILE,
#      SFS_COST_FORCE_PARSER — same semantics as claude-code.sh.
# Aggregate token counts and tool names only — never message text; only the
# session file basename is printed.
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

session_file() {
  if [ -n "${SFS_COST_SESSION_FILE:-}" ]; then
    [ -f "${SFS_COST_SESSION_FILE}" ] || return 1
    printf '%s' "${SFS_COST_SESSION_FILE}"
    return 0
  fi
  local root="${SFS_COST_LOG_DIR:-${HOME}/.codex/sessions}" f
  [ -d "${root}" ] || return 1
  # Y/M/D path + timestamped filename => lexical order is chronological.
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    if head -1 "$f" 2>/dev/null | grep -Fq "\"cwd\":\"${PWD}\""; then
      printf '%s' "$f"
      return 0
    fi
  done <<EOF_FILES
$(find "${root}" -name 'rollout-*.jsonl' 2>/dev/null | sort -r | head -50)
EOF_FILES
  return 1
}

emit_jq() { # $1=file
  jq -rRn '
    reduce (inputs | fromjson? // empty) as $l (
      {u:0, tok:null, rd:0, ed:0, models:{}};
      (if ($l.type? // "") == "turn_context" and (($l.payload.model? // "") != "")
       then .models[$l.payload.model] = 1 else . end)
      | (if ($l.type? // "") == "event_msg"
           and (($l.payload.type? // "") == "token_count")
           and (($l.payload.info.total_token_usage? // null) != null)
         then .u += 1 | .tok = $l.payload.info.total_token_usage else . end)
      | (if ($l.type? // "") == "response_item"
           and (($l.payload.type? // "") == "function_call")
         then ($l.payload.name // "") as $n
           | (if $n == "apply_patch" then .ed += 1
              elif ($n == "web_search" or $n == "view_image") then .rd += 1
              else . end)
         else . end)
    )
    | if .u == 0 or .tok == null then halt_error(3) else . end
    | (.tok.input_tokens // 0) as $in_total
    | (.tok.cached_input_tokens // 0) as $cr
    | (($in_total - $cr) | if . < 0 then 0 else . end) as $fresh
    | (.tok.output_tokens // 0) as $out
    | (.models | keys | sort) as $mk
    | "usage_lines=\(.u)",
      "input_tokens=\($fresh)",
      "output_tokens=\($out)",
      "cache_read_tokens=\($cr)",
      "cache_write_tokens=0",
      "cache_read_ratio_pct=\(if $in_total > 0 then (100 * $cr / $in_total | floor) else 0 end)",
      "read_tool_uses=\(.rd)",
      "edit_tool_uses=\(.ed)",
      "sidechain_output_tokens=0",
      "sidechain_share_pct=0",
      "model_count=\($mk | length)",
      "models=\(if ($mk | length) == 1 then "\($mk[0]):\($out)"
                else ($mk | map("\(.):0") | join(",")) end)"
  ' < "$1"
}

emit_python3() { # $1=file
  python3 - "$1" <<'PYEOF'
import json, sys

u = rd = ed = 0
tok = None
models = {}
with open(sys.argv[1], encoding="utf-8", errors="replace") as fh:
    for line in fh:
        try:
            o = json.loads(line)
        except ValueError:
            continue
        if not isinstance(o, dict):
            continue
        p = o.get("payload")
        if not isinstance(p, dict):
            continue
        t = o.get("type")
        if t == "turn_context" and p.get("model"):
            models[p["model"]] = 1
        elif t == "event_msg" and p.get("type") == "token_count":
            info = p.get("info")
            if isinstance(info, dict) and isinstance(info.get("total_token_usage"), dict):
                u += 1
                tok = info["total_token_usage"]
        elif t == "response_item" and p.get("type") == "function_call":
            n = p.get("name") or ""
            if n == "apply_patch":
                ed += 1
            elif n in ("web_search", "view_image"):
                rd += 1

if u == 0 or tok is None:
    sys.exit(3)
in_total = tok.get("input_tokens") or 0
cr = tok.get("cached_input_tokens") or 0
fresh = max(in_total - cr, 0)
out = tok.get("output_tokens") or 0
mk = sorted(models)
print(f"usage_lines={u}")
print(f"input_tokens={fresh}")
print(f"output_tokens={out}")
print(f"cache_read_tokens={cr}")
print("cache_write_tokens=0")
print(f"cache_read_ratio_pct={100 * cr // in_total if in_total > 0 else 0}")
print(f"read_tool_uses={rd}")
print(f"edit_tool_uses={ed}")
print("sidechain_output_tokens=0")
print("sidechain_share_pct=0")
print(f"model_count={len(mk)}")
if len(mk) == 1:
    print(f"models={mk[0]}:{out}")
else:
    print("models=" + ",".join(f"{m}:0" for m in mk))
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
    printf 'runtime=codex\nschema=1\nsession_file=%s\n' "$(basename "${file}")"
    printf '%s\n' "${metrics}"
    ;;
  *)
    echo "usage: codex.sh detect|emit" >&2
    exit 2
    ;;
esac
