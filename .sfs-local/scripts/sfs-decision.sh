#!/usr/bin/env bash
# .sfs-local/scripts/sfs-decision.sh
#
# Solon SFS — `/sfs decision` command implementation.
# WU-26 §1 spec implementation. WU-23 §1.5 정합:
#   · 파일 path stdout 출력만 (에디터 launch 안 함).
#   · decision id auto-naming = 4-자리 zero-pad sequential (0001, 0002, ...).
#   · `--id <override>` 또는 `--id=<override>` 로 명시 ID 지정 가능 (충돌 시 exit 1).
#
# Output (one line):
#   decision created: <path>
#
# Exit codes (WU-26 §1.3 / WU-23 §1.5 정합):
#   0  success
#   1  --id 충돌 (지정 ID 의 decision 이미 존재)
#   2  events.jsonl 손상
#   3  not a git repo
#   4  decisions-template/ADR-TEMPLATE.md 부재
#   5  permission denied
#   7  <title> 미지정 또는 unknown CLI flag
#   99 unknown (e.g. bash trap)
#
# Path note: dev staging file lives at
#   solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-decision.sh
# install.sh copies templates/.sfs-local-template/ → consumer project's .sfs-local/.
# WU-26 §1 spec used `.sfs-local/scripts/` as a shorthand for the consumer-side path.
#
# Note: `next_decision_id_local` is inlined here as a local helper (WU-26 row 2).
#       Per WU-26 §3 + row 4, it will be moved into sfs-common.sh as `next_decision_id`
#       (alongside `sprint_close` and `auto_commit_close`).
#
# Visibility: business-only (solon-mvp-dist staging asset).
# Created: 2026-04-28 (24th cycle user-active conversation `brave-gracious-mayer`
#                      continuation 5, WU-26 §5 row 2).

set -euo pipefail

# Local exit-code fallback (sfs-common.sh has SFS_EXIT_*; we add row-2-local pattern
# matching WU-25 row 3 sfs-review.sh style for forward compat).
: "${SFS_EXIT_BADCLI:=7}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/sfs-common.sh"

# ─── inline local helper (TODO: move to sfs-common.sh in WU-26 §3 / row 4) ────
# next_decision_id_local — scan `.sfs-local/decisions/` for `<id>-<kebab>.md` files,
# return the next 4-digit zero-padded id (max+1, or 0001 if none).
# stdout: 4-digit decision id
# rc: always 0
next_decision_id_local() {
    local dir=".sfs-local/decisions"
    if [ ! -d "$dir" ]; then
        echo "0001"
        return 0
    fi
    local max
    max="$(ls -1 "$dir" 2>/dev/null | grep -E '^[0-9]{4}-' | sed 's/-.*//' | sort -n | tail -1)"
    if [ -z "$max" ]; then
        echo "0001"
    else
        # 10# prefix forces base-10 (avoids octal interpretation of leading zeros).
        printf "%04d" $((10#$max + 1))
    fi
}

# ─── arg parse ────────────────────────────────────────────────────────────────
TITLE=""
OVERRIDE_ID=""

while [ $# -gt 0 ]; do
    case "$1" in
        --help|-h)
            cat <<'USAGE'
Usage: sfs-decision.sh <title> [--id <id>]
       sfs-decision.sh <title> [--id=<id>]

Creates a new mini-ADR file under .sfs-local/decisions/<id>-<kebab>.md from
the .sfs-local/decisions-template/ADR-TEMPLATE.md template, with placeholders
{{DECISION_ID}}, {{TITLE}}, {{NOW}} substituted.

Output: `decision created: <path>` (single line).
Exit codes: 0=ok / 1=id conflict / 4=template missing / 7=usage / 99=unknown.
USAGE
            exit 0
            ;;
        --id)
            [ $# -ge 2 ] || { echo "--id requires value" >&2; exit $SFS_EXIT_BADCLI; }
            OVERRIDE_ID="$2"
            shift 2
            ;;
        --id=*)
            OVERRIDE_ID="${1#--id=}"
            shift
            ;;
        --*)
            { echo "unknown arg: $1" >&2; exit $SFS_EXIT_BADCLI; }
            ;;
        -*)
            { echo "unknown arg: $1" >&2; exit $SFS_EXIT_BADCLI; }
            ;;
        *)
            if [ -z "$TITLE" ]; then
                TITLE="$1"
            else
                { echo "extra positional arg: $1 (only one <title> allowed; use quotes if title contains spaces)" >&2; exit $SFS_EXIT_BADCLI; }
            fi
            shift
            ;;
    esac
done

