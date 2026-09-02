#!/usr/bin/env bash
# Default retro close publishes the manager handoff before evidence compaction.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-retro-daily-handoff.XXXXXX")"

cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }
has() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

init_fixture() { # $1 = fixture directory, $2 = workspace
  local root="$1" workspace="$2"
  mkdir -p "${root}"
  (
    cd "${root}"
    git init -q
    printf '# Daily Handoff Fixture\n' > README.md
    git add README.md
    git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'
    SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null
    SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" start \
      'publish close evidence through default retro' --workspace "${workspace}" >/dev/null
  )
}

write_review_evidence() { # $1 = review path, $2 = sprint id
  local review_path="$1" sprint_id="$2"
  printf '%s\n' \
    '---' \
    'phase: review' \
    'gate_number: 6' \
    'gate_label: Review' \
    'gate_id: G5' \
    "sprint_id: ${sprint_id}" \
    '---' \
    '# Review' \
    '## Verdict' \
    '- verdict: pass' \
    '## Validation' \
    '- Gate 6 review evidence is present before publication' > "${review_path}"
}

# Successful default close: report/review/retro supply the evidence, the
# publisher is executable, both artifacts are committed, and their local source
# links point to the close records beside them.
GOOD="${TMP_DIR}/good"
init_fixture "${GOOD}" "daily-handoff-fixture"
cd "${GOOD}"

SID="$(<.sfs-local/current-sprint)"
DATE_DIR="$(date +%Y%m%d)"
HANDOFF_DIR="docs/solon/daily-handoff-fixture/${DATE_DIR}"
REPORT="${HANDOFF_DIR}/report.md"
RETRO="${HANDOFF_DIR}/retro.md"
REVIEW=".sfs-local/sprints/${SID}/review.md"
PUBLISHER="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-publish-daily-handoff.sh"

SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" report >/dev/null
SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" retro --draft >/dev/null
[[ -x "${PUBLISHER}" ]] || fail "publisher must be executable"

{
  printf '\n## Completed\n- Closed work is ready for manager handoff\n'
  printf '\n## Decisions\n- ADR-0042 | docs/maintenance/adr/ADR-0042-handoff-contract.md | publish only recorded decisions\n'
  printf '\n## Validation\n- bash tests/test-sfs-retro-daily-handoff.sh: PASS\n'
  printf '\n## Risks\n- no open blocker | owner: maintainer | status: closed\n'
  printf '\n## Next\n- inspect the automatic handoff | owner: maintainer | status: pending\n'
} >> "${REPORT}"
printf '\n## Validation\n- retro evidence is present before publication\n' >> "${RETRO}"
write_review_evidence "${REVIEW}" "${SID}"
printf '{"ts":"2026-09-02T09:00:00+09:00","type":"review_open","sprint_id":"%s"}\n' "${SID}" >> .sfs-local/events.jsonl

HANDOFF_MD="${HANDOFF_DIR}/daily-handoff.md"
HANDOFF_HTML="${HANDOFF_DIR}/daily-handoff.html"
"${PUBLISHER}" --report "${REPORT}" --review "${REVIEW}" --retro "${RETRO}" \
  --sprint "${SID}" --out-dir "${HANDOFF_DIR}" >/dev/null
has "${HANDOFF_MD}" '- report: [report.md](report.md)' "Markdown report source"
has "${HANDOFF_MD}" '- review: [review.md](' "Markdown review source"
has "${HANDOFF_MD}" '- retro: [retro.md](retro.md)' "Markdown retro source"
has "${HANDOFF_HTML}" '<a href="report.md">report.md</a>' "HTML report source link"
has "${HANDOFF_HTML}" '>review.md</a>' "HTML review source link"
has "${HANDOFF_HTML}" '<a href="retro.md">retro.md</a>' "HTML retro source link"
[[ -f "${HANDOFF_DIR}/report.md" && -f "${HANDOFF_DIR}/retro.md" ]] \
  || fail "source-link targets must exist beside the handoff"
has "${HANDOFF_MD}" 'ADR-0042 | docs/maintenance/adr/ADR-0042-handoff-contract.md | publish only recorded decisions' "explicit ADR evidence"
has "${HANDOFF_HTML}" '<td class="adr-id">ADR-0042</td>' "explicit ADR HTML row"
if grep -Fq 'ADR-0000' "${HANDOFF_MD}"; then
  fail "publisher must not invent template ADR ids"
fi

# Neither source may be a generated handoff output, including a hardlink
# alias. The preflight must leave both outputs untouched.
HANDOFF_MD_BEFORE="${TMP_DIR}/daily-handoff-md.before"
HANDOFF_HTML_BEFORE="${TMP_DIR}/daily-handoff-html.before"
cp "${HANDOFF_MD}" "${HANDOFF_MD_BEFORE}"
cp "${HANDOFF_HTML}" "${HANDOFF_HTML_BEFORE}"
assert_publisher_rejects_source() { # $1 = label, $2 = report, $3 = retro
  local label="$1" report_source="$2" retro_source="$3" rc=0
  "${PUBLISHER}" --report "${report_source}" --review "${REVIEW}" --retro "${retro_source}" \
    --sprint "${SID}" --out-dir "${HANDOFF_DIR}" >"${TMP_DIR}/${label}.out" 2>"${TMP_DIR}/${label}.err" || rc=$?
  [[ "${rc}" -eq 2 ]] || fail "${label} must exit 2 (got ${rc})"
  has "${TMP_DIR}/${label}.err" "source and output are the same file" "${label} error"
  cmp -s "${HANDOFF_MD}" "${HANDOFF_MD_BEFORE}" || fail "${label} must preserve handoff Markdown"
  cmp -s "${HANDOFF_HTML}" "${HANDOFF_HTML_BEFORE}" || fail "${label} must preserve handoff HTML"
}

