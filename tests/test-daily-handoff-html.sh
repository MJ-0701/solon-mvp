#!/usr/bin/env bash
# daily-handoff-html renderer — regression lock.
#
# Locks the contract stated in scripts/daily-handoff-html.sh and
# commands/daily.md section MANAGER_HANDOFF:
#   - the shipped sprint-templates/daily-handoff.md, once its placeholders are
#     filled, renders with no edits to frontmatter keys or section headings;
#   - output is ONE self-contained HTML page (inline style, no scripts /
#     external assets) carrying the required metadata and all six sections;
#   - ADR decision rows render id / link / rationale as a table;
#   - literal HTML-special characters in input values are escaped;
#   - deterministic: same input bytes -> byte-identical output;
#   - malformed input (missing frontmatter key / section) exits 2, writes nothing.
# ASCII anchors only.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
RENDERER="${DIST_DIR}/templates/.sfs-local-template/scripts/daily-handoff-html.sh"
TEMPLATE="${DIST_DIR}/templates/.sfs-local-template/sprint-templates/daily-handoff.md"

TMP="$(mktemp -d "${TMPDIR:-/tmp}/sfs-daily-handoff-test.XXXXXX")"
trap 'rm -rf "${TMP}"' EXIT

fail()  { echo "FAIL: $*" >&2; exit 1; }
has()   { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
hasnt() { if grep -Fq -- "$2" "$1"; then fail "$3: must not contain '$2'"; fi; }

[[ -f "${RENDERER}" ]] || fail "missing renderer ${RENDERER}"
[[ -x "${RENDERER}" ]] || fail "renderer must be executable (chmod +x)"
[[ -f "${TEMPLATE}" ]] || fail "missing input template ${TEMPLATE}"

# 1) Fill a copy of the shipped template in a temp dir. Only placeholder
#    values are substituted — contract keys and '## ' headings stay as shipped,
#    so this also proves template and renderer agree on the contract.
IN="${TMP}/daily-handoff.md"
sed \
  -e 's/YYYY-MM-DD/2026-09-02/' \
  -e 's/OWNER_NAME/kim-mj/g' \
  -e 's/SPRINT_OR_WU_ID/WU-7/' \
  -e 's/SPRINT_ID/WU-7/' \
  -e 's/WHAT_WAS_DONE/shipped daily renderer/' \
  -e 's/TEST_OR_COMMAND_RESULT/bash -n clean/' \
  -e 's/WHY_THIS_CHOICE_WON/plain awk keeps the renderer dependency-free/' \
  -e 's/COMMAND_OR_CHECK: RESULT/bash -n on renderer: clean/' \
  -e 's/RISK_OR_BLOCKER/template drift/' \
  -e 's/NEXT_ACTION/wire render step into evening recap/' \
  "${TEMPLATE}" > "${IN}.presed"

# Escape probe: one bullet of literal HTML-special characters under Completed.
RAW='x<y & 3>2 "dq" '\''sq'\'' done'
awk -v probe="${RAW}" '{ print; if ($0 == "## Completed") print "- " probe }' \
  "${IN}.presed" > "${IN}"
rm -f "${IN}.presed"
hasnt "${IN}" "OWNER_NAME" "filled input"

# 2) Render (direct exec also locks shebang + executable bit).
OUT="${IN%.md}.html"
run_out="$("${RENDERER}" "${IN}")"
[[ -f "${OUT}" ]] || fail "renderer did not write ${OUT}"
case "${run_out}" in
  *"${OUT}"*) ;;
  *) fail "success output should name the written file, got: ${run_out}" ;;
esac

# 3) Self-contained HTML page — inline style, zero external references.
head -n 1 "${OUT}" | grep -Fqx '<!DOCTYPE html>' || fail "first line must be <!DOCTYPE html>"
has "${OUT}" "</html>" "page close"
has "${OUT}" "<style>" "inline styles"
for banned in "<script" "src=" "<link" "@import" "url(" "<iframe"; do
  hasnt "${OUT}" "${banned}" "self-contained page"
done