[ -n "$TITLE" ] || { echo "usage: /sfs decision <title> [--id <id>]" >&2; exit $SFS_EXIT_BADCLI; }

# ─── pre-flight ──────────────────────────────────────────────────────────────
# Note: validate_sfs_local exits non-zero (1) if .sfs-local/ missing.
# We allow `set -e` to propagate here (decision creation is an in-sprint
# operation; absence of .sfs-local is unrecoverable).
set +e
validate_sfs_local
RC=$?
set -e
if [ $RC -ne 0 ]; then
    exit $RC
fi

SPRINT_ID="$(read_current_sprint || true)"

# ─── decision id (auto or override) ──────────────────────────────────────────
if [ -n "$OVERRIDE_ID" ]; then
    # Validate override format: 4-digit zero-padded (lenient — accept any non-empty
    # string, but recommend 4-digit per spec). Spec allows arbitrary id; we only
    # check collision.
    DECISION_ID="$OVERRIDE_ID"
    # Collision check: any file matching ^<id>-*.md
    if compgen -G ".sfs-local/decisions/${DECISION_ID}-*.md" > /dev/null; then
        { echo "decision id $DECISION_ID already exists" >&2; exit 1; }
    fi
else
    DECISION_ID="$(next_decision_id_local)"
fi

# ─── kebab-case slug from title ───────────────────────────────────────────────
KEBAB="$(printf '%s' "$TITLE" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9' '-' | sed 's/--*/-/g; s/^-//; s/-$//')"
[ -n "$KEBAB" ] || { echo "title produces empty kebab-case slug; use letters/digits" >&2; exit $SFS_EXIT_BADCLI; }

# ─── template + path ──────────────────────────────────────────────────────────
DECISIONS_DIR=".sfs-local/decisions"
TEMPLATE=".sfs-local/decisions-template/ADR-TEMPLATE.md"

[ -f "$TEMPLATE" ] || { echo "template missing: $TEMPLATE" >&2; exit 4; }

mkdir -p "$DECISIONS_DIR"

DECISION_PATH="$DECISIONS_DIR/$DECISION_ID-$KEBAB.md"

# Idempotency: if a same-path file already exists (rare, only when override id
# matches an existing kebab), die 1.
[ ! -f "$DECISION_PATH" ] || { echo "decision file already exists: $DECISION_PATH" >&2; exit 1; }

NOW="$(date -u +%Y-%m-%dT%H:%M:%S+00:00)"

# ─── cp template + placeholder substitution ───────────────────────────────────
cp "$TEMPLATE" "$DECISION_PATH"

# Use a portable awk-based substitution (avoid sed -i differences between
# BSD/GNU). Atomic tmp+mv pattern, same as sfs-common.sh update_frontmatter.
TMP_FILE="${DECISION_PATH}.tmp.$$"
awk -v id="$DECISION_ID" -v title="$TITLE" -v now="$NOW" '
{
    gsub(/\{\{DECISION_ID\}\}/, id)
    gsub(/\{\{TITLE\}\}/, title)
    gsub(/\{\{NOW\}\}/, now)
    print
}
' "$DECISION_PATH" > "$TMP_FILE"
mv "$TMP_FILE" "$DECISION_PATH"

if [ -n "$SPRINT_ID" ]; then
    update_frontmatter "$DECISION_PATH" "sprint_id" "\"${SPRINT_ID//\"/\\\"}\"" 2>/dev/null || true
fi

# ─── events.jsonl append ──────────────────────────────────────────────────────
# Use sfs-common.sh `append_event` 2-arg signature (type, json_payload).
# Note: WU-25 row 2 narrative captured the spec→impl signature mismatch;
#       we follow the impl form here (consistent with sfs-plan.sh / sfs-review.sh).
_esc_decision_id="${DECISION_ID//\\/\\\\}"
_esc_decision_id="${_esc_decision_id//\"/\\\"}"
_esc_sprint="${SPRINT_ID//\\/\\\\}"
_esc_sprint="${_esc_sprint//\"/\\\"}"
_esc_path="${DECISION_PATH//\\/\\\\}"
_esc_path="${_esc_path//\"/\\\"}"
_esc_title="${TITLE//\\/\\\\}"
_esc_title="${_esc_title//\"/\\\"}"
append_event "decision_created" "{\"decision_id\":\"${_esc_decision_id}\",\"sprint_id\":\"${_esc_sprint}\",\"path\":\"${_esc_path}\",\"title\":\"${_esc_title}\"}"

# ─── stdout (WU-26 §1.1 verbatim) ─────────────────────────────────────────────
echo "decision created: $DECISION_PATH"

exit 0
