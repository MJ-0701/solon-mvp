#!/usr/bin/env bash
# .sfs-local/scripts/daily-handoff-html.sh
#
# Solon SFS — manager-readable daily handoff HTML renderer.
# Renders ONE explicit daily-handoff Markdown input (a filled copy of
# sprint-templates/daily-handoff.md) into ONE self-contained HTML page.
#
# Contract (locked by tests/test-daily-handoff-html.sh):
#   - deterministic: same input bytes -> byte-identical output; reads no
#     clock, no git history, no implicit project state — only the input file;
#   - dependency-free: bash 3.2+ / POSIX awk only, zero network/JS/assets;
#   - safe: every input value is HTML-escaped; only http(s) URLs and explicit
#     relative Markdown links in the generated Sources section link;
#   - derived projection: the Markdown input stays the authoritative source
#     (release-policy live-status pattern) — regenerate, never hand-edit HTML.
#
# This is a standalone helper invoked directly, NOT an `sfs` dispatched
# command: commands/daily.md keeps its "composition, not a binary" contract
# and sfs-dispatch.sh must never route a daily verb
# (tests/test-daily-bookend-loop.sh). Flow doc: context/commands/daily.md
# section MANAGER_HANDOFF.
#
# Path note: dev staging file lives at
#   templates/.sfs-local-template/scripts/daily-handoff-html.sh
# install.sh copies templates/.sfs-local-template/ -> consumer .sfs-local/.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  daily-handoff-html.sh <daily-handoff.md> [--out <file.html>]

Renders a filled daily-handoff Markdown input (copy of
sprint-templates/daily-handoff.md) into a self-contained, manager-readable
HTML page. Default output path = input path with .md replaced by .html.

Required frontmatter keys : date / owner / sprint / status
Required section headings : ## Completed / ## Decisions / ## Validation
                            ## Risks / ## Next / ## Sources

Exit 0 on success (prints the output path); exit 2 on missing input,
missing required keys, or missing required sections. The Markdown input is
the authoritative source; the HTML page is a derived projection.
EOF
}

INPUT=""
OUT=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help|help) usage; exit 0 ;;
    --out) OUT="${2:-}"; [ -n "$OUT" ] || { echo "missing value for --out" >&2; exit 2; }; shift 2 ;;
    --out=*) OUT="${1#*=}"; shift ;;
    -*) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
    *)
      if [ -z "$INPUT" ]; then INPUT="$1"; shift
      else echo "unexpected extra argument: $1" >&2; usage >&2; exit 2; fi ;;
  esac
done

[ -n "$INPUT" ] || { usage >&2; exit 2; }
[ -f "$INPUT" ] || { echo "daily-handoff-html: input not found: $INPUT" >&2; exit 2; }
if [ -z "$OUT" ]; then
  case "$INPUT" in
    *.md) OUT="${INPUT%.md}.html" ;;
    *)    OUT="${INPUT}.html" ;;
  esac
fi
if [ "$INPUT" = "$OUT" ] || { [ -e "$OUT" ] && [ "$INPUT" -ef "$OUT" ]; }; then
  echo "daily-handoff-html: input and output are the same file: $INPUT" >&2
  exit 2
fi

