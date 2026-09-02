#!/usr/bin/env bash
# .sfs-local/scripts/sfs-publish-daily-handoff.sh
#
# Solon SFS — daily-handoff publisher.
# Aggregates ONE sprint report, an optional existing Gate 6 review, and an
# optional Gate 7 retro into <out-dir>/daily-handoff.md
# (a filled instance of sprint-templates/daily-handoff.md, the authoritative
# Markdown) and derives <out-dir>/daily-handoff.html via the sibling renderer
# daily-handoff-html.sh.
#
# Contract:
#   - idempotent create-or-update: everything OUTSIDE the human-notes block
#     is regenerated from the sources on every run; the human-notes block
#     (marker lines included) is preserved byte-for-byte across reruns;
#   - evidence-faithful: bullets are extracted from report/review/retro list items
#     under recognizably-named headings; a section with no extracted
#     evidence gets an explicit "(none reported)" placeholder — content is
#     never invented;
#   - ADR gate: Decisions renders ONLY entries already explicitly marked
#     ADR-NNNN in the sources (a bullet starting with "ADR-NNNN", or an
#     ADR-NNNN mention inside a decisions-named section). No marked entry ->
#     the section stays bullet-free and the HTML shows "gate did not apply";
#   - derived HTML: daily-handoff.html is regenerated on every run and must
#     never be hand-edited (release-policy live-status pattern);
#   - dependency-free: bash 3.2+ / POSIX awk / base utilities only, zero
#     network/JS/assets.
#
# Like the renderer, this is an internal Gate 6/7 helper, NOT an `sfs`
# dispatched command. Users never invoke a separate daily-publish command
# (commands/daily.md keeps its "composition, not a binary" contract).
#
# Path note: dev staging file lives at
#   templates/.sfs-local-template/scripts/sfs-publish-daily-handoff.sh
# install.sh copies templates/.sfs-local-template/ -> consumer .sfs-local/.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  sfs-publish-daily-handoff.sh --report <report.md> [--review <review.md>] \
                               [--retro <retro.md>] \
                               --sprint <id> [--out-dir <dir>]

Publishes a manager-readable daily handoff from one sprint report, an existing
Gate 6 review when available, and (when Gate 7 has created it) one retro:

  <out-dir>/daily-handoff.md    authoritative Markdown (created or updated)
  <out-dir>/daily-handoff.html  derived page via sibling daily-handoff-html.sh

Default <out-dir> = dirname(<report.md>).

Behavior:
  - Completed / Validation / Risks / Next are filled from bullet lines found
    under matching headings in the report, review, and optional retro; when nothing is found a
    section gets an explicit "- (none reported)" placeholder.
  - Decisions renders ONLY entries already explicitly marked ADR-NNNN in the
    sources; with no marked entry the section is left bullet-free and the
    HTML shows "(none: ADR gate did not apply)". ADRs are never invented.
  - Sources always cites the report path and sprint id. It cites review and
    retro paths only when those evidence files exist.
  - The block between the markers
        <!-- human-notes:start ... -->  ...  <!-- human-notes:end -->
    (at the bottom, under "## Human Notes") is preserved verbatim across
    reruns. Everything else is regenerated: put manual edits ONLY inside
    that block. If an existing daily-handoff.md has no such markers, it is
    saved once to daily-handoff.md.bak before being regenerated.
  - Frontmatter owner/status come from the report frontmatter when present
    (retro as owner fallback, then $USER); status falls back to on-track
    unless one of: on-track | at-risk | blocked | done.

Exit 0 on success (prints both output paths); exit 2 on usage errors or
missing inputs; renderer failures propagate. The Markdown output is the
authoritative source; the HTML page is a derived projection.
EOF
}

die2() { printf 'sfs-publish-daily-handoff: %s\n' "$1" >&2; exit 2; }

REPORT=""; REVIEW=""; RETRO=""; SPRINT=""; OUT_DIR=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help|help) usage; exit 0 ;;
    --report)    REPORT="${2:-}";  [ -n "$REPORT" ]  || die2 "missing value for --report";  shift 2 ;;
    --report=*)  REPORT="${1#*=}";  shift ;;
    --review)    REVIEW="${2:-}";  [ -n "$REVIEW" ]  || die2 "missing value for --review";  shift 2 ;;
    --review=*)  REVIEW="${1#*=}";  shift ;;
    --retro)     RETRO="${2:-}";   [ -n "$RETRO" ]   || die2 "missing value for --retro";   shift 2 ;;
    --retro=*)   RETRO="${1#*=}";   shift ;;
    --sprint)    SPRINT="${2:-}";  [ -n "$SPRINT" ]  || die2 "missing value for --sprint";  shift 2 ;;
    --sprint=*)  SPRINT="${1#*=}";  shift ;;
    --out-dir)   OUT_DIR="${2:-}"; [ -n "$OUT_DIR" ] || die2 "missing value for --out-dir"; shift 2 ;;
    --out-dir=*) OUT_DIR="${1#*=}"; shift ;;
    *) printf 'unknown argument: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
