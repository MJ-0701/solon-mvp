#!/usr/bin/env bash
# 5개 organization division + cross-cutting taxonomy role ledger의
# Tier-B advisory와 legacy consumer 호환성을 검증하는 회귀 테스트다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
HC="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-healthcheck.sh"
POLICY="${DIST_DIR}/docs/maintenance/policies/six-division-council.md"
ROUTED_POLICY="${DIST_DIR}/templates/.sfs-local-template/context/policies/division-subagent-council.md"
PLAN_TEMPLATE="${DIST_DIR}/templates/.sfs-local-template/sprint-templates/plan.md"
REVIEW_TEMPLATE="${DIST_DIR}/templates/.sfs-local-template/sprint-templates/review.md"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-division-ledger.XXXXXX")"
trap 'rm -rf "${TMP_DIR}"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }

create_project() {
  local project="$1"
  mkdir -p "${project}"
  (
    cd "${project}"
    git init -q
    git config user.email "division-ledger@solon.invalid"
    git config user.name "Solon Division Ledger Test"
    printf '# fixture\n' > README.md
    git add README.md && git commit -qm init
    SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" \
      bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1
  ) || fail "fixture init failed"
}

set_council_role_rows() {
  local file="$1" heading="$2" kind="$3" tmp
  tmp="${file}.tmp"
  awk -v heading="${heading}" -v kind="${kind}" '
    $0 == heading { in_section=1; print; next }
    in_section && /^## / { in_section=0 }
    in_section && /^\| (strategy-pm|dev|QA|design|infra|taxonomy) \|/ {
      split($0, cells, "|")
      role=cells[2]
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", role)
      if (kind == "filled") {
        if (heading ~ /^## 7\./) {
          print "| " role " | AC/evidence mapping | asset candidate | involved |"
        } else {
          print "| " role " | involved | finding/evidence | asset candidate | pass |"
        }
      } else if (role == "strategy-pm" || role == "QA" || role == "infra") {
        if (heading ~ /^## 7\./) {
          print "| " role " | N/A: no product decision in this lint slice |  | not-applicable |"
        } else {
          print "| " role " | not-applicable | N/A: no review finding in this lint slice |  | pass |"
        }
      } else if (heading ~ /^## 7\./) {
        print "| " role " | waiver: lint-only slice |  | waived |"
      } else {
        print "| " role " | waived | waiver: lint-only slice |  | pass |"
      }
      next
    }
    { print }
  ' "${file}" > "${tmp}" && mv "${tmp}" "${file}"
}

write_variant_ledgers() {
  local plan="$1" review="$2"
  printf '%s\r\n' \
    '### §7 - Division Sub-Agent Ledger ###   ' \
    '| division | AC/files/evidence mapping | asset_candidate | status/finding/waiver |' \
    '|---|---|---|---|' \
    '| **STRATEGY-PM** |  |  |  |' \
    '| `DEV` |  |  |  |' \
    '| _qa_ |  |  |  |' \
    '| **Design** |  |  |  |' \
    '| INFRA |  |  |  |' \
    '| `taxonomy` |  |  |  |' \
    '| developer |  |  |  |' \
    '| QA lead |  |  |  |' \
    '### 7.1 Domain Asset Promotion Ledger' \
    '| strategy-pm |  |  |  |' > "${plan}"
  printf '%s\r\n' \
    '#### 5) Division sub agent ledger ###   ' \
    '| division | status | finding/evidence/waiver | asset_candidate | reviewer verdict |' \
    '|---|---|---|---|---|' \
    '| **STRATEGY-PM** |  |  |  |  |' \
    '| `DEV` |  |  |  |  |' \
    '| _qa_ |  |  |  |  |' \
    '| **Design** |  |  |  |  |' \
    '| INFRA |  |  |  |  |' \
    '| `taxonomy` |  |  |  |  |' \
    '| developer |  |  |  |  |' \
    '| QA lead |  |  |  |  |' \
    '#### 5.1 Domain Asset Review Ledger' \
    '| strategy-pm |  |  |  |  |' \
    '- result_verdict: `partial`' > "${review}"
}

run_hc() {
  SFS_HEALTHCHECK_SKIP_RUNTIME_TESTS=1 SFS_DIST_DIR="${DIST_DIR}" \
    bash "${SFS_BIN}" healthcheck --project "${PROJECT}" 2>&1
}

run_hc_byte_oriented() {
  LC_ALL=C SFS_HEALTHCHECK_SKIP_RUNTIME_TESTS=1 SFS_DIST_DIR="${DIST_DIR}" \
    bash "${SFS_BIN}" healthcheck --project "${PROJECT}" 2>&1
}

for template in "${PLAN_TEMPLATE}" "${REVIEW_TEMPLATE}"; do
  grep -Fq "Council Participation Ledger" "${template}" \
    || fail "council participation heading missing from ${template}"
  grep -Fq '`taxonomy`는 조직 division이 아니라 필수 cross-cutting product function/lens' "${template}" \
    || fail "taxonomy cross-cutting role boundary missing from ${template}"
  grep -Fq "| council role |" "${template}" \
    || fail "ledger must name rows as council roles in ${template}"
  grep -Fq "| taxonomy |" "${template}" \
    || fail "taxonomy must remain a required council role in ${template}"
  grep -Fq "Division Sub-agent Ledger" "${template}" \
    && fail "new templates must not classify taxonomy under a division ledger"
done
grep -Fiq "five organization divisions" "${ROUTED_POLICY}" \
  || fail "routed policy must identify exactly five organization divisions"
grep -Fq "Taxonomy is not an organization division" "${ROUTED_POLICY}" \
  || fail "routed policy must classify taxonomy as cross-cutting"