# Single-pass POSIX awk: buffer frontmatter + the six known sections, validate
# in END, then emit the page. Nothing is written unless validation passes
# (command substitution + set -e aborts before the redirect on exit 2).
HTML="$(SFS_DH_SRC="$INPUT" awk '
  function esc(s) {
    gsub(/&/,  "\\&amp;",  s)
    gsub(/</,  "\\&lt;",   s)
    gsub(/>/,  "\\&gt;",   s)
    gsub(/"/,  "\\&quot;", s)
    gsub(sq,   "\\&#39;",  s)
    return s
  }
  function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
  function source_linkify(s,   token, label, href, prefix) {
    if (!match(s, /\[[^]]+\]\([^)]+\)[ \t]*$/)) return "<code>" esc(s) "</code>"
    prefix = substr(s, 1, RSTART - 1)
    token = substr(s, RSTART, RLENGTH)
    label = token; sub(/^\[/, "", label); sub(/\]\(.*/, "", label)
    href = token; sub(/^.*\]\(/, "", href); sub(/\)[ \t]*$/, "", href)
    if (href ~ /^https?:\/\// || href ~ /^(\.\.\/)*(\.\/)?[A-Za-z0-9.][A-Za-z0-9._\/-]*$/)
      return esc(prefix) "<a href=\"" esc(href) "\">" esc(label) "</a>"
    return "<code>" esc(s) "</code>"
  }
  function linkify(s) {
    if (s ~ /^https?:\/\//) return "<a href=\"" esc(s) "\">" esc(s) "</a>"
    return "<code>" esc(s) "</code>"
  }
  function emit_list(i,   j, n, p, k, out) {
    print "<ul>"
    if (cnt[i] == 0) print "<li class=\"empty\">(none reported)</li>"
    for (j = 1; j <= cnt[i]; j++) {
      if (i == 6) {
        print "<li>" source_linkify(body[i, j]) "</li>"
      } else if (i == 4 || i == 5) {
        n = split(body[i, j], p, /[ \t]*\|[ \t]*/)
        out = esc(p[1])
        for (k = 2; k <= n; k++) out = out " <span class=\"kv\">" esc(p[k]) "</span>"
        print "<li>" out "</li>"
      } else {
        print "<li>" esc(body[i, j]) "</li>"
      }
    }
    print "</ul>"
  }
  function emit_decisions(   j, n, p, rat, k) {
    print "<table class=\"adr\">"
    print "<thead><tr><th>ADR</th><th>Link</th><th>Rationale</th></tr></thead>"
    print "<tbody>"
    if (cnt[2] == 0)
      print "<tr><td colspan=\"3\" class=\"empty\">(none: ADR gate did not apply)</td></tr>"
    for (j = 1; j <= cnt[2]; j++) {
      n = split(body[2, j], p, /[ \t]*\|[ \t]*/)
      if (n >= 2) {
        rat = ""
        for (k = 3; k <= n; k++) rat = rat (k > 3 ? " | " : "") p[k]
        print "<tr><td class=\"adr-id\">" esc(p[1]) "</td><td>" linkify(p[2]) "</td><td>" esc(rat) "</td></tr>"
      } else {
        print "<tr><td colspan=\"3\">" esc(body[2, j]) "</td></tr>"
      }
    }
    print "</tbody>"
    print "</table>"
  }
  BEGIN {
    sq = sprintf("%c", 39)   # single-quote char, kept out of this program text
    nsec = 6
    name[1] = "Completed";  label[1] = "Completed work"
    name[2] = "Decisions";  label[2] = "Decisions (ADR)"
    name[3] = "Validation"; label[3] = "Validation evidence"
    name[4] = "Risks";      label[4] = "Risks &amp; blockers"
    name[5] = "Next";       label[5] = "Next actions"
    name[6] = "Sources";    label[6] = "Provenance &amp; sources"
    for (i = 1; i <= nsec; i++) { idx[name[i]] = i; cnt[i] = 0; seen[i] = 0 }
    fm = 0; cur = 0
  }
  { sub(/\r$/, "") }
  NR == 1 && $0 == "---" { fm = 1; next }
  fm == 1 && $0 == "---" { fm = 0; next }
  fm == 1 {
    line = $0
    sub(/[ \t]+#.*$/, "", line)
    if (match(line, /^[A-Za-z][A-Za-z0-9_-]*:/)) {
      key = substr(line, 1, RLENGTH - 1)
      val = trim(substr(line, RLENGTH + 1))
      gsub(/^"|"$/, "", val)
      meta[key] = val
    }
    next
  }
  /^## / {
    h = trim(substr($0, 4))
    if (h in idx) { cur = idx[h]; seen[cur] = 1 } else { cur = 0 }
    next
  }
  /^- / {
    if (cur > 0) {
      item = trim(substr($0, 3))
      if (item != "") { cnt[cur]++; body[cur, cnt[cur]] = item }
    }
    next
  }
  END {
    missing = ""
    nreq = split("date owner sprint status", req, " ")
    for (i = 1; i <= nreq; i++)
      if (!(req[i] in meta) || meta[req[i]] == "")
        missing = missing (missing == "" ? "" : ", ") "frontmatter " req[i]
    for (i = 1; i <= nsec; i++)
      if (!seen[i])
        missing = missing (missing == "" ? "" : ", ") "section ## " name[i]
    if (missing != "") {
      print "daily-handoff-html: input missing required fields: " missing > "/dev/stderr"
      exit 2
    }
    d = esc(meta["date"]); ow = esc(meta["owner"])
    sp = esc(meta["sprint"]); st = esc(meta["status"])
    scls = tolower(meta["status"])
    gsub(/[^a-z0-9]+/, "-", scls); gsub(/^-+|-+$/, "", scls)
    if (scls == "") scls = "unknown"
    lang = ("lang" in meta && meta["lang"] != "") ? meta["lang"] : "en"
    print "<!DOCTYPE html>"
    print "<html lang=\"" esc(lang) "\">"
    print "<head>"
    print "<meta charset=\"utf-8\">"
    print "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
    print "<meta name=\"generator\" content=\"daily-handoff-html.sh v1\">"
    print "<title>Daily Handoff " d "</title>"
    print "<style>"
    print "* { box-sizing: border-box; }"
    print "body { margin: 0; padding: 24px 16px; background: #f4f5f7; color: #1c2733;"
    print "  font: 15px/1.55 -apple-system, BlinkMacSystemFont, Roboto, Arial, sans-serif; }"
    print "main { max-width: 860px; margin: 0 auto; background: #fff;"
    print "  border: 1px solid #dde3ea; border-radius: 10px; padding: 28px 32px; }"
    print "header { border-bottom: 2px solid #1c2733; padding-bottom: 12px; }"
    print "h1 { margin: 0 0 10px; font-size: 24px; }"
    print "h2 { font-size: 16px; margin: 24px 0 8px; }"
    print ".meta { margin: 0; }"
    print ".kv { display: inline-block; background: #eef1f5; border-radius: 6px;"
    print "  padding: 2px 8px; margin: 0 6px 4px 0; font-size: 13px; }"
    print ".kv strong { color: #5a6b7d; font-weight: 600; margin-right: 4px; }"
    print ".status { display: inline-block; border-radius: 6px; padding: 2px 10px;"
    print "  font-size: 13px; font-weight: 700; background: #e2e6eb; color: #3d4a57; }"
    print ".status-on-track { background: #d9f0e1; color: #14683a; }"
    print ".status-done { background: #dbe9fb; color: #1c4f93; }"
    print ".status-at-risk { background: #fbeed2; color: #8a5a06; }"
    print ".status-blocked { background: #fadcd9; color: #a02318; }"
    print "section { border-top: 1px solid #e6ebf1; }"
    print "section:first-of-type { border-top: 0; }"
    print "ul { margin: 6px 0; padding-left: 22px; }"
    print "li { margin: 4px 0; }"
    print "li.empty { list-style: none; color: #7a8794; }"
    print "td.empty { color: #7a8794; }"
    print "code { background: #f0f2f5; border-radius: 4px; padding: 1px 5px; font-size: 13px;"
    print "  font-family: ui-monospace, Menlo, Consolas, monospace; }"
    print "a { color: #175bcc; }"
    print "table.adr { width: 100%; border-collapse: collapse; margin: 8px 0; font-size: 14px; }"
    print "table.adr th, table.adr td { border: 1px solid #e0e5ec; padding: 6px 10px;"
    print "  text-align: left; vertical-align: top; }"
    print "table.adr th { background: #f4f6f9; color: #5a6b7d; font-size: 12px;"
    print "  text-transform: uppercase; letter-spacing: 0.04em; }"
    print "td.adr-id { white-space: nowrap; font-weight: 600; }"
    print "footer { margin-top: 28px; border-top: 1px solid #e6ebf1; padding-top: 10px;"
    print "  color: #7a8794; font-size: 12px; }"
    print "@media print { body { background: #fff; padding: 0; } main { border: 0; padding: 0; } }"
    print "</style>"
    print "</head>"
    print "<body>"
    print "<main>"
    print "<header>"
    print "<h1>Daily Handoff</h1>"
    print "<p class=\"meta\">"
    print "<span class=\"kv\"><strong>Date</strong> " d "</span>"
    print "<span class=\"kv\"><strong>Owner</strong> " ow "</span>"
    print "<span class=\"kv\"><strong>Sprint</strong> " sp "</span>"
    print "<span class=\"status status-" scls "\">" st "</span>"
    print "</p>"
    print "</header>"
    for (i = 1; i <= nsec; i++) {
      print "<section id=\"" tolower(name[i]) "\">"
      print "<h2>" label[i] "</h2>"
      if (i == 2) emit_decisions(); else emit_list(i)
      print "</section>"
    }
    print "<footer>"
    print "<p>Generated by <code>daily-handoff-html.sh</code> from <code>" esc(ENVIRON["SFS_DH_SRC"]) "</code>."
    print "The Markdown input is the authoritative source: regenerate this page, do not hand-edit.</p>"
    print "</footer>"
    print "</main>"
    print "</body>"
    print "</html>"
  }
' "$INPUT")"

printf '%s\n' "$HTML" > "$OUT"
printf 'daily-handoff-html: wrote %s\n' "$OUT"