done

[ -n "$REPORT" ] || die2 "--report is required (see --help)"
[ -n "$SPRINT" ] || die2 "--sprint is required (see --help)"
[ -f "$REPORT" ] || die2 "report not found: $REPORT"
if [ -n "$REVIEW" ]; then
  [ -f "$REVIEW" ] || die2 "review not found: $REVIEW"
fi
if [ -n "$RETRO" ]; then
  [ -f "$RETRO" ] || die2 "retro not found: $RETRO"
fi
case "$SPRINT" in
  *$'\n'*|*$'\r'*) die2 "sprint id must be a single line" ;;
esac

[ -n "$OUT_DIR" ] || OUT_DIR=$(dirname -- "$REPORT")
OUT_MD="$OUT_DIR/daily-handoff.md"
OUT_HTML="$OUT_DIR/daily-handoff.html"

for SRC in "$REPORT"; do
  if [ "$SRC" = "$OUT_MD" ] || [ "$SRC" = "$OUT_HTML" ] || \
     { [ -e "$OUT_MD" ] && [ "$SRC" -ef "$OUT_MD" ]; } || \
     { [ -e "$OUT_HTML" ] && [ "$SRC" -ef "$OUT_HTML" ]; }; then
    die2 "source and output are the same file: $SRC"
  fi
done
if [ -n "$REVIEW" ]; then
  if [ "$REVIEW" = "$OUT_MD" ] || [ "$REVIEW" = "$OUT_HTML" ] || \
     { [ -e "$OUT_MD" ] && [ "$REVIEW" -ef "$OUT_MD" ]; } || \
     { [ -e "$OUT_HTML" ] && [ "$REVIEW" -ef "$OUT_HTML" ]; }; then
    die2 "source and output are the same file: $REVIEW"
  fi
fi
if [ -n "$RETRO" ]; then
  if [ "$RETRO" = "$OUT_MD" ] || [ "$RETRO" = "$OUT_HTML" ] || \
     { [ -e "$OUT_MD" ] && [ "$RETRO" -ef "$OUT_MD" ]; } || \
     { [ -e "$OUT_HTML" ] && [ "$RETRO" -ef "$OUT_HTML" ]; }; then
    die2 "source and output are the same file: $RETRO"
  fi
fi

mkdir -p -- "$OUT_DIR"

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
RENDERER="$SCRIPT_DIR/daily-handoff-html.sh"
[ -f "$RENDERER" ] || die2 "renderer not found next to this script: $RENDERER"
[ -x "$RENDERER" ] || die2 "renderer is not executable: $RENDERER"

TMP=$(mktemp -d "${TMPDIR:-/tmp}/sfs-publish-daily-handoff.XXXXXX") || die2 "mktemp failed"
trap 'rm -rf "$TMP"' EXIT

# ---------------------------------------------------------------------------
# 1. Extract list evidence from the two sources into per-section list files.
#    Buckets are chosen by heading name (any ATX level, case-insensitive);
#    only `- / * / +` bullet lines are taken; source frontmatter is skipped.
#    Decisions are collected separately and only when explicitly ADR-marked.
# ---------------------------------------------------------------------------
extract_into_lists() {
  SFS_PDH_LIST_DIR="$TMP" awk '
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    BEGIN { D = ENVIRON["SFS_PDH_LIST_DIR"]; bucket = ""; fm = 0 }
    { sub(/\r$/, "") }
    NR == 1 && $0 == "---" { fm = 1; next }
    fm == 1 { if ($0 == "---") fm = 0; next }
    /^#/ {
      if (match($0, /^#+[ \t]+/)) {
        h = tolower(trim(substr($0, RLENGTH + 1)))
        if      (h ~ /completed|delivered|shipped|(^|[^a-z])done([^a-z]|$)|완료/) bucket = "completed"
        else if (h ~ /valid|verif|test|check|evidence|검증/)                      bucket = "validation"
        else if (h ~ /risk|blocker|위험|블로커/)                                  bucket = "risks"
        else if (h ~ /next|follow|todo|action|다음/)                              bucket = "next"
        else if (h ~ /decision|adr|결정/)                                        bucket = "decisions"
        else bucket = ""
        next
      }
    }
    /^[ \t]*[-*+][ \t]+/ {
      item = trim($0)
      item = trim(substr(item, 2))
      if (item == "") next
      if (item ~ /^ADR-[0-9][0-9][0-9][0-9]([^0-9]|$)/ ||
          (bucket == "decisions" && item ~ /ADR-[0-9][0-9][0-9][0-9]/))
        print item >> (D "/decisions.lst")
      if (bucket != "" && bucket != "decisions")
        print item >> (D "/" bucket ".lst")
      next
    }
  ' "$1"
}
extract_into_lists "$REPORT"
if [ -n "$REVIEW" ]; then
  extract_into_lists "$REVIEW"
