#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────
# Solon v0.4-r4 · scripts/handoff-write.sh  (v0.1)
# 목적: 본 세션 종료 시 AI 가 호출. 현재 PROGRESS state + git ahead/log +
#       working tree → HANDOFF-next-session.md 갱신 + PROGRESS frontmatter
#       resume_hint block 갱신.
#
# CLAUDE.md §1.19 (WU-28 신설) 의 운영 helper.
#
# Usage:
#   ./scripts/handoff-write.sh \
#     --next-action "<prose, 1줄>" \
#     [--inventory <files…>] \
#     [--w10-pending <ids…>] \
#     [--last-commit <sha>] \
#     [--progress <path>] \
#     [--handoff <path>] \
#     [--dry-run]
#
# Side effects:
#   - HANDOFF-next-session.md 갱신 (frontmatter + 본문 4 섹션)
#   - PROGRESS.md frontmatter resume_hint.default_action 갱신
#
# Exit codes:
#   0 = ok
#   1 = invalid usage
#   2 = PROGRESS.md or HANDOFF.md path not found
#   3 = write failed
#   99 = unknown
# ────────────────────────────────────────────────────────────────
set -euo pipefail

NEXT_ACTION=""
INVENTORY=""
W10_PENDING=""
LAST_COMMIT=""
PROGRESS_PATH=""
HANDOFF_PATH=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --next-action)     NEXT_ACTION="$2"; shift 2 ;;
    --next-action=*)   NEXT_ACTION="${1#*=}"; shift ;;
    --inventory)       INVENTORY="$2"; shift 2 ;;
    --inventory=*)     INVENTORY="${1#*=}"; shift ;;
    --w10-pending)     W10_PENDING="$2"; shift 2 ;;
    --w10-pending=*)   W10_PENDING="${1#*=}"; shift ;;
    --last-commit)     LAST_COMMIT="$2"; shift 2 ;;
    --last-commit=*)   LAST_COMMIT="${1#*=}"; shift ;;
    --progress)        PROGRESS_PATH="$2"; shift 2 ;;
    --progress=*)      PROGRESS_PATH="${1#*=}"; shift ;;
    --handoff)         HANDOFF_PATH="$2"; shift 2 ;;
    --handoff=*)       HANDOFF_PATH="${1#*=}"; shift ;;
    --dry-run)         DRY_RUN=true; shift ;;
    -h|--help)
      sed -n '2,30p' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    *)
      echo "handoff-write: unknown arg: $1" >&2; exit 1
      ;;
  esac
done

if [[ -z "$NEXT_ACTION" ]]; then
  echo "handoff-write: --next-action required (1-line prose)" >&2
  exit 1
fi

# Resolve paths
if [[ -z "$PROGRESS_PATH" ]]; then
  for cand in "2026-04-19-sfs-v0.4/PROGRESS.md" "PROGRESS.md"; do
    [[ -f "$cand" ]] && { PROGRESS_PATH="$cand"; break; }
  done
fi
if [[ -z "$HANDOFF_PATH" ]]; then
  for cand in "2026-04-19-sfs-v0.4/HANDOFF-next-session.md" "HANDOFF-next-session.md"; do
    [[ -f "$cand" ]] && { HANDOFF_PATH="$cand"; break; }
  done
  # If still empty, default to docset path (will be created)
  HANDOFF_PATH="${HANDOFF_PATH:-2026-04-19-sfs-v0.4/HANDOFF-next-session.md}"
fi
if [[ ! -f "$PROGRESS_PATH" ]]; then
  echo "handoff-write: PROGRESS.md not found (set --progress)" >&2
  exit 2
fi

# Auto-detect last commit if not provided
if [[ -z "$LAST_COMMIT" ]]; then
  LAST_COMMIT=$(git log -1 --pretty=format:'%H' 2>/dev/null || echo "(no commit)")
fi

NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
NOW_KST=$(date +"%Y-%m-%dT%H:%M:%S+09:00" 2>/dev/null || echo "$NOW")

