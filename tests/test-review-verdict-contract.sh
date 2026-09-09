#!/usr/bin/env bash
# WU1 review verdict contract의 정적 문서 표면을 검증한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1"
  local expected="$2"

  grep -Fq -- "${expected}" "${file}" || fail "${file#"${DIST_DIR}/"} is missing: ${expected}"
}

if [[ "$#" -gt 0 ]] && [[ "$#" -ne 2 || "$1" != "--only" || "$2" != "contract_text" ]]; then
  fail "usage: $0 [--only contract_text]"
fi

review_command="${DIST_DIR}/templates/.sfs-local-template/context/commands/review.md"
kernel="${DIST_DIR}/templates/.sfs-local-template/context/kernel.md"
cpo="${DIST_DIR}/templates/.sfs-local-template/personas/cpo-evaluator.md"
review_template="${DIST_DIR}/templates/.sfs-local-template/sprint-templates/review.md"

assert_contains "${review_command}" "## Verdict Contract"
assert_contains "${review_command}" "Goal, scope, and non-goals are present."
assert_contains "${review_command}" "Requirement ↔ AC ↔ work-unit traceability is complete."
assert_contains "${review_command}" "Every AC names a verify-by command."
assert_contains "${review_command}" "Security, PII, and data-loss considerations are recorded or explicitly waived."
assert_contains "${review_command}" "The user-approval boundary is stated."
assert_contains "${review_command}" "Open questions and blind spots are both zero."
assert_contains "${review_command}" "Static checks pass."
assert_contains "${review_command}" "seven sequential stages — syntax/type, format, code security, dependency"
assert_contains "${review_command}" 'Implementation Acceptance Ledger marks every planned AC as `implemented`,'
assert_contains "${review_command}" 'approved `deferred`, or `waived`.'
assert_contains "${review_command}" "A blocking finding must name the violated numbered PASS criterion."
assert_contains "${review_command}" '[Critical] G<n>-<criterion>'
assert_contains "${review_command}" '[Required] G<n>-<criterion>'
assert_contains "${review_command}" 'one or more `Required` findings produce `partial`.'
assert_contains "${review_command}" 'and `FYI` items are advisories only and produce `pass` regardless of advisory'
assert_contains "${review_command}" 'self review has a maximum of two runs and cross'
assert_contains "${review_command}" 'review has a maximum of one run.'
assert_contains "${review_command}" 'converged: pass-with-advisories'
assert_contains "${review_command}" 'Self review defaults to the no-executor `author-check`'
assert_contains "${review_command}" 'Exclude `gate*-rework-log.md`,'
assert_contains "${review_command}" '`review-archive-*.md`, and `llm-wiki/**` unless the plan declares the file in'
assert_contains "${kernel}" 'Apply the numbered Verdict Contract in `commands/review.md`: only `Critical` and `Required` violations of an applicable PASS criterion can block a verdict.'
assert_contains "${cpo}" '- Verdict: `pass` | `partial` | `fail` only'
assert_contains "${cpo}" '- Blocking findings: N'
assert_contains "${cpo}" '- Advisories: N'
assert_contains "${cpo}" '[Critical] G<n>-<criterion>'
assert_contains "${cpo}" '[Required] G<n>-<criterion>'
assert_contains "${cpo}" '## Advisories'
assert_contains "${cpo}" 'This exclusion also'
assert_contains "${cpo}" 'applies to the `docs` lens.'
assert_contains "${review_template}" '### PASS 체크리스트'
assert_contains "${review_template}" '| PASS criterion | 확인 근거 | 상태 (pass/missing/waived) |'
assert_contains "${review_template}" '## 3.1 Advisories'

quality_gate="${DIST_DIR}/templates/.sfs-local-template/scripts/quality-gate.sh"
[[ -x "${quality_gate}" ]] || fail "consumer quality-gate.sh must be executable"
bash -n "${quality_gate}" || fail "consumer quality-gate.sh is not valid bash"
assert_contains "${quality_gate}" 'umask 077'
assert_contains "${quality_gate}" 'chmod 600 "$log"'
assert_contains "${quality_gate}" 'trap cleanup EXIT HUP INT TERM'
assert_contains "${quality_gate}" 'REDACTED-SECRET'
assert_contains "${quality_gate}" 'STAGE %d/7'

gate_fixture="$(mktemp -d)"
contract_fixture=""
cleanup_gate_fixture() {
  rm -rf "${gate_fixture}"
  [[ -z "${contract_fixture}" ]] || rm -rf "${contract_fixture}"
}
trap cleanup_gate_fixture EXIT
mkdir -p "${gate_fixture}/bin"
printf '[project]\nname = "fixture"\nversion = "0"\n' > "${gate_fixture}/pyproject.toml"
for tool in pyright ruff semgrep pip-audit gitleaks pytest; do
  cat > "${gate_fixture}/bin/${tool}" <<'EOF'
