#!/usr/bin/env bash
# Gate 6 evaluator completion refreshes the active sprint's dated handoff.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-review-daily-handoff.XXXXXX")"

cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }
has() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
absent() { [[ ! -e "$1" && ! -e "$2" ]] || fail "$3: handoff was published unexpectedly"; }

init_fixture() { # $1 = fixture directory, $2 = workspace
  local root="$1" workspace="$2"
  mkdir -p "${root}"
  (
    cd "${root}"
    git init -q
    git config user.email sfs-test@example.invalid
    git config user.name 'SFS Test'
    printf '# Gate 6 Daily Handoff Fixture\n' > README.md
    git add README.md
    git commit -qm initial
    SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null
    SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" start \
      'publish one verified task unit before retro' --workspace "${workspace}" >/dev/null
    mkdir -p tools
    cat > tools/fake-pass-review.sh <<'EOF_PASS'
#!/usr/bin/env bash
printf 'Verdict: pass\n'
printf 'Validation:\n- fake evaluator verified the task unit\n'
EOF_PASS
    cat > tools/fake-fail-review.sh <<'EOF_FAIL'
#!/usr/bin/env bash
printf 'executor fixture failed\n' >&2
exit 41
EOF_FAIL
    chmod +x tools/fake-pass-review.sh tools/fake-fail-review.sh
  )
}

run_sfs() {
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_REVIEW_BRIDGE_PROBE=0 SFS_DIST_DIR="${DIST_DIR}" \
    bash "${SFS_BIN}" "$@"
}

GOOD="${TMP_DIR}/good"
init_fixture "${GOOD}" "gate6-daily-handoff"
cd "${GOOD}"

SID="$(<.sfs-local/current-sprint)"
DATE_DIR="$(date +%Y%m%d)"
HANDOFF_DIR="docs/solon/gate6-daily-handoff/${DATE_DIR}"
HANDOFF_MD="${HANDOFF_DIR}/daily-handoff.md"
HANDOFF_HTML="${HANDOFF_DIR}/daily-handoff.html"

# Non-executor review surfaces and other gates never publish the handoff.
run_sfs review --gate 6 --prompt-only >/dev/null
absent "${HANDOFF_MD}" "${HANDOFF_HTML}" "prompt-only Gate 6"
run_sfs review --gate 6 --print-prompt >/dev/null
absent "${HANDOFF_MD}" "${HANDOFF_HTML}" "print-prompt Gate 6"
run_sfs review --gate 6 --show-last >/dev/null
absent "${HANDOFF_MD}" "${HANDOFF_HTML}" "show-last Gate 6"
run_sfs review --gate 5 --allow-empty --executor ./tools/fake-pass-review.sh >/dev/null
absent "${HANDOFF_MD}" "${HANDOFF_HTML}" "non-Gate-6 evaluator run"

set +e
run_sfs review --gate 6 --allow-empty --executor ./tools/fake-fail-review.sh >"${TMP_DIR}/failed.out" 2>"${TMP_DIR}/failed.err"
FAILED_RC=$?
set -e
[[ "${FAILED_RC}" -ne 0 ]] || fail "failed evaluator must fail review"
absent "${HANDOFF_MD}" "${HANDOFF_HTML}" "failed Gate 6 evaluator run"

# An actual, non-failing Gate 6 evaluator run is the task-unit seam: it must
# create the same dated Markdown SSoT and its derived HTML before Gate 7.
REVIEW_OUT="$(run_sfs review --gate 6 --allow-empty --executor ./tools/fake-pass-review.sh)"
[[ -f "${HANDOFF_MD}" ]] || fail "Gate 6 review must create handoff Markdown"
[[ -f "${HANDOFF_HTML}" ]] || fail "Gate 6 review must create handoff HTML"
has <(printf '%s\n' "${REVIEW_OUT}") "daily handoff refreshed: ${HANDOFF_HTML}" "Gate 6 review output"
has "${HANDOFF_MD}" '- report: [report.md](report.md)' "incremental report source"
has "${HANDOFF_MD}" '- review: [review.md](' "incremental review source"
if grep -Fq -- '- retro:' "${HANDOFF_MD}"; then
  fail "incremental Gate 6 handoff must not invent unavailable retro evidence"
fi
has "${HANDOFF_HTML}" '<a href="report.md">report.md</a>' "incremental HTML report source"
has "${HANDOFF_HTML}" '>review.md</a>' "incremental HTML review source"

# Repeated verified task units refresh generated evidence but keep human notes.
NOTED="${TMP_DIR}/noted.md"
awk '
  /^<!-- human-notes:start/ { print; print "- Human note survives Gate 6 refreshes"; next }
  { print }
' "${HANDOFF_MD}" > "${NOTED}"
mv "${NOTED}" "${HANDOFF_MD}"
printf '\n## Validation\n- second verified task unit is recorded in report\n' >> "${HANDOFF_DIR}/report.md"
run_sfs review --gate 6 --allow-empty --executor ./tools/fake-pass-review.sh >/dev/null
has "${HANDOFF_MD}" 'Human note survives Gate 6 refreshes' "human notes preserved on Gate 6 refresh"
has "${HANDOFF_MD}" 'second verified task unit is recorded in report' "latest report evidence refresh"

# Incremental-publication failure is fatal before review completion is printed.
BAD="${TMP_DIR}/publisher-failure"
init_fixture "${BAD}" "gate6-publisher-failure"
BAD_RUNTIME="${BAD}/failing-renderer-runtime"
mkdir -p "${BAD_RUNTIME}/templates"
cp -R "${DIST_DIR}/templates/.sfs-local-template" "${BAD_RUNTIME}/templates/"
BAD_RENDERER="${BAD_RUNTIME}/templates/.sfs-local-template/scripts/daily-handoff-html.sh"
printf '%s\n' '#!/usr/bin/env bash' 'echo "fixture daily handoff renderer failure" >&2' 'exit 73' > "${BAD_RENDERER}"
chmod +x "${BAD_RENDERER}"
cd "${BAD}"
BAD_SID="$(<.sfs-local/current-sprint)"
BAD_DATE_DIR="$(date +%Y%m%d)"
BAD_HANDOFF_DIR="docs/solon/gate6-publisher-failure/${BAD_DATE_DIR}"
set +e
SFS_COMMAND_TIMEOUT_SEC=0 SFS_REVIEW_BRIDGE_PROBE=0 SFS_DIST_DIR="${BAD_RUNTIME}" \
  bash "${SFS_BIN}" review --gate 6 --allow-empty --executor ./tools/fake-pass-review.sh >"${TMP_DIR}/publisher-failed.out" 2>"${TMP_DIR}/publisher-failed.err"
PUBLISH_FAILED_RC=$?
set -e
[[ "${PUBLISH_FAILED_RC}" -ne 0 ]] || fail "incremental publication failure must fail review"
[[ ! -e "${BAD_HANDOFF_DIR}/daily-handoff.html" ]] \
  || fail "failed incremental publication must not leave a completed handoff pair"
has "${TMP_DIR}/publisher-failed.err" 'fixture daily handoff renderer failure' "incremental publisher error"
has "${TMP_DIR}/publisher-failed.err" 'daily handoff publication failed; review remains incomplete' "incremental fail-closed message"
if grep -Fq 'CPO run complete' "${TMP_DIR}/publisher-failed.out"; then
  fail "incremental publication failure must occur before review completion is claimed"
fi

echo "test-sfs-review-daily-handoff: OK"