# ── Build new HANDOFF body ────────────────────────────────────────
HANDOFF_BODY=$(cat <<EOF
---
doc_id: handoff-next-session
title: "Next session handoff (auto-written by handoff-write.sh, WU-28)"
written_at: ${NOW}
written_at_kst: ${NOW_KST}
last_commit: ${LAST_COMMIT}
visibility: raw-internal
---

# Next Session Handoff

> Auto-written by \`scripts/handoff-write.sh\` per CLAUDE.md §1.19.
> Next session: read this file → execute \`default_action\` (no user trigger needed per §1.11 WU-28).

## 1. default_action (다음 세션 진입 시 즉시 실행)

${NEXT_ACTION}

## 2. 산출 inventory (직전 세션 결과)

${INVENTORY:-(none)}

## 3. 미결정 W10 TODO

${W10_PENDING:-(none)}

## 4. 직전 commit

\`${LAST_COMMIT}\`

## 5. 운영 명령

\`\`\`bash
# 본 file 자동 생성 재현:
cd ~/agent_architect
./2026-04-19-sfs-v0.4/scripts/handoff-write.sh \\
  --next-action "${NEXT_ACTION}" \\
  --inventory "${INVENTORY:-}" \\
  --w10-pending "${W10_PENDING:-}" \\
  --last-commit ${LAST_COMMIT}

# 다음 세션 진입 시 (AI 가 자동 호출):
./2026-04-19-sfs-v0.4/scripts/auto-resume.sh
\`\`\`
EOF
)

# ── Update PROGRESS.md frontmatter resume_hint.default_action ────
update_progress_resume_hint() {
  python3 - "$PROGRESS_PATH" "$NEXT_ACTION" "$NOW" <<'PYEOF'
import sys, re
path, action, now = sys.argv[1:4]
with open(path) as f:
    content = f.read()
m = re.search(r'^(---\n)(.*?)(\n---)', content, re.DOTALL)
if not m:
    sys.exit(3)
fm = m.group(2)

# Find or create resume_hint block
rh_pat = r'^(resume_hint:\s*\n)((?:[ \t]+.*\n?)+)'
rh = re.search(rh_pat, fm, re.MULTILINE)

def replace_or_add_field_multiline_safe(body, key, val):
    """Replace `key: ...` line with `key: <val>`, removing any multi-line block
    scalar continuation (indented deeper than the key itself)."""
    lines = body.split('\n')
    out = []
    da_indent = -1
    replaced = False
    skip_until_dedent = False
    for line in lines:
        m = re.match(rf'^([ \t]+){re.escape(key)}:\s*(.*)$', line)
        if m and not replaced:
            indent = m.group(1)
            da_indent = len(indent)
            out.append(f"{indent}{key}: {val}")
            replaced = True
            skip_until_dedent = True
            continue
        if skip_until_dedent:
            if not line.strip():
                # blank line — keep but stop skipping (next sibling boundary)
                skip_until_dedent = False
                out.append(line)
                continue
            m2 = re.match(r'^([ \t]+)', line)
            if m2 and len(m2.group(1)) > da_indent:
                # continuation of previous block scalar, skip
                continue
            else:
                skip_until_dedent = False
        out.append(line)
    if not replaced:
        # Append at end
        if out and out[-1] != '':
            pass
        out.append(f"  {key}: {val}")
    return '\n'.join(out)

if rh:
    header, body = rh.group(1), rh.group(2)
    new_body = replace_or_add_field_multiline_safe(body, 'default_action', action)
    new_body = replace_or_add_field_multiline_safe(new_body, 'last_written', now)
    new_fm = fm[:rh.start()] + header + new_body + fm[rh.end():]
else:
    # Append a new resume_hint block at end of frontmatter
    if fm and not fm.endswith('\n'):
        fm += '\n'
    new_fm = fm + f"resume_hint:\n  default_action: {action}\n  last_written: {now}\n"

new_content = m.group(1) + new_fm + m.group(3) + content[m.end():]
with open(path, 'w') as f:
    f.write(new_content)
PYEOF
}

if [[ "$DRY_RUN" == "true" ]]; then
  echo "[DRY-RUN] Would write HANDOFF to: $HANDOFF_PATH"
  echo "[DRY-RUN] Would update resume_hint.default_action in: $PROGRESS_PATH"
  echo "[DRY-RUN] HANDOFF body preview (first 30 lines):"
  echo "$HANDOFF_BODY" | head -30
  exit 0
fi

# Write HANDOFF
if ! echo "$HANDOFF_BODY" > "$HANDOFF_PATH"; then
  echo "handoff-write: failed to write $HANDOFF_PATH" >&2
  exit 3
fi

# Update PROGRESS resume_hint
if ! update_progress_resume_hint; then
  echo "handoff-write: failed to update $PROGRESS_PATH resume_hint" >&2
  exit 3
fi

echo "handoff-write: wrote $HANDOFF_PATH + updated $PROGRESS_PATH resume_hint"
exit 0