#!/usr/bin/env bash
printf 'tool=%s secret=sk-abcdefghijklmnopqrstuvwxyz email=fixture@example.com\n' "$(basename "$0")"
EOF
  chmod +x "${gate_fixture}/bin/${tool}"
done

gate_out="$(cd "${gate_fixture}" && PATH="${gate_fixture}/bin:${PATH}" bash "${quality_gate}" --mode pr)"
printf '%s\n' "${gate_out}" | grep -q 'STAGE 1/7 syntax/type: PASS' || fail "quality gate must run syntax/type first"
printf '%s\n' "${gate_out}" | grep -q 'STAGE 7/7 regression tests: SKIP' || fail "pr mode must record regression SKIP"
printf '%s\n' "${gate_out}" | grep -q 'last 20 lines (redacted)' || fail "quality gate must summarize each run stage"
printf '%s\n' "${gate_out}" | grep -q '\[REDACTED-SECRET\]' || fail "quality gate must redact synthetic secrets"
if printf '%s\n' "${gate_out}" | grep -q 'fixture@example.com'; then
  fail "quality gate must redact synthetic PII"
fi
printf '%s\n' "${gate_out}" | grep -q 'QUALITY GATE: PASS (mode=pr)' || fail "fully tooled fixture must pass"

rm -f "${gate_fixture}/bin/gitleaks"
set +e
missing_out="$(cd "${gate_fixture}" && PATH="${gate_fixture}/bin:${PATH}" bash "${quality_gate}" --mode pr 2>&1)"
missing_rc=$?
set -e
[[ "${missing_rc}" -ne 0 ]] || fail "missing gitleaks must fail the consumer gate"
printf '%s\n' "${missing_out}" | grep -q 'credentials: FAIL(required tool skipped)' || fail "gitleaks skip must be explicit"

set +e
bash "${quality_gate}" --mode invalid >/dev/null 2>&1
invalid_rc=$?
set -e
[[ "${invalid_rc}" -eq 2 ]] || fail "quality gate must accept only --mode pr|full"

# Functional review-runtime fixture.  This deliberately uses `sfs init` and
# `sfs start`, as the other SFS runtime tests do, so the assertions cover the
# installed consumer template rather than implementation text in this repo.
contract_fixture="$(mktemp -d "${TMPDIR:-/tmp}/sfs-review-verdict-contract.XXXXXX")"

run_sfs() {
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_REVIEW_BRIDGE_PROBE=0 SFS_DIST_DIR="${DIST_DIR}" \
    bash "${DIST_DIR}/bin/sfs" "$@"
}

init_review_fixture() { # $1 = consumer repository directory, $2 = sprint goal
  local root="$1" goal="$2"
  mkdir -p "${root}"
  (
    cd "${root}"
    git init -q
    git config user.email sfs-test@example.invalid
    git config user.name 'SFS Review Verdict Test'
    printf '# Review verdict fixture\n' > README.md
    git add README.md
    git commit -qm initial
    run_sfs init --layout thin --yes >/dev/null
    run_sfs start "${goal}" >/dev/null
    mkdir -p tools
  )
}

write_result_executor() { # $1 = fixture root
  cat > "$1/tools/result-executor.sh" <<'EOF_RESULT'
#!/usr/bin/env bash
set -euo pipefail
cat >/dev/null
case "${1:?result kind required}" in
  optional)
    cat <<'RESULT'
Verdict: partial
Blocking findings: 0
Advisories: 2
Findings:
- none
Advisory details:
- [Optional] wording preference
- [FYI] future cleanup note
RESULT
    ;;
  required)
    cat <<'RESULT'
Verdict: partial
Blocking findings: 1
Advisories: 0
Findings:
- [Required] [Gate PASS: G3-1] the required plan criterion is missing
RESULT
    ;;
  critical)
    cat <<'RESULT'
Verdict: fail
Blocking findings: 1
Advisories: 0
Findings:
- [Critical] [Gate PASS: G3-4] security invariant is not met
RESULT
    ;;
  *)
    printf 'unknown fixture result kind: %s\n' "$1" >&2
    exit 64
    ;;
esac
EOF_RESULT
  chmod +x "$1/tools/result-executor.sh"
}

assert_event_contains() { # $1 = file, $2 = literal event fragment, $3 = label
  grep -Fq -- "$2" "$1" || fail "$3: missing event fragment '$2'"
}

