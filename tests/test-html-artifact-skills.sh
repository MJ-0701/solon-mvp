#!/usr/bin/env bash
# BWU-1: Solon HTML output-artifact skills (spec/review/handoff) ship with the
# copy-as-prompt handoff export and are wired into install.sh on both surfaces.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILLS_DIR="${DIST_DIR}/templates/.agents/skills"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

assert_not_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  if grep -Fq -- "${needle}" "${file}"; then
    fail "${label}: unexpected '${needle}'"
  fi
}

# 1) All three skills exist with SKILL.md (frontmatter) + template.html asset.
for skill in solon-doc-spec solon-doc-review solon-doc-handoff; do
  skill_md="${SKILLS_DIR}/${skill}/SKILL.md"
  tpl="${SKILLS_DIR}/${skill}/template.html"
  [[ -f "${skill_md}" ]] || fail "${skill}: missing SKILL.md"
  [[ -f "${tpl}" ]] || fail "${skill}: missing template.html"
  [[ "$(sed -n '1p' "${skill_md}")" == "---" ]] || fail "${skill}: SKILL.md missing opening frontmatter"
  sed -n "2,40p" "${skill_md}" | grep -Fxq -- "---" || fail "${skill}: SKILL.md missing closing frontmatter"
  assert_contains "${skill_md}" "name: ${skill}" "${skill} name"
  # Templates must stay placeholder-driven, not project-specific fixed values.
  assert_contains "${tpl}" "<PROJECT-NAME>" "${skill} placeholder"
  assert_contains "${tpl}" "{{ARTIFACT_KIND}}" "${skill} artifact kind metadata"
  assert_contains "${tpl}" "{{ARTIFACT_STATUS}}" "${skill} artifact status metadata"
  assert_contains "${tpl}" "{{ARTIFACT_OWNER}}" "${skill} artifact owner metadata"
  assert_contains "${tpl}" "{{SOURCE_REF}}" "${skill} source ref metadata"
  assert_contains "${tpl}" "{{EVIDENCE_ITEM}}" "${skill} evidence item placeholder"
  assert_contains "${skill_md}" "{{ARTIFACT_KIND}}" "${skill} skill doc metadata placeholder"
  assert_contains "${skill_md}" "{{EVIDENCE_ITEM}}" "${skill} skill doc evidence placeholder"
  assert_contains "${skill_md}" "Self-contained HTML" "${skill} static contract"
  assert_not_contains "${tpl}" "https://" "${skill} no external https asset"
  assert_not_contains "${tpl}" "http://" "${skill} no external http asset"
  assert_not_contains "${tpl}" "/Users/" "${skill} no private user path"
  assert_not_contains "${tpl}" "/private/" "${skill} no private tmp path"
done

# 2) The richer artifact rails are present on each template.
SPEC_TPL="${SKILLS_DIR}/solon-doc-spec/template.html"
SPEC_MD="${SKILLS_DIR}/solon-doc-spec/SKILL.md"
assert_contains "${SPEC_TPL}" "Verification plan" "spec verification plan"
assert_contains "${SPEC_TPL}" "{{VERIFY_SIGNAL}}" "spec verify signal"
assert_contains "${SPEC_TPL}" "Decision and action log" "spec decision action log"
assert_contains "${SPEC_TPL}" "{{ACTION_ITEM}}" "spec action item"
assert_contains "${SPEC_MD}" "{{VERIFY_SIGNAL}}" "spec skill doc verify placeholder"
assert_contains "${SPEC_MD}" "{{ACTION_ITEM}}" "spec skill doc action placeholder"

REVIEW_TPL="${SKILLS_DIR}/solon-doc-review/template.html"
REVIEW_MD="${SKILLS_DIR}/solon-doc-review/SKILL.md"
assert_contains "${REVIEW_TPL}" "Review verdict" "review verdict section"
assert_contains "${REVIEW_TPL}" "{{REVIEW_VERDICT}}" "review verdict placeholder"
assert_contains "${REVIEW_TPL}" "{{REVIEWER}}" "reviewer placeholder"
assert_contains "${REVIEW_TPL}" "Required actions" "review required actions"
assert_contains "${REVIEW_TPL}" "{{ACTION_STATUS}}" "review action status"
assert_contains "${REVIEW_MD}" "{{REVIEW_VERDICT}}" "review skill doc verdict placeholder"
assert_contains "${REVIEW_MD}" "{{ACTION_STATUS}}" "review skill doc action placeholder"
assert_contains "${REVIEW_TPL}" "{{DIFF_BODY}}" "review diff placeholder preserved"
assert_contains "${REVIEW_TPL}" "{{ANNOTATION_ITEM}}" "review annotation placeholder preserved"

# 3) Headline assertion: the handoff template carries the standard
#    copy-as-prompt export. ASCII markers only (no multibyte-locale grep trap).
HANDOFF_TPL="${SKILLS_DIR}/solon-doc-handoff/template.html"
HANDOFF_MD="${SKILLS_DIR}/solon-doc-handoff/SKILL.md"
assert_contains "${HANDOFF_TPL}" "data-copy-as-prompt" "handoff copy-as-prompt marker"
assert_contains "${HANDOFF_TPL}" "function copyAsPrompt" "handoff copy-as-prompt handler"
assert_contains "${HANDOFF_TPL}" "id=\"next-session-prompt\"" "handoff next-session-prompt block"
assert_contains "${HANDOFF_TPL}" "{{PARKED_AT}}" "handoff parked placeholder"
assert_contains "${HANDOFF_TPL}" "{{HARD_STOP}}" "handoff hard stop placeholder"
assert_contains "${HANDOFF_TPL}" "{{BLOCKER_ITEM}}" "handoff blocker placeholder"
assert_contains "${HANDOFF_TPL}" "{{REQUIRED_OWNER_ACTION}}" "handoff owner action placeholder"
assert_contains "${HANDOFF_TPL}" "copyAsJson" "handoff json export preserved"
assert_contains "${HANDOFF_MD}" "{{PARKED_AT}}" "handoff skill doc parked placeholder"
assert_contains "${HANDOFF_MD}" "{{REQUIRED_OWNER_ACTION}}" "handoff skill doc owner action placeholder"

# 4) install.sh wires all three skills onto both Claude Code and Codex surfaces.
INSTALL="${DIST_DIR}/install.sh"
for skill in solon-doc-spec solon-doc-review solon-doc-handoff; do
  assert_contains "${INSTALL}" "${skill}" "install.sh wiring (${skill})"
done
assert_contains "${INSTALL}" ".claude/skills/\$_doc_skill/SKILL.md" "install.sh Claude surface"
assert_contains "${INSTALL}" ".agents/skills/\$_doc_skill/SKILL.md" "install.sh Codex surface"

echo "test-html-artifact-skills: OK"