# 4) Required metadata + all six report sections.
has "${OUT}" '<meta charset="utf-8">' "charset meta"
has "${OUT}" 'name="generator" content="daily-handoff-html.sh' "generator meta"
has "${OUT}" "<title>Daily Handoff 2026-09-02</title>" "title carries date"
has "${OUT}" "<strong>Date</strong> 2026-09-02" "date metadata"
has "${OUT}" "<strong>Owner</strong> kim-mj" "owner metadata"
has "${OUT}" "<strong>Sprint</strong> WU-7" "sprint metadata"
has "${OUT}" 'class="status status-on-track">on-track<' "status metadata"
for sec in completed decisions validation risks next sources; do
  has "${OUT}" "<section id=\"${sec}\">" "section ${sec}"
done
for label in "Completed work" "Decisions (ADR)" "Validation evidence" \
             "Risks &amp; blockers" "Next actions" "Provenance &amp; sources"; do
  has "${OUT}" "<h2>${label}</h2>" "section label"
done
has "${OUT}" '<span class="kv">owner: kim-mj</span>' "risk/next owner kv"
has "${OUT}" '<span class="kv">status: open</span>' "risk status kv"
has "${OUT}" '<code>.sfs-local/sprints/WU-7/log.md</code>' "source as code"
has "${OUT}" "The Markdown input is the authoritative source" "derived-projection notice"

# 5) ADR decision row: id / link / rationale.
has "${OUT}" '<td class="adr-id">ADR-0000</td>' "ADR id cell"
has "${OUT}" '<code>.sfs-local/decisions/0000-example.md</code>' "ADR link cell"
has "${OUT}" '<td>plain awk keeps the renderer dependency-free</td>' "ADR rationale cell"

# 6) Literal HTML-special characters are escaped, raw probe never survives.
has "${OUT}" 'x&lt;y &amp; 3&gt;2 &quot;dq&quot; &#39;sq&#39; done' "escaped probe"
hasnt "${OUT}" "${RAW}" "raw HTML-special probe"

# 7) Deterministic: same input renders byte-identical output.
OUT2="${TMP}/second-render.html"
"${RENDERER}" "${IN}" --out "${OUT2}" >/dev/null
cmp -s "${OUT}" "${OUT2}" || fail "same input must render byte-identical output"

# 8) --out must reject the input itself and a hardlink alias before either can
# be truncated.
IN_BEFORE="${TMP}/input.before"
cp "${IN}" "${IN_BEFORE}"
rc=0; "${RENDERER}" "${IN}" --out "${IN}" >/dev/null 2>"${TMP}/err-same" || rc=$?
[[ "${rc}" -eq 2 ]] || fail "same input/output must exit 2 (got ${rc})"
cmp -s "${IN}" "${IN_BEFORE}" || fail "same input/output must preserve input"
grep -Fq "same file" "${TMP}/err-same" || fail "same input/output error should explain conflict"

IN_HARDLINK="${TMP}/daily-handoff-hardlink.html"
ln "${IN}" "${IN_HARDLINK}"
rc=0; "${RENDERER}" "${IN}" --out "${IN_HARDLINK}" >/dev/null 2>"${TMP}/err-hardlink" || rc=$?
[[ "${rc}" -eq 2 ]] || fail "hardlink input/output alias must exit 2 (got ${rc})"
cmp -s "${IN}" "${IN_BEFORE}" || fail "hardlink input/output alias must preserve input"
grep -Fq "same file" "${TMP}/err-hardlink" || fail "hardlink input/output error should explain conflict"

# 9) Malformed input fails (exit 2) without writing any output file.
BAD_KEY="${TMP}/bad-missing-owner.md"
grep -v '^owner:' "${IN}" > "${BAD_KEY}"
rc=0; "${RENDERER}" "${BAD_KEY}" >/dev/null 2>"${TMP}/err1" || rc=$?
[[ "${rc}" -eq 2 ]] || fail "missing frontmatter key must exit 2 (got ${rc})"
[[ ! -e "${BAD_KEY%.md}.html" ]] || fail "missing-key input must write nothing"
grep -Fq "owner" "${TMP}/err1" || fail "error should name the missing key"

BAD_SEC="${TMP}/bad-missing-section.md"
sed '/^## Validation$/d' "${IN}" > "${BAD_SEC}"
rc=0; "${RENDERER}" "${BAD_SEC}" >/dev/null 2>"${TMP}/err2" || rc=$?
[[ "${rc}" -eq 2 ]] || fail "missing section must exit 2 (got ${rc})"
[[ ! -e "${BAD_SEC%.md}.html" ]] || fail "missing-section input must write nothing"
grep -Fq "Validation" "${TMP}/err2" || fail "error should name the missing section"

echo "test-daily-handoff-html: OK"
