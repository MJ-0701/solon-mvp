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
done

# 2) Headline assertion: the handoff template carries the standard
#    copy-as-prompt export. ASCII markers only (no multibyte-locale grep trap).
HANDOFF_TPL="${SKILLS_DIR}/solon-doc-handoff/template.html"
assert_contains "${HANDOFF_TPL}" "data-copy-as-prompt" "handoff copy-as-prompt marker"
assert_contains "${HANDOFF_TPL}" "function copyAsPrompt" "handoff copy-as-prompt handler"
assert_contains "${HANDOFF_TPL}" "id=\"next-session-prompt\"" "handoff next-session-prompt block"

# 3) install.sh wires all three skills onto both Claude Code and Codex surfaces.
INSTALL="${DIST_DIR}/install.sh"
for skill in solon-doc-spec solon-doc-review solon-doc-handoff; do
  assert_contains "${INSTALL}" "${skill}" "install.sh wiring (${skill})"
done
assert_contains "${INSTALL}" ".claude/skills/\$_doc_skill/SKILL.md" "install.sh Claude surface"
assert_contains "${INSTALL}" ".agents/skills/\$_doc_skill/SKILL.md" "install.sh Codex surface"

echo "test-html-artifact-skills: OK"
