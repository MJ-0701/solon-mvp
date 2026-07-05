#!/usr/bin/env bash
# DESIGN-2026-07-03 §1.5 (idea_wiki:L087-I5) — headline.
#
# Locks the AI-friendly surface axis group in doctor's AI Readiness section:
# the repo-standard four elements (repo guide MD / rules-guardrails /
# repeated-work commands-skills / AI reviewer) map 1:1 onto solon-installed
# surfaces and score 0-2 each, as a SECOND group next to the Sanity four —
# additive: the Sanity axes and their total line are untouched. Signal-only
# (ALT-INV-3): ai-surface lines are info/ok only, rc-equality locked. The
# mapping table (repo-standard element <-> solon surface) is required in the
# rubric policy.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
POLICY="${DIST_DIR}/templates/.sfs-local-template/context/policies/harness-readiness.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
has() { grep -Fq -- "$2" <<<"$1" || fail "$3: missing '$2'"; }

AXES="repo-guide guardrails command-skill ai-reviewer"

# ── Rubric policy: new section, mapping table, additive anchors ─────
[[ -f "${POLICY}" ]] || fail "missing policies/harness-readiness.md"
fhas "${POLICY}" "AI_FRIENDLY_SURFACE" "surface section anchor"
fhas "${POLICY}" "idea_wiki:L087-I5" "source pointer citation (by-reference)"
for axis in ${AXES}; do
  fhas "${POLICY}" "${axis}" "rubric axis '${axis}'"
done
# mapping table rows: repo-standard element <-> solon surface.
fhas "${POLICY}" "repository guide (MD)" "mapping row: repo guide"
fhas "${POLICY}" "rules / guardrails file" "mapping row: guardrails"
fhas "${POLICY}" "repeated work as slash commands / skills" "mapping row: commands/skills"
fhas "${POLICY}" "AI code reviewer active" "mapping row: AI reviewer"
# additive guarantee: the 0.8.61 Sanity anchors survive.
for anchor in RUBRIC ORDER_DISCIPLINE WAIVER KNOWLEDGE_GRAPH_POINTER \
              self-verification dead-code convention-consistency entry-doc-freshness; do
  fhas "${POLICY}" "${anchor}" "pre-existing anchor '${anchor}' preserved"
done
lines="$(wc -l < "${POLICY}")"
[[ "${lines}" -lt 200 ]] || fail "policy exceeds 200-line budget (${lines})"

# doc colocation: product-shape wiki names the surface axes, both languages.
fhas "${DIST_DIR}/docs/en/current-product-shape/17-token-harness-hygiene.md" \
  "AI-friendly surface" "wiki surface bullet (en)"
fhas "${DIST_DIR}/docs/ko/current-product-shape/17-token-harness-hygiene.md" \
  "AI-friendly 표면" "wiki surface bullet (ko)"

# ── Fixtures through the real doctor ────────────────────────────────
tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/sfs-aisurface.XXXXXX")"
trap 'rm -rf "${tmp_root}"' EXIT
export SFS_COST_FORCE_PARSER=none

run_doctor() {
  local rc=0 out
  out="$(SFS_DIST_DIR="${DIST_DIR}" bash "${DIST_DIR}/scripts/sfs-harness.sh" doctor 2>&1)" || rc=$?
  printf '%s\nrc=%d\n' "${out}" "${rc}"
}

proj="${tmp_root}/proj"
mkdir -p "${proj}"
cd "${proj}"
git init -q && git config user.email "s@solon.invalid" && git config user.name "S"
mkdir -p tests
printf '#!/usr/bin/env bash\necho ok\n' > tests/run-all.sh
printf '# proj\n' > README.md
git add -A && git commit -qm "init"
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1
printf '# proj router\nSee [README](README.md).\n' > SFS.md
git add -A && git commit -qm "sfs"

# 1) bare install: guide+guardrails present, nothing compiled, reviewer unused.
out_bare="$(run_doctor)"
has "${out_bare}" "readiness: ai-surface guardrails 2/2" "bare guardrails 2/2 (packaged context)"
has "${out_bare}" "readiness: ai-surface command-skill 0/2" "bare command-skill 0/2"
has "${out_bare}" "readiness: ai-surface ai-reviewer 1/2" "bare ai-reviewer 1/2 (rail unused)"
has "${out_bare}" "readiness: ai-surface total " "surface total line"
# additive: the Sanity total line is untouched by the new group.
has "${out_bare}" "readiness: total " "Sanity total line preserved"
rc_bare="$(sed -n 's/^rc=//p' <<<"${out_bare}")"

# rubric <-> output lock: every policy axis token appears in doctor output.
for axis in ${AXES}; do
  has "${out_bare}" "readiness: ai-surface ${axis} " "doctor output axis token '${axis}'"
done

# 2) full surface: compiled skill + sprint review evidence -> 8/8.
mkdir -p .claude/commands
printf '# /demo — repeated task\n' > .claude/commands/demo.md
mkdir -p .sfs-local/sprints/2026-07-05-wu-demo
printf '%s\n' '---' 'phase: review' '---' '# review' > .sfs-local/sprints/2026-07-05-wu-demo/review.md
out_full="$(run_doctor)"
has "${out_full}" "readiness: ai-surface repo-guide 2/2" "full repo-guide 2/2"
has "${out_full}" "readiness: ai-surface guardrails 2/2" "full guardrails 2/2"
has "${out_full}" "readiness: ai-surface command-skill 2/2" "full command-skill 2/2"
has "${out_full}" "readiness: ai-surface ai-reviewer 2/2" "full ai-reviewer 2/2"
has "${out_full}" "readiness: ai-surface total 8/8" "full surface total 8/8"

# 3) promotion-material middle score: logs exist, nothing compiled yet.
rm -rf .claude
printf '%s\n' '- [x] demo task done' > PROGRESS.md
out_mid="$(run_doctor)"
has "${out_mid}" "readiness: ai-surface command-skill 1/2" "command-skill 1/2 on completed-work logs"
has "${out_mid}" "skill-promotion-loop" "middle score routes to the promotion loop"

# ── Signal-only locks ───────────────────────────────────────────────
if grep -E '(⚠️|❌|🟠)' <<<"${out_full}" | grep -q 'ai-surface'; then
  fail "ai-surface lines must be info/ok only"
fi
rc_full="$(sed -n 's/^rc=//p' <<<"${out_full}")"
[[ "${rc_bare}" == "${rc_full}" ]] \
  || fail "signal-only violated: doctor rc changed with surface score (${rc_bare} -> ${rc_full})"

echo "test-harness-ai-surface: OK"
