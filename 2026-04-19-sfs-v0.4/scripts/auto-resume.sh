#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────
# Solon v0.4-r4 · scripts/auto-resume.sh  (v0.1)
# 목적: 다음 세션 첫 발화 시 AI 가 호출. PROGRESS.md frontmatter `resume_hint`
#       block 추출 → JSON stdout. AI 가 출력 보고 즉시 default_action 실행.
#
# CLAUDE.md §1.11 (WU-28 simplify) 의 운영 helper.
#
# Usage:
#   ./scripts/auto-resume.sh [--progress <path>] [--format json|text]
#
# Exit codes:
#   0 = ok (resume_hint extracted, JSON output to stdout)
#   1 = invalid usage (unknown flag)
#   2 = PROGRESS.md not found
#   3 = resume_hint block missing or empty
#   99 = unknown internal error
# ────────────────────────────────────────────────────────────────
set -euo pipefail

PROGRESS_PATH=""
FORMAT="json"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --progress)   PROGRESS_PATH="$2"; shift 2 ;;
    --progress=*) PROGRESS_PATH="${1#*=}"; shift ;;
    --format)     FORMAT="$2"; shift 2 ;;
    --format=*)   FORMAT="${1#*=}"; shift ;;
    -h|--help)
      cat <<'EOF'
Usage: ./scripts/auto-resume.sh [--progress <path>] [--format json|text]

Extracts the `resume_hint` block from PROGRESS.md frontmatter and emits the
default_action, on_skip_patterns, and on_ambiguous fields. Used by AI on
first user message of a new session (CLAUDE.md §1.11 WU-28 simplify).

Exit codes:
  0  ok (output to stdout)
  1  invalid usage
  2  PROGRESS.md not found
  3  resume_hint block missing
  99 unknown
EOF
      exit 0
      ;;
    *)
      echo "auto-resume: unknown arg: $1" >&2
      exit 1
      ;;
  esac
done

# Resolve PROGRESS.md path
if [[ -z "$PROGRESS_PATH" ]]; then
  for cand in \
    "2026-04-19-sfs-v0.4/PROGRESS.md" \
    "PROGRESS.md" \
    ".sfs-local/PROGRESS.md"; do
    if [[ -f "$cand" ]]; then
      PROGRESS_PATH="$cand"; break
    fi
  done
fi
if [[ ! -f "$PROGRESS_PATH" ]]; then
  echo "auto-resume: PROGRESS.md not found (set --progress <path>)" >&2
  exit 2
fi

# Extract resume_hint block via python3 (yaml-aware)
if ! command -v python3 >/dev/null 2>&1; then
  echo "auto-resume: python3 required" >&2
  exit 99
fi

OUTPUT=$(python3 - "$PROGRESS_PATH" "$FORMAT" <<'PYEOF'
import sys, re, json
path, fmt = sys.argv[1], sys.argv[2]
with open(path) as f:
    content = f.read()
m = re.search(r'^---\n(.*?)\n---', content, re.DOTALL)
if not m:
    sys.exit(3)
fm = m.group(1)

def get_top_field(name):
    pat = rf'^{re.escape(name)}:\s*(.*?)(?:\s*#.*)?$'
    mm = re.search(pat, fm, re.MULTILINE)
    return mm.group(1).strip() if mm else ""

# resume_hint is a nested block
rh = re.search(r'^resume_hint:\s*\n((?:[ \t]+.*\n?)+)', fm, re.MULTILINE)
if not rh:
    sys.exit(3)
body = rh.group(1)

def get_nested(name, body):
    pat = rf'^[ \t]+{re.escape(name)}:\s*(.*?)(?:\s*#.*)?$'
    mm = re.search(pat, body, re.MULTILINE)
    if not mm:
        return ""
    val = mm.group(1).strip()
    # Strip surrounding quotes
    if (val.startswith('"') and val.endswith('"')) or (val.startswith("'") and val.endswith("'")):
        val = val[1:-1]
    # Multi-line block scalar (`|` or `>`)
    if val in ('|', '>', ''):
        # Read subsequent indented lines
        block_pat = rf'^[ \t]+{re.escape(name)}:.*\n((?:[ \t]+[ \t]+.*\n?)+)'
        bm = re.search(block_pat, body, re.MULTILINE)
        if bm:
            return bm.group(1).strip()
    return val

result = {
    'progress_path': path,
    'current_wu': get_top_field('current_wu'),
    'current_wu_path': get_top_field('current_wu_path'),
    'current_wu_owner': get_top_field('current_wu_owner').split('#')[0].strip(),
    'default_action': get_nested('default_action', body),
    'on_skip_patterns': get_nested('on_skip_patterns', body),
    'on_skip_action': get_nested('on_skip_action', body),
    'on_ambiguous': get_nested('on_ambiguous', body),
    'safety_locks': get_nested('safety_locks', body),
}

if fmt == 'json':
    print(json.dumps(result, ensure_ascii=False, indent=2))
else:
    for k, v in result.items():
        print(f"{k}: {v}")
PYEOF
)
RC=$?
if (( RC == 3 )); then
  echo "auto-resume: resume_hint block missing or empty in $PROGRESS_PATH" >&2
  exit 3
fi
if (( RC != 0 )); then
  echo "auto-resume: extraction failed (rc=$RC)" >&2
  exit 99
fi
echo "$OUTPUT"
exit 0