fi
if [ -n "$RETRO" ]; then
  extract_into_lists "$RETRO"
fi

# ---------------------------------------------------------------------------
# 2. Frontmatter values: owner/status from the report (an existing review, then
#    retro as owner fallbacks), date from today, sprint from --sprint.
# ---------------------------------------------------------------------------
fm_get() { # $1 = file, $2 = key (literal word, no metacharacters)
  awk -v want="$2" '
    { sub(/\r$/, "") }
    NR == 1 { if ($0 != "---") exit; next }
    $0 == "---" { exit }
    {
      line = $0
      sub(/[ \t]+#.*$/, "", line)
      if (match(line, /^[A-Za-z][A-Za-z0-9_-]*:/)) {
        key = substr(line, 1, RLENGTH - 1)
        if (key == want) {
          val = substr(line, RLENGTH + 1)
          gsub(/^[ \t]+|[ \t]+$/, "", val)
          gsub(/^"|"$/, "", val)
          print val
          exit
        }
      }
    }
  ' "$1"
}

OWNER=$(fm_get "$REPORT" owner)
if [ -z "$OWNER" ] && [ -n "$REVIEW" ]; then
  OWNER=$(fm_get "$REVIEW" owner)
fi
if [ -z "$OWNER" ] && [ -n "$RETRO" ]; then
  OWNER=$(fm_get "$RETRO" owner)
fi
[ -n "$OWNER" ] || OWNER="${USER:-unknown}"
STATUS=$(fm_get "$REPORT" status)
case "$STATUS" in
  on-track|at-risk|blocked|done) : ;;
  *) STATUS="on-track" ;;
esac
TODAY=$(date +%Y-%m-%d)

# ---------------------------------------------------------------------------
# 3. Preserve the human-notes block from an existing output, verbatim
#    (marker lines included). Missing end marker -> keep through EOF.
# ---------------------------------------------------------------------------
NOTES_FILE="$TMP/human-notes.md"
if [ -f "$OUT_MD" ]; then
  awk '
    /^<!-- human-notes:start/ { inblock = 1 }
    inblock { print }
    inblock && /^<!-- human-notes:end/ { exit }
  ' "$OUT_MD" > "$NOTES_FILE"
  if [ ! -s "$NOTES_FILE" ] && [ ! -e "$OUT_MD.bak" ]; then
    # Existing file without markers (hand-written or pre-marker version):
    # keep a one-time backup so regeneration never destroys manual content.
    cat -- "$OUT_MD" > "$OUT_MD.bak"
    printf 'sfs-publish-daily-handoff: existing %s had no human-notes markers; saved backup %s\n' \
      "$OUT_MD" "$OUT_MD.bak" >&2
  fi
fi
if [ ! -s "$NOTES_FILE" ]; then
  {
    printf '%s\n' '<!-- human-notes:start (이 블록은 재생성 시 그대로 보존된다 — 손으로 쓰는 메모는 여기에만) -->'
    printf '%s\n' '_(no human notes yet)_'
    printf '%s\n' '<!-- human-notes:end -->'
  } > "$NOTES_FILE"
fi

# ---------------------------------------------------------------------------
# 4. Assemble the Markdown (renderer contract: frontmatter date/owner/sprint/
#    status + the six ## sections), then swap it into place.
# ---------------------------------------------------------------------------
emit_bullets() { # $1 = list file (may be absent) — dedup, "- " prefix
  if [ -s "$1" ]; then
    awk '!seen[$0]++ { print "- " $0 }' "$1"
  else
    printf '%s\n' '- (none reported)'
  fi
}