# (a), (b), and (c): exercise the executor result parser and durable
# review_run records, including the required normalization from partial + 0.
VERDICTS="${contract_fixture}/verdicts"
init_review_fixture "${VERDICTS}" 'exercise evaluator verdict records'
write_result_executor "${VERDICTS}"
(
  cd "${VERDICTS}"
  optional_out="$(run_sfs review --gate 3 --stage artifact --allow-empty --executor './tools/result-executor.sh optional')"
  case "${optional_out}" in
    *'verdict: pass'*'blocking_findings: 0'*'normalized_fact: declared partial with 0 validated blocking findings normalized to pass'*) ;;
    *) fail "Optional/FYI-only evaluator result must normalize to pass with Blocking 0; output: ${optional_out}" ;;
  esac
  assert_event_contains .sfs-local/events.jsonl '"declared_verdict":"partial","result_verdict":"pass","blocking_findings":0' \
    'Optional/FYI-only review_run'

  required_out="$(run_sfs review --gate 3 --stage artifact --allow-empty --executor './tools/result-executor.sh required')"
  case "${required_out}" in
    *'verdict: partial'*'blocking_findings: 1'*) ;;
    *) fail "Required evaluator result must be partial; output: ${required_out}" ;;
  esac
  assert_event_contains .sfs-local/events.jsonl '"declared_verdict":"partial","result_verdict":"partial","blocking_findings":1' \
    'Required review_run'

  critical_out="$(run_sfs review --gate 3 --stage artifact --allow-empty --executor './tools/result-executor.sh critical')"
  case "${critical_out}" in
    *'verdict: fail'*'blocking_findings: 1'*) ;;
    *) fail "Critical evaluator result must fail; output: ${critical_out}" ;;
  esac
  assert_event_contains .sfs-local/events.jsonl '"declared_verdict":"fail","result_verdict":"fail","blocking_findings":1' \
    'Critical review_run'
)

# (d): the cap must beat an explicitly supplied executor on the third same-gate
# self run. The marker makes an accidental third bridge invocation observable.
CONVERGENCE="${contract_fixture}/convergence"
init_review_fixture "${CONVERGENCE}" 'exercise self convergence without executor'
cat > "${CONVERGENCE}/tools/counting-pass.sh" <<'EOF_COUNTING'
#!/usr/bin/env bash
set -euo pipefail
cat >/dev/null
printf 'called\n' >> tools/executor-called.txt
cat <<'RESULT'
Verdict: pass
Blocking findings: 0
Advisories: 0
Findings:
- none
RESULT
EOF_COUNTING
chmod +x "${CONVERGENCE}/tools/counting-pass.sh"
(
  cd "${CONVERGENCE}"
  run_sfs review --gate 3 --stage self --allow-empty --executor ./tools/counting-pass.sh >/dev/null
  run_sfs review --gate 3 --stage self --allow-empty --executor ./tools/counting-pass.sh >/dev/null
  convergence_out="$(run_sfs review --gate 3 --stage self --allow-empty --executor ./tools/counting-pass.sh)"
  [[ "$(wc -l < tools/executor-called.txt | tr -d '[:space:]')" == "2" ]] \
    || fail "third same-gate self review invoked the executor after two 0-blocking records"
  case "${convergence_out}" in
    *'blocking_findings: 0'*'converged pass-with-advisories after the self same-gate round cap'*) ;;
    *) fail "third same-gate self review must emit converged pass-with-advisories without executor; output: ${convergence_out}" ;;
  esac
  assert_event_contains .sfs-local/events.jsonl '"self_cpo":"converged"' 'converged self review_run'
  assert_event_contains .sfs-local/events.jsonl '"executor_invoked":false' 'converged self review_run'
)

# (e): have an evaluator inspect the actual generated prompt. It fails with a
# small contract diagnosis when a forbidden file leaks into the bundle, rather
# than testing implementation strings or silently accepting an unavailable seam.
BUNDLE="${contract_fixture}/bundle"
init_review_fixture "${BUNDLE}" 'exercise frozen review bundle references'
mkdir -p "${BUNDLE}/llm-wiki"
printf 'must stay out of the bundle\n' > "${BUNDLE}/gate3-rework-log.md"
printf 'must stay out of the bundle\n' > "${BUNDLE}/review-archive-old.md"
printf 'must stay out of the bundle\n' > "${BUNDLE}/llm-wiki/unreferenced.md"
printf 'this is the one declared reference\n' > "${BUNDLE}/llm-wiki/declared-plan-reference.md"
sprint_id="$(<"${BUNDLE}/.sfs-local/current-sprint")"
cat > "${BUNDLE}/.sfs-local/sprints/${sprint_id}/plan.md" <<'EOF_PLAN'
---
phase: plan
---

# Frozen bundle fixture