grep -Fq "six required council participation roles" "${ROUTED_POLICY}" \
  || fail "routed policy must preserve all six required council roles"

grep -Fq "Tier-B healthcheck lint" "${POLICY}" \
  || fail "council policy must document the Tier-B healthcheck lint"
grep -Fq "issue count/exit code" "${POLICY}" \
  || fail "council policy must document advisory-only severity"
grep -Fq "result_verdict" "${POLICY}" \
  || fail "council policy must document review verdict eligibility"
grep -Fq "check_council_role_ledger_completeness" "${HC}" \
  || fail "healthcheck completeness function missing"
if awk '/^check_council_role_ledger_completeness\(\)/,/^}/' "${HC}" | grep -q "add_issue"; then
  fail "council role ledger check must be advisory-only"
fi

PROJECT="${TMP_DIR}/project"
create_project "${PROJECT}"
SPRINT="${PROJECT}/.sfs-local/sprints/s-division-ledger"
mkdir -p "${SPRINT}"
printf 's-division-ledger\n' > "${PROJECT}/.sfs-local/current-sprint"
cp "${PLAN_TEMPLATE}" "${SPRINT}/plan.md"
cp "${REVIEW_TEMPLATE}" "${SPRINT}/review.md"

# Freshly-created plan/review templates are scaffolds, not evidence that either
# lifecycle stage has occurred.
out="$(run_hc)"
grep -Fq "[division-ledger]" <<<"${out}" && fail "pristine templates must not warn division-ledger"

# plan §7 becomes eligible once implementation has started; an unreviewed
# review.md remains ineligible.
cp "${DIST_DIR}/templates/.sfs-local-template/sprint-templates/implement.md" "${SPRINT}/implement.md"
out="$(run_hc)"
grep -Fq "WARN [division-ledger]" <<<"${out}" || { printf '%s\n' "${out}" >&2; fail "eligible blank plan ledger must warn"; }
grep -Fq "plan.md §7 has blank required council role row(s): strategy-pm, dev, QA, design, infra, taxonomy" <<<"${out}" \
  || fail "plan §7 blank rows must be named"
grep -Fq "review.md §5 has blank required council role row(s)" <<<"${out}" \
  && fail "review ledger must not warn before an actual verdict is recorded"

# review §5 becomes eligible only when the standard durable result verdict is
# present; this is a real verdict shape, not the template's pass/partial/fail
# guidance line.
printf '\n- result_verdict: `partial`\n' >> "${SPRINT}/review.md"
out="$(run_hc)"
grep -Fq "review.md §5 has blank required council role row(s): strategy-pm, dev, QA, design, infra, taxonomy" <<<"${out}" \
  || fail "review §5 blank rows must be named"
grep -Fq "FAIL [division-ledger]" <<<"${out}" && fail "division ledger check must never be a FAIL issue"

# Filled rows suppress both advisories.
set_council_role_rows "${SPRINT}/plan.md" "## 7. Council Participation Ledger" filled
set_council_role_rows "${SPRINT}/review.md" "## 5. Council Participation Ledger" filled
out="$(run_hc)"
grep -Fq "[division-ledger]" <<<"${out}" && fail "filled rows must suppress division-ledger warnings"

# Explicit N/A and waiver rows are valid substantive entries.
cp "${PLAN_TEMPLATE}" "${SPRINT}/plan.md"
cp "${REVIEW_TEMPLATE}" "${SPRINT}/review.md"
printf '\n- result_verdict: `pass`\n' >> "${SPRINT}/review.md"
set_council_role_rows "${SPRINT}/plan.md" "## 7. Council Participation Ledger" exception
set_council_role_rows "${SPRINT}/review.md" "## 5. Council Participation Ledger" exception
out="$(run_hc)"
grep -Fq "[division-ledger]" <<<"${out}" && fail "explicit N/A and waiver rows must suppress division-ledger warnings"

# Legacy Division Sub-agent Ledger headings, Markdown heading
# levels/punctuation, trailing whitespace, CRLF, and safe inline
# formatting/case changes all retain the six canonical council roles,
# including taxonomy. The following 7.1/5.1 tables and non-canonical rows must
# stay out of scope.
write_variant_ledgers "${SPRINT}/plan.md" "${SPRINT}/review.md"
out="$(run_hc)"
grep -Fq "plan.md §7 has blank required council role row(s): strategy-pm, dev, QA, design, infra, taxonomy" <<<"${out}" \
  || fail "CRLF/variant plan heading and labels must be recognized"
grep -Fq "review.md §5 has blank required council role row(s): strategy-pm, dev, QA, design, infra, taxonomy" <<<"${out}" \
  || fail "CRLF/variant review heading and labels must be recognized"
grep -Fq "developer" <<<"${out}" && fail "unrelated developer row must not be matched"
grep -Fq "QA lead" <<<"${out}" && fail "unrelated QA lead row must not be matched"
grep -Fq "taxonomy, strategy-pm" <<<"${out}" && fail "following 7.1/5.1 sections must not extend ledger boundaries"

# Under a byte-oriented awk locale, a UTF-8 section sign cannot be quantified
# as one regex character. Keep both the §-prefixed plan heading and the plain
# numbered review heading detectable.
out="$(run_hc_byte_oriented)"
grep -Fq "plan.md §7 has blank required council role row(s): strategy-pm, dev, QA, design, infra, taxonomy" <<<"${out}" \
  || fail "byte-oriented awk must recognize §-prefixed plan headings"
grep -Fq "review.md §5 has blank required council role row(s): strategy-pm, dev, QA, design, infra, taxonomy" <<<"${out}" \
  || fail "byte-oriented awk must recognize plain numbered review headings"

echo "test-sfs-healthcheck-division-ledger-advisory: OK"