# Return SOURCE as a path relative to OUT_DIR. The normal retro lifecycle
# already places report, retro, and this handoff in one directory; retaining a
# relative path also keeps the Markdown and its derived HTML portable together.
relative_source_path() { # $1 = source file, $2 = output directory
  local source="$1" output_dir="$2" source_dir output_abs source_abs
  source_dir=$(CDPATH= cd -P -- "$(dirname -- "$source")" && pwd) || return 1
  output_abs=$(CDPATH= cd -P -- "$output_dir" && pwd) || return 1
  source_abs="$source_dir/$(basename -- "$source")"
  awk -v from="$output_abs" -v to="$source_abs" '
    BEGIN {
      nf = split(from, f, "/"); nt = split(to, t, "/"); i = 1
      while (i <= nf && i <= nt && f[i] == t[i]) i++
      out = ""
      for (j = i; j <= nf; j++) if (f[j] != "") out = out "../"
      for (j = i; j <= nt; j++) if (t[j] != "") out = out (out == "" || substr(out, length(out), 1) == "/" ? "" : "/") t[j]
      print (out == "" ? "." : out)
    }
  '
}

emit_source() { # $1 = source label, $2 = source file
  local label="$1" source="$2" rel
  rel="$(relative_source_path "$source" "$OUT_DIR")" || rel="$source"
  case "$rel" in
    *$'\n'*|*$'\r'*|*'['*|*']'*|*'('*|*')'*|*' '* )
      printf '%s\n' "- $label: \`$source\`"
      ;;
    *)
      printf '%s\n' "- $label: [$(basename -- "$source")]($rel)"
      ;;
  esac
}

NEW_MD="$TMP/daily-handoff.new.md"
{
  printf '%s\n' '---'
  printf '%s\n' 'phase: daily-handoff'
  printf '%s\n' "date: $TODAY"
  printf '%s\n' "owner: $OWNER"
  printf '%s\n' "sprint: $SPRINT"
  printf '%s\n' "status: $STATUS"
  printf '%s\n' '---'
  printf '%s\n' ''
  printf '%s\n' '# Daily Handoff'
  printf '%s\n' ''
  printf '%s\n' '<!-- generated by sfs-publish-daily-handoff.sh — 아래 섹션은 재실행 시 report/review/retro 에서 다시 생성된다. 손 메모는 맨 아래 human-notes 블록에만. HTML 은 파생 산출물: 수정은 항상 이 MD 에서. -->'
  printf '%s\n' ''
  printf '%s\n' '## Completed'
  printf '%s\n' ''
  emit_bullets "$TMP/completed.lst"
  printf '%s\n' ''
  printf '%s\n' '## Decisions'
  printf '%s\n' ''
  if [ -s "$TMP/decisions.lst" ]; then
    awk '!seen[$0]++ { print "- " $0 }' "$TMP/decisions.lst"
  else
    printf '%s\n' '<!-- (none reported): no ADR-NNNN-marked entries in sources; renderer shows "ADR gate did not apply" -->'
  fi
  printf '%s\n' ''
  printf '%s\n' '## Validation'
  printf '%s\n' ''
  emit_bullets "$TMP/validation.lst"
  printf '%s\n' ''
  printf '%s\n' '## Risks'
  printf '%s\n' ''
  emit_bullets "$TMP/risks.lst"
  printf '%s\n' ''
  printf '%s\n' '## Next'
  printf '%s\n' ''
  emit_bullets "$TMP/next.lst"
  printf '%s\n' ''
  printf '%s\n' '## Sources'
  printf '%s\n' ''
  emit_source report "$REPORT"
  if [ -n "$REVIEW" ]; then
    emit_source review "$REVIEW"
  fi
  if [ -n "$RETRO" ]; then
    emit_source retro "$RETRO"
  fi
  printf '%s\n' "- sprint: $SPRINT"
  printf '%s\n' ''
  printf '%s\n' '## Human Notes'
  printf '%s\n' ''
  printf '%s\n' '<!-- renderer 가 렌더하지 않는 MD 전용 메모 영역 (아래 블록만 재생성에서 보존됨) -->'
  printf '%s\n' ''
  cat -- "$NOTES_FILE"
} > "$NEW_MD"

mv -f -- "$NEW_MD" "$OUT_MD"

# ---------------------------------------------------------------------------
# 5. Derive the HTML projection (regenerate, never hand-edit).
# ---------------------------------------------------------------------------
"$RENDERER" "$OUT_MD" --out "$OUT_HTML" >/dev/null
printf 'sfs-publish-daily-handoff: wrote %s\n' "$OUT_MD"
printf 'sfs-publish-daily-handoff: wrote %s\n' "$OUT_HTML"
