#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────
# Solon v0.4-r4 · scripts/auto-resume.sh  (v0.2 — W-23 HANDOFF 우선)
# 목적: 다음 세션 첫 발화 시 AI 가 호출. PROGRESS.md frontmatter `resume_hint`
#       block 추출 → JSON stdout. AI 가 출력 보고 즉시 default_action 실행.
#
# CLAUDE.md §1.11 (WU-28 simplify) + §1.19 (Handoff system-grade auto-write).
#
# v0.2 (25th-6 zen-magical-feynman, W-23): HANDOFF-next-session.md 가
#   PROGRESS resume_hint 보다 신선하면 HANDOFF default_action 우선 출력.
#   25th-5 zen-practical-archimedes 발견 = stale resume_hint (0.5.0-mvp) +
#   신선 HANDOFF (0.4.0-mvp baseline) 충돌 → AI 가 잘못된 default 따라갈 위험.
#
# Usage:
#   ./scripts/auto-resume.sh [--progress <path>] [--handoff <path>]
#                            [--format json|text]
#                            [--prefer-handoff | --prefer-progress | --auto]
#
# Source resolution:
#   --auto (default)  → HANDOFF.written_at vs resume_hint.last_written 비교, 신선한 쪽
#   --prefer-handoff  → HANDOFF 강제 우선 (HANDOFF 없으면 PROGRESS fallback)
#   --prefer-progress → 기존 v0.1 동작 (PROGRESS 만, HANDOFF 무시)
#
# Exit codes:
#   0 = ok (output to stdout, source 필드 = progress|handoff|both)
#   1 = invalid usage (unknown flag)
#   2 = PROGRESS.md not found
#   3 = resume_hint block missing AND HANDOFF default_action missing
#   99 = unknown internal error
# ────────────────────────────────────────────────────────────────
set -euo pipefail

PROGRESS_PATH=""
HANDOFF_PATH=""
FORMAT="json"
PREFER="auto"  # auto | handoff | progress

while [[ $# -gt 0 ]]; do
  case "$1" in
    --progress)        PROGRESS_PATH="$2"; shift 2 ;;
    --progress=*)      PROGRESS_PATH="${1#*=}"; shift ;;
    --handoff)         HANDOFF_PATH="$2"; shift 2 ;;
    --handoff=*)       HANDOFF_PATH="${1#*=}"; shift ;;
    --format)          FORMAT="$2"; shift 2 ;;
    --format=*)        FORMAT="${1#*=}"; shift ;;
    --prefer-handoff)  PREFER="handoff"; shift ;;
    --prefer-progress) PREFER="progress"; shift ;;
    --auto)            PREFER="auto"; shift ;;
    -h|--help)
      cat <<'EOF'
Usage: ./scripts/auto-resume.sh [--progress <path>] [--handoff <path>]
                                [--format json|text]
                                [--prefer-handoff | --prefer-progress | --auto]

Extracts the resume hint for the next session. By default (--auto) compares
HANDOFF.written_at with resume_hint.last_written and chooses the fresher one.
W-23 (25th-5 zen-practical-archimedes 발견) 후속 = stale resume_hint vs 신선
HANDOFF 충돌 방지.

Source resolution:
  --auto (default)  HANDOFF vs PROGRESS 신선도 자동 비교
  --prefer-handoff  HANDOFF 강제 우선 (없으면 PROGRESS fallback)
  --prefer-progress 기존 v0.1 동작 (PROGRESS 만)

Exit codes:
  0  ok (JSON 출력에 source 필드 = progress|handoff|both)
  1  invalid usage
  2  PROGRESS.md not found
  3  resume_hint AND HANDOFF default_action 둘 다 missing
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

# Resolve HANDOFF.md path (W-23, v0.2): same dir as PROGRESS by default
if [[ -z "$HANDOFF_PATH" ]]; then
  PROGRESS_DIR="$(dirname "$PROGRESS_PATH")"
  for cand in \
    "${PROGRESS_DIR}/HANDOFF-next-session.md" \
    "HANDOFF-next-session.md" \
    "2026-04-19-sfs-v0.4/HANDOFF-next-session.md"; do
    if [[ -f "$cand" ]]; then
      HANDOFF_PATH="$cand"; break
    fi
  done
fi
# HANDOFF is optional — only PROGRESS is required

# Extract resume_hint block + HANDOFF default_action via python3 (yaml-aware)
if ! command -v python3 >/dev/null 2>&1; then
  echo "auto-resume: python3 required" >&2
  exit 99
fi

