#!/usr/bin/env bash
# tests/test-sfs-review-commit-aware-evidence.sh — review prompt includes clean committed handoff/ADR evidence.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-review-commit-aware.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains_file() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

cd "${TMP_DIR}"
git init -q
git branch -M main
git config user.email sfs-test@example.invalid
git config user.name "SFS Test"
printf '# Review Commit Evidence Project\n' > README.md
git add README.md
git commit -qm 'initial'

SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null
git add SFS.md CLAUDE.md AGENTS.md GEMINI.md .gitignore
git commit -qm 'install sfs'

SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" start "root module architecture redesign" --workspace root-module-frontend >/dev/null
sprint_id="$(cat .sfs-local/current-sprint)"
date_dir="$(date +%Y%m%d)"
handoff_dir="docs/solon/root-module-frontend/${date_dir}"
adr_path="docs/solon/decisions/0007-module-architecture-redistribution.md"
report_path="${handoff_dir}/report.md"
mkdir -p "$(dirname "${adr_path}")" "${handoff_dir}"

cat > "${adr_path}" <<'EOF_ADR'
# ADR 0007 — Module architecture redistribution

## 1. Context
The root module needs a stable frontend/backend boundary.

## 2. Decision
Keep the boundary explicit and reviewable.

## 3. Requirements
Persist only durable architecture decisions.

## 4. Acceptance Criteria
Gate evidence must include this ADR after commit.

## 5. Slice Mapping
Each slice maps files and artifacts.

## 6. Security
No raw paths or secrets are exposed.

## 7. API
Contracts remain explicit.

## 8. Data
No data-loss path is introduced.

## 9. UX
Existing flows remain compatible.

## 10. Backend
Backend owns persistence.

## 11. Frontend
Frontend owns chat UX.

## 12. Tests
Smoke and negative tests are required.

## 13. Migration
No destructive migration is allowed.

## 14. Rollback
Rollback stays commit-based.

## 15. Open Questions
No product decision is open.

## 16. Review History
Round findings are mapped.

## 17. Handoff
Implementation can consume this ADR.

## 18. Operational assumptions
This section is intentionally near the end so the regression catches prompt caps.

## 19. Appendix
End marker.
EOF_ADR

cat > "${report_path}" <<EOF_REPORT
---
sprint_id: "${sprint_id}"
workspace: "root-module-frontend"
---

# Root Module Frontend Report

Committed handoff report evidence marker: REVIEW_COMMIT_AWARE_REPORT.
EOF_REPORT

git add "${adr_path}" "${report_path}"
git commit -qm 'docs: add architecture ADR and handoff report'

[[ -z "$(git status --porcelain --untracked-files=no)" ]] || fail "tracked working tree should be clean before review"

review_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" review --gate 4 --prompt-only)"
prompt_path="$(printf '%s\n' "${review_out}" | sed -nE 's/.* prompt ([^[:space:]]+)$/\1/p' | tail -n 1)"
[[ -n "${prompt_path}" ]] || fail "could not parse prompt path from review output: ${review_out}"
[[ -f "${prompt_path}" ]] || fail "prompt path missing: ${prompt_path}"

assert_contains_file "${prompt_path}" "latest commit reviewable file manifest" "prompt latest commit manifest"
assert_contains_file "${prompt_path}" "${adr_path}" "prompt ADR path"
assert_contains_file "${prompt_path}" "${report_path}" "prompt handoff report path"
assert_contains_file "${prompt_path}" "current sprint shared handoff evidence manifest" "prompt handoff manifest"
assert_contains_file "${prompt_path}" "## 18. Operational assumptions" "prompt full ADR tail section"
assert_contains_file "${prompt_path}" "REVIEW_COMMIT_AWARE_REPORT" "prompt handoff report body"
assert_contains_file "${prompt_path}" "first-class review target; full file included" "prompt full small-file marker"

review_path=".sfs-local/sprints/${sprint_id}/review.md"
assert_contains_file "${review_path}" 'goal: "root module architecture redesign"' "review goal frontmatter"
assert_contains_file "${review_path}" 'workspace: "root-module-frontend"' "review workspace frontmatter"

echo "test-sfs-review-commit-aware-evidence: OK"
