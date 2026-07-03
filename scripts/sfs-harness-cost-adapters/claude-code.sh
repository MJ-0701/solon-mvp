#!/usr/bin/env bash
# Cost-signal adapter: Claude Code session log (JSONL).
#
# Contract (DESIGN-2026-07-03 P2, decisions D1/D2):
#   claude-code.sh detect  -> rc 0 when a log file and a parser are available
#   claude-code.sh emit    -> k=v metric lines on stdout; nonzero rc on any
#                             schema drift (no known usage fields) so the
#                             doctor degrades to "no cost signal source".
# Env:
#   SFS_COST_LOG_DIR       override the log directory (tests use this)
#   SFS_COST_SESSION_FILE  override the session file (skips latest-pick)
#   SFS_COST_FORCE_PARSER  jq | python3 | none (tests / degrade probes)
#
# The log format is UNOFFICIAL and version-dependent; this adapter reads only
# aggregate token counts and tool names — never message text — and prints only
# the session file basename, so no private path or content leaves the machine.
set -u

MODE="${1:-}"

log_dir() {
  if [ -n "${SFS_COST_LOG_DIR:-}" ]; then
    printf '%s' "${SFS_COST_LOG_DIR}"
    return
  fi
  # Claude Code slugs the project path by replacing '/' and '.' with '-'.
  printf '%s/.claude/projects/%s' "${HOME}" "$(printf '%s' "${PWD}" | sed 's|[/.]|-|g')"
}

session_file() {
  if [ -n "${SFS_COST_SESSION_FILE:-}" ]; then
    [ -f "${SFS_COST_SESSION_FILE}" ] || return 1
    printf '%s' "${SFS_COST_SESSION_FILE}"
    return 0
  fi
  local dir file
  dir="$(log_dir)"
  [ -d "${dir}" ] || return 1
  file="$(ls -t "${dir}"/*.jsonl 2>/dev/null | head -1)"
  [ -n "${file}" ] && [ -f "${file}" ] || return 1
  printf '%s' "${file}"
}

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

emit_jq() { # $1=file
  jq -rRn '
    ["Read","Grep","Glob","WebFetch","WebSearch"] as $reads
    | ["Edit","Write","MultiEdit","NotebookEdit"] as $edits
    | reduce (inputs | fromjson? // empty) as $l (
        {u:0, inp:0, out:0, cr:0, cw:0, so:0, rd:0, ed:0, models:{}};
        if ($l.type? // "") == "assistant" then
          (if ($l.message.usage? // null) != null then
            ($l.message.model // "unknown") as $m
            | .u += 1
            | .inp += ($l.message.usage.input_tokens // 0)
            | .out += ($l.message.usage.output_tokens // 0)
            | .cr  += ($l.message.usage.cache_read_input_tokens // 0)
            | .cw  += ($l.message.usage.cache_creation_input_tokens // 0)
            | (if ($l.isSidechain? // false) == true
               then .so += ($l.message.usage.output_tokens // 0) else . end)
            | .models[$m] = ((.models[$m] // 0) + ($l.message.usage.output_tokens // 0))
          else . end)
          | .rd += ([ ($l.message.content? // []) | if type == "array" then .[] else empty end
                      | select(type == "object" and .type == "tool_use")
                      | select(.name as $n | $reads | index($n)) ] | length)
          | .ed += ([ ($l.message.content? // []) | if type == "array" then .[] else empty end
                      | select(type == "object" and .type == "tool_use")
                      | select(.name as $n | $edits | index($n)) ] | length)
        else . end
      )
    | if .u == 0 then halt_error(3) else . end
    | (.inp + .cr + .cw) as $den
    | "usage_lines=\(.u)",
      "input_tokens=\(.inp)",
      "output_tokens=\(.out)",
      "cache_read_tokens=\(.cr)",
      "cache_write_tokens=\(.cw)",
      "cache_read_ratio_pct=\(if $den > 0 then (100 * .cr / $den | floor) else 0 end)",
      "read_tool_uses=\(.rd)",
      "edit_tool_uses=\(.ed)",
      "sidechain_output_tokens=\(.so)",
      "sidechain_share_pct=\(if .out > 0 then (100 * .so / .out | floor) else 0 end)",
      "model_count=\(.models | length)",
      "models=\(.models | to_entries | sort_by(.key) | map("\(.key):\(.value)") | join(","))"
  ' < "$1"
}

emit_python3() { # $1=file
  python3 - "$1" <<'PYEOF'
import json, sys

READS = {"Read", "Grep", "Glob", "WebFetch", "WebSearch"}
EDITS = {"Edit", "Write", "MultiEdit", "NotebookEdit"}

u = inp = out = cr = cw = so = rd = ed = 0
models = {}
with open(sys.argv[1], encoding="utf-8", errors="replace") as fh:
    for line in fh:
        try:
            o = json.loads(line)
        except ValueError:
            continue
        if not isinstance(o, dict) or o.get("type") != "assistant":
            continue
        m = o.get("message")
        if not isinstance(m, dict):
            continue
        usage = m.get("usage")
        if isinstance(usage, dict):
            u += 1
            inp += usage.get("input_tokens") or 0
            out += usage.get("output_tokens") or 0
            cr += usage.get("cache_read_input_tokens") or 0
            cw += usage.get("cache_creation_input_tokens") or 0
            if o.get("isSidechain") is True:
                so += usage.get("output_tokens") or 0
            key = m.get("model") or "unknown"
            models[key] = models.get(key, 0) + (usage.get("output_tokens") or 0)
        content = m.get("content")
        if isinstance(content, list):
            for b in content:
                if isinstance(b, dict) and b.get("type") == "tool_use":
                    if b.get("name") in READS:
                        rd += 1
                    elif b.get("name") in EDITS:
                        ed += 1

if u == 0:
    sys.exit(3)
den = inp + cr + cw
print(f"usage_lines={u}")
print(f"input_tokens={inp}")
print(f"output_tokens={out}")
print(f"cache_read_tokens={cr}")
print(f"cache_write_tokens={cw}")
print(f"cache_read_ratio_pct={100 * cr // den if den > 0 else 0}")
print(f"read_tool_uses={rd}")
print(f"edit_tool_uses={ed}")
print(f"sidechain_output_tokens={so}")
print(f"sidechain_share_pct={100 * so // out if out > 0 else 0}")
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
    printf 'runtime=claude-code\nschema=1\nsession_file=%s\n' "$(basename "${file}")"
    printf '%s\n' "${metrics}"
    ;;
  *)
    echo "usage: claude-code.sh detect|emit" >&2
    exit 2
    ;;
esac