OUTPUT=$(python3 - "$PROGRESS_PATH" "${HANDOFF_PATH:-}" "$FORMAT" "$PREFER" <<'PYEOF'
import sys, re, json
from datetime import datetime, timezone

path = sys.argv[1]
handoff_path = sys.argv[2] or None
fmt = sys.argv[3]
prefer = sys.argv[4]  # auto | handoff | progress

# ── PROGRESS.md frontmatter parse ──────────────────────
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
progress_default_action = ""
progress_last_written = ""
progress_fields = {}
if rh:
    body = rh.group(1)

    def get_nested(name, body):
        pat = rf'^[ \t]+{re.escape(name)}:\s*(.*?)(?:\s*#.*)?$'
        mm = re.search(pat, body, re.MULTILINE)
        if not mm:
            return ""
        val = mm.group(1).strip()
        if (val.startswith('"') and val.endswith('"')) or (val.startswith("'") and val.endswith("'")):
            val = val[1:-1]
        if val in ('|', '>', ''):
            block_pat = rf'^[ \t]+{re.escape(name)}:.*\n((?:[ \t]+[ \t]+.*\n?)+)'
            bm = re.search(block_pat, body, re.MULTILINE)
            if bm:
                return bm.group(1).strip()
        return val

    progress_default_action = get_nested('default_action', body)
    progress_last_written   = get_nested('last_written', body)
    progress_fields = {
        'default_action':   progress_default_action,
        'on_skip_patterns': get_nested('on_skip_patterns', body),
        'on_skip_action':   get_nested('on_skip_action', body),
        'on_ambiguous':     get_nested('on_ambiguous', body),
        'safety_locks':     get_nested('safety_locks', body),
        'last_written':     progress_last_written,
    }

# ── HANDOFF.md frontmatter + body parse (W-23 신선도 비교) ─
handoff_default_action = ""
handoff_written_at = ""
if handoff_path:
    try:
        with open(handoff_path) as f:
            hcontent = f.read()
        hm = re.search(r'^---\n(.*?)\n---', hcontent, re.DOTALL)
        if hm:
            hfm = hm.group(1)
            wa = re.search(r'^written_at:\s*(.*?)(?:\s*#.*)?$', hfm, re.MULTILINE)
            handoff_written_at = wa.group(1).strip() if wa else ""
        # ## 1. default_action 섹션 본문 (다음 ## 까지)
        sec = re.search(r'^##\s*1\.\s*default_action[^\n]*\n(.*?)(?=^##\s|\Z)',
                        hcontent, re.MULTILINE | re.DOTALL)
        if sec:
            handoff_default_action = sec.group(1).strip()
    except Exception:
        pass

# ── 신선도 비교 (auto mode) ───────────────────────────
def parse_iso(s):
    if not s:
        return None
    s = s.strip()
    # strip optional surrounding quotes
    if (s.startswith('"') and s.endswith('"')) or (s.startswith("'") and s.endswith("'")):
        s = s[1:-1]
    # Normalize Z → +00:00
    s = s.replace('Z', '+00:00')
    try:
        return datetime.fromisoformat(s)
    except Exception:
        return None

p_dt = parse_iso(progress_last_written)
h_dt = parse_iso(handoff_written_at)

source = "progress"  # default
if prefer == "handoff":
    if handoff_default_action:
        source = "handoff"
elif prefer == "progress":
    source = "progress"
else:  # auto
    if handoff_default_action and h_dt and p_dt:
        if h_dt > p_dt:
            source = "handoff"
        else:
            source = "progress"
    elif handoff_default_action and not progress_default_action:
        source = "handoff"
    elif handoff_default_action and h_dt and not p_dt:
        # PROGRESS last_written 없으면 HANDOFF 우선
        source = "handoff"

# 둘 다 비어 있으면 exit 3
if not progress_default_action and not handoff_default_action:
    sys.exit(3)

chosen_action = handoff_default_action if source == "handoff" else progress_default_action

result = {
    'progress_path': path,
    'handoff_path': handoff_path or "",
    'source': source,                              # progress | handoff
    'prefer_mode': prefer,                         # auto | handoff | progress
    'progress_last_written': progress_last_written,
    'handoff_written_at': handoff_written_at,
    'current_wu': get_top_field('current_wu'),
    'current_wu_path': get_top_field('current_wu_path'),
    'current_wu_owner': get_top_field('current_wu_owner').split('#')[0].strip(),
    'default_action': chosen_action,
    'progress_default_action': progress_default_action,
    'handoff_default_action': handoff_default_action,
}
# Append remaining PROGRESS-only fields (preserve v0.1 contract)
for k, v in progress_fields.items():
    if k not in ('default_action', 'last_written'):
        result[k] = v

if fmt == 'json':
    print(json.dumps(result, ensure_ascii=False, indent=2))
else:
    for k, v in result.items():
        print(f"{k}: {v}")
PYEOF
)
RC=$?
if (( RC == 3 )); then
  echo "auto-resume: resume_hint AND HANDOFF default_action 둘 다 missing ($PROGRESS_PATH / $HANDOFF_PATH)" >&2
  exit 3
fi
if (( RC != 0 )); then
  echo "auto-resume: extraction failed (rc=$RC)" >&2
  exit 99
fi
echo "$OUTPUT"
exit 0