## References
- `llm-wiki/declared-plan-reference.md`
EOF_PLAN
cat > "${BUNDLE}/tools/bundle-executor.sh" <<'EOF_BUNDLE'
#!/usr/bin/env bash
set -euo pipefail
prompt="$(cat)"
for forbidden in gate3-rework-log.md review-archive-old.md llm-wiki/unreferenced.md; do
  if grep -Fq -- "${forbidden}" <<<"${prompt}"; then
    cat <<RESULT
Verdict: partial
Blocking findings: 1
Advisories: 0
Findings:
- [Required] [Gate PASS: G3-1] frozen bundle leaked ${forbidden}
RESULT
    exit 0
  fi
done
if ! grep -Fq -- 'llm-wiki/declared-plan-reference.md' <<<"${prompt}"; then
  cat <<'RESULT'
Verdict: partial
Blocking findings: 1
Advisories: 0
Findings:
- [Required] [Gate PASS: G3-1] frozen bundle omitted the exact plan references declaration
RESULT
  exit 0
fi
cat <<'RESULT'
Verdict: pass
Blocking findings: 0
Advisories: 0
Findings:
- none
RESULT
EOF_BUNDLE
chmod +x "${BUNDLE}/tools/bundle-executor.sh"
(
  cd "${BUNDLE}"
  bundle_out="$(run_sfs review --gate 3 --stage artifact --allow-empty --executor ./tools/bundle-executor.sh)"
  case "${bundle_out}" in
    *'verdict: pass'*'blocking_findings: 0'*) ;;
    *) fail "frozen bundle must exclude rework/archive/unreferenced llm-wiki while retaining its exact plan reference; output: ${bundle_out}" ;;
  esac
)

# (f): an ambient fake executor must remain untouched when no --executor flag
# was supplied; only the author-check review_run may be recorded.
AUTHOR_CHECK="${contract_fixture}/author-check"
init_review_fixture "${AUTHOR_CHECK}" 'exercise no-executor self author check'
cat > "${AUTHOR_CHECK}/tools/must-not-run.sh" <<'EOF_NO_RUN'
#!/usr/bin/env bash
printf 'unexpected executor invocation\n' >> tools/fake-executor-called.txt
exit 97
EOF_NO_RUN
chmod +x "${AUTHOR_CHECK}/tools/must-not-run.sh"
(
  cd "${AUTHOR_CHECK}"
  author_out="$(SFS_REVIEW_EXECUTOR=./tools/must-not-run.sh run_sfs review --gate 3 --stage self --allow-empty)"
  [[ ! -e tools/fake-executor-called.txt ]] || fail "--stage self without --executor ran the fake executor"
  case "${author_out}" in
    *'verdict: pass'*'blocking_findings: 0'*) ;;
    *) fail "--stage self without --executor must produce an author-check result; output: ${author_out}" ;;
  esac
  assert_event_contains .sfs-local/events.jsonl '"self_cpo":"author-check"' 'author-check review_run'
  assert_event_contains .sfs-local/events.jsonl '"executor_invoked":false' 'author-check review_run'
)

# Result metadata must expose the prompt byte count and measured elapsed wall time.
assert_contains "${VERDICTS}/.sfs-local/sprints/2026-W37-sprint-1/review.md" '- prompt_bytes: `'
assert_contains "${VERDICTS}/.sfs-local/sprints/2026-W37-sprint-1/review.md" '- wall_time_sec: `'

# A safety timeout is recorded as a single manual retry instruction; it never retries
# the executor automatically.
TIMEOUT_FIXTURE="${contract_fixture}/timeout"
init_review_fixture "${TIMEOUT_FIXTURE}" 'exercise timeout manual retry'
cat > "${TIMEOUT_FIXTURE}/tools/timeout-executor.sh" <<'EOF_TIMEOUT'
#!/usr/bin/env bash
set -euo pipefail
cat >/dev/null
sleep 5
EOF_TIMEOUT
chmod +x "${TIMEOUT_FIXTURE}/tools/timeout-executor.sh"
(
  cd "${TIMEOUT_FIXTURE}"
  set +e
  timeout_out="$(SFS_REVIEW_EXECUTOR_TIMEOUT_SEC=1 run_sfs review --gate 3 --stage artifact --allow-empty --executor ./tools/timeout-executor.sh 2>&1)"
  timeout_rc=$?
  set -e
  [[ "${timeout_rc}" -ne 0 ]] || fail "timed-out executor must fail the review invocation"
  assert_contains .sfs-local/sprints/2026-W37-sprint-1/review.md '- next: timeout: 번들 축소 후 1회 재시도'
  assert_contains .sfs-local/sprints/2026-W37-sprint-1/review.md '- retry_policy: `manual only; no automatic retry`'
)

echo "test-review-verdict-contract: contract_text and runtime verdict contract OK"