assert_publisher_rejects_source "report-md" "${HANDOFF_MD}" "${RETRO}"
assert_publisher_rejects_source "retro-html" "${REPORT}" "${HANDOFF_HTML}"
HANDOFF_MD_HARDLINK="${TMP_DIR}/daily-handoff-md-hardlink"
HANDOFF_HTML_HARDLINK="${TMP_DIR}/daily-handoff-html-hardlink"
ln "${HANDOFF_MD}" "${HANDOFF_MD_HARDLINK}"
ln "${HANDOFF_HTML}" "${HANDOFF_HTML_HARDLINK}"
assert_publisher_rejects_source "report-md-hardlink" "${HANDOFF_MD_HARDLINK}" "${RETRO}"
assert_publisher_rejects_source "retro-html-hardlink" "${REPORT}" "${HANDOFF_HTML_HARDLINK}"

# Only the marked human-notes block survives an idempotent republish.
NOTED="${TMP_DIR}/noted.md"
awk '
  /^<!-- human-notes:start/ { print; print "- Human note survives publication reruns"; next }
  { print }
' "${HANDOFF_MD}" > "${NOTED}"
mv "${NOTED}" "${HANDOFF_MD}"
REPUBLISH_OUT="$("${PUBLISHER}" --report "${REPORT}" --review "${REVIEW}" --retro "${RETRO}" --sprint "${SID}" --out-dir "${HANDOFF_DIR}")"
case "${REPUBLISH_OUT}" in
  *"${HANDOFF_MD}"*"${HANDOFF_HTML}"*) ;;
  *) fail "publisher success output must name both artifacts: ${REPUBLISH_OUT}" ;;
esac
has "${HANDOFF_MD}" 'Human note survives publication reruns' "human notes preserved"

CLOSE_OUT="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" retro)"
has <(printf '%s\n' "${CLOSE_OUT}") "daily handoff ready: ${HANDOFF_DIR}/daily-handoff.html" "retro output"
[[ -f "${HANDOFF_DIR}/daily-handoff.md" ]] || fail "daily handoff Markdown missing"
[[ -f "${HANDOFF_DIR}/daily-handoff.html" ]] || fail "daily handoff HTML missing"
git ls-files --error-unmatch "${HANDOFF_DIR}/daily-handoff.md" >/dev/null 2>&1 \
  || fail "close commit must include handoff Markdown"
git ls-files --error-unmatch "${HANDOFF_DIR}/daily-handoff.html" >/dev/null 2>&1 \
  || fail "close commit must include handoff HTML"
has "${HANDOFF_MD}" 'Human note survives publication reruns' "human notes preserved after close"

# Publication failure must stop default close before compaction or current-sprint
# removal; a fixture-local failing renderer makes the internal publisher fail.
BAD="${TMP_DIR}/publisher-failure"
init_fixture "${BAD}" "daily-handoff-failure"
cd "${BAD}"
BAD_SID="$(<.sfs-local/current-sprint)"
BAD_PLAN=".sfs-local/sprints/${BAD_SID}/plan.md"
BAD_REVIEW=".sfs-local/sprints/${BAD_SID}/review.md"
BAD_DATE_DIR="$(date +%Y%m%d)"
BAD_HANDOFF_DIR="docs/solon/daily-handoff-failure/${BAD_DATE_DIR}"
BAD_RUNTIME="${BAD}/failing-renderer-runtime"
printf '%s\n' '---' 'status: active' '---' '# Fixture workbench plan' > "${BAD_PLAN}"
mkdir -p "${BAD_RUNTIME}/templates"
cp -R "${DIST_DIR}/templates/.sfs-local-template" "${BAD_RUNTIME}/templates/"
BAD_RENDERER="${BAD_RUNTIME}/templates/.sfs-local-template/scripts/daily-handoff-html.sh"
printf '%s\n' '#!/usr/bin/env bash' 'echo "fixture daily handoff renderer failure" >&2' 'exit 73' > "${BAD_RENDERER}"
chmod +x "${BAD_RENDERER}"
SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" retro --draft >/dev/null
SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" report >/dev/null
write_review_evidence "${BAD_REVIEW}" "${BAD_SID}"
printf '{"ts":"2026-09-02T09:00:00+09:00","type":"review_open","sprint_id":"%s"}\n' "${BAD_SID}" >> .sfs-local/events.jsonl
set +e
SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${BAD_RUNTIME}" bash "${SFS_BIN}" retro >"${TMP_DIR}/bad.out" 2>"${TMP_DIR}/bad.err"
BAD_RC=$?
set -e
[[ "${BAD_RC}" -ne 0 ]] || fail "publication failure must fail retro close"
[[ -f .sfs-local/current-sprint ]] || fail "failed publication must leave sprint active"
[[ -f "${BAD_PLAN}" ]] || fail "failed publication must not compact workbench"
has "${TMP_DIR}/bad.err" 'fixture daily handoff renderer failure' "fixture renderer failure"
has "${TMP_DIR}/bad.err" 'daily handoff publication failed; sprint remains open' "publication failure message"

echo "test-sfs-retro-daily-handoff: OK"
