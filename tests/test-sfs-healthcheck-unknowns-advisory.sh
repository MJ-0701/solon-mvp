#!/usr/bin/env bash
# 0.11.1 headline — unknowns-loop runtime signals + evals scaffold.
#
# Locks:
#   (a) healthcheck deviation-ledger advisory: completion claimed (review/report
#       exists) while implement.md's `## Deviations` ledger is missing/unstated
#       → WARN only (advisory, never an issue); `none observed` silences it.
#   (b) healthcheck plan-readiness advisory: implementation started while
#       unknowns-loop readiness items sit unchecked in plan.md → WARN only.
#   (c) evals scaffold: template README + install/upgrade wiring + harness
#       doctor "Held-Out Evals" info section (signal-only).
#   (d) dig→references bridge lines + hygiene (plan template status, gitignore).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
HC="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-healthcheck.sh"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-unknowns-adv.XXXXXX")"
trap 'rm -rf "${TMP_DIR}"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fhas_ko() { LC_ALL=C grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# ── static wiring ────────────────────────────────────────────────────
fhas "${HC}" "check_unknowns_conformance" "healthcheck function"
fhas "${HC}" "deviation-ledger" "healthcheck deviation advisory key"
fhas "${HC}" "plan-readiness" "healthcheck readiness advisory key"
[[ -f "${DIST_DIR}/templates/.sfs-local-template/evals/README.md" ]] || fail "evals README template missing"
fhas_ko "${DIST_DIR}/templates/.sfs-local-template/evals/README.md" "eval-first" "evals README discipline"
fhas "${DIST_DIR}/install.sh" ".sfs-local/evals" "install.sh evals copy"
fhas "${DIST_DIR}/upgrade.sh" ".sfs-local/evals/README.md|templates/.sfs-local-template/evals/README.md" "upgrade.sh evals pair"
fhas "${DIST_DIR}/scripts/sfs-harness.sh" "Held-Out Evals" "doctor evals section"
fhas_ko "${CTX}/commands/dig.md" "REFERENCES_FIELD" "dig.md references bridge"
fhas "${CTX}/commands/plan.md" "ready-made references entries" "plan.md dig bridge"
fhas "${DIST_DIR}/templates/.sfs-local-template/sprint-templates/plan.md" "status: draft" "plan template status frontmatter"
fhas "${DIST_DIR}/.gitignore" ".sfs-local/release-state/" "gitignore release-state"
fhas "${DIST_DIR}/.gitignore" ".fuse_hidden*" "gitignore fuse leftovers"

# advisory-only guarantee: the new checks never call add_issue.
if awk '/^check_unknowns_conformance\(\)/,/^}/' "${HC}" | grep -q "add_issue"; then
  fail "check_unknowns_conformance must be say_warn-only (found add_issue)"
fi

# ── dynamic fixture ──────────────────────────────────────────────────
PROJECT="${TMP_DIR}/proj"
mkdir -p "${PROJECT}"
(
  cd "${PROJECT}"
  git init -q
  git config user.email "t@solon.invalid"
  git config user.name "t"
  printf '# fixture\n' > README.md
  git add README.md && git commit -qm init
  SFS_INSTALL_LLM_WIKI=1 SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" \
    bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1
) || fail "fixture init failed"

run_hc() {
  SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" healthcheck --project "${PROJECT}" 2>&1 || true
}

# green: fresh project → no unknowns advisories
out="$(run_hc)"
grep -q "deviation-ledger" <<<"${out}" && fail "fresh project must not warn deviation-ledger"
grep -q "plan-readiness" <<<"${out}" && fail "fresh project must not warn plan-readiness"

# red: completion claimed + unstated ledger + unchecked readiness items
SPRINT="${PROJECT}/.sfs-local/sprints/s-unknowns"
mkdir -p "${SPRINT}"
printf 's-unknowns\n' > "${PROJECT}/.sfs-local/current-sprint"
cp "${DIST_DIR}/templates/.sfs-local-template/sprint-templates/implement.md" "${SPRINT}/implement.md"
cp "${DIST_DIR}/templates/.sfs-local-template/sprint-templates/plan.md" "${SPRINT}/plan.md"
printf -- '---\nphase: report\n---\n# r\n' > "${SPRINT}/report.md"
out="$(run_hc)"
grep -q "WARN \[deviation-ledger\]" <<<"${out}" || { printf '%s\n' "${out}" >&2; fail "expected deviation-ledger WARN"; }
grep -q "WARN \[plan-readiness\]" <<<"${out}" || fail "expected plan-readiness WARN"

# advisory must not flip exit semantics by itself: WARN lines are not FAIL lines
grep -q "FAIL \[deviation-ledger\]" <<<"${out}" && fail "deviation-ledger must never be a FAIL issue"
grep -q "FAIL \[plan-readiness\]" <<<"${out}" && fail "plan-readiness must never be a FAIL issue"

# silenced: ledger stated + readiness items checked (standalone sentinel line
# inside the ## Deviations section — the template guidance's quoted mention
# must NOT count, which the red phase above already proved)
awk '{print} /^## Deviations/ && !done { print "- none observed"; done=1 }' \
  "${SPRINT}/implement.md" > "${SPRINT}/implement.md.tmp" \
  && mv "${SPRINT}/implement.md.tmp" "${SPRINT}/implement.md"
LC_ALL=C sed -i.bak 's/- \[ \] 인터뷰 열린 질문/- [x] 인터뷰 열린 질문/; s/- \[ \] blind_spots 항목/- [x] blind_spots 항목/; s/- \[ \] references 가 있으면/- [x] references 가 있으면/' "${SPRINT}/plan.md" && rm -f "${SPRINT}/plan.md.bak"
out="$(run_hc)"
grep -q "deviation-ledger" <<<"${out}" && fail "stated ledger must silence deviation-ledger warn"
grep -q "plan-readiness" <<<"${out}" && fail "checked items must silence plan-readiness warn"

# ── doctor evals section (in-fixture) ────────────────────────────────
dout="$( (cd "${PROJECT}" && SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" harness doctor 2>&1) || true)"
grep -q "Held-Out Evals" <<<"${dout}" || fail "doctor must print Held-Out Evals section"
grep -q "evals:" <<<"${dout}" || fail "doctor must print an evals line"
mkdir -p "${PROJECT}/.sfs-local/evals"
printf -- '---\ncase_id: c1\n---\n## Input\nx\n## Must contain (anchors)\n- y\n' > "${PROJECT}/.sfs-local/evals/c1.md"
dout="$( (cd "${PROJECT}" && SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" harness doctor 2>&1) || true)"
grep -q "1 held-out case file(s)" <<<"${dout}" || fail "doctor must count held-out case files"

echo "PASS: unknowns runtime signals + evals scaffold locked"
