#!/usr/bin/env bash
# Root agent adapter docs must stay thin and route SFS policy to SFS.md/context.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

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

assert_frontmatter_only() {
  local file="$1" label="$2"
  [[ "$(sed -n '1p' "${file}")" == "---" ]] || fail "${label}: missing opening frontmatter"
  sed -n '2,120p' "${file}" | grep -Fxq -- "---" || fail "${label}: missing closing frontmatter"
  if awk '
    NR == 1 && $0 == "---" { in_fm = 1; next }
    in_fm && $0 == "---" { in_fm = 0; seen_close = 1; next }
    seen_close && $0 ~ /[^[:space:]]/ { found = 1 }
    END { exit found ? 0 : 1 }
  ' "${file}"; then
    fail "${label}: root adapter must not contain body text"
  fi
}

root_adapters=(
  "${DIST_DIR}/templates/CLAUDE.md.template"
  "${DIST_DIR}/templates/AGENTS.md.template"
  "${DIST_DIR}/templates/GEMINI.md.template"
)

for file in "${root_adapters[@]}"; do
  assert_frontmatter_only "${file}" "adapter frontmatter-only ${file}"
  assert_contains "${file}" "doc_type: agent-adapter-bootstrap" "adapter frontmatter ${file}"
  assert_contains "${file}" "frontmatter_only: true" "adapter frontmatter-only marker ${file}"
  assert_contains "${file}" "SFS.md" "adapter routes to SFS.md ${file}"
  assert_contains "${file}" ".sfs-local/context/" "adapter routes to project-local context ${file}"
  assert_contains "${file}" "sfs context cat kernel" "adapter routes kernel ${file}"
  assert_contains "${file}" "sfs context cat index" "adapter routes index ${file}"
  assert_contains "${file}" "SFS command tables" "adapter no policy duplication ${file}"
  assert_contains "${file}" "bkit-style Feature Usage footers" "adapter no bkit footer ${file}"
  assert_contains "${file}" "sfs agent doctor --fix" "adapter refactor command ${file}"

  lines="$(wc -l <"${file}" | tr -d '[:space:]')"
  [[ "${lines}" -le 45 ]] || fail "${file}: root adapter too long (${lines} lines)"

  assert_not_contains "${file}" "Session Continuation Guard" "adapter no session policy body ${file}"
  assert_not_contains "${file}" "Domain knowledge assets are first-class" "adapter no domain policy body ${file}"
  assert_not_contains "${file}" "Division sub-agent council is always-on" "adapter no division policy body ${file}"
  assert_not_contains "${file}" "Model routing applies by default" "adapter no model policy body ${file}"
  assert_not_contains "${file}" "SFS commands —" "adapter no full command table ${file}"
  assert_not_contains "${file}" "gemini-3.1-pro-preview" "adapter no model table ${file}"
done

sfs_template="${DIST_DIR}/templates/SFS.md.template"
[[ "$(sed -n '1p' "${sfs_template}")" == "---" ]] || fail "SFS.md.template missing opening frontmatter"
assert_contains "${sfs_template}" "doc_type: solon-router" "SFS template frontmatter"
assert_contains "${sfs_template}" "sfs context cat kernel" "SFS template routes kernel"
assert_contains "${sfs_template}" "sfs doctor --fix" "SFS template maintenance command"
assert_not_contains "${sfs_template}" "Domain knowledge assets are first-class" "SFS template no domain policy body"
assert_not_contains "${sfs_template}" "Session Continuation Guard" "SFS template no session policy body"
assert_not_contains "${sfs_template}" "Division sub-agent council is always-on" "SFS template no division policy body"

policy="${DIST_DIR}/templates/.sfs-local-template/context/policies/agent-adapter-doc-refactor.md"
router_policy="${DIST_DIR}/templates/.sfs-local-template/context/policies/sfs-router-doc-refactor.md"
index="${DIST_DIR}/templates/.sfs-local-template/context/_INDEX.md"
assert_contains "${index}" "agent-adapter-doc-refactor.md" "context index routes agent doc refactor policy"
assert_contains "${index}" "sfs-router-doc-refactor.md" "context index routes SFS doc refactor policy"
assert_contains "${policy}" "frontmatter-only SFS pointers" "agent doc refactor policy contract"
assert_contains "${policy}" "sfs agent doctor --fix" "agent doc refactor policy command"
assert_contains "${router_policy}" '`SFS.md` is the project entry router' "SFS doc refactor policy contract"
assert_contains "${router_policy}" "sfs doctor --fix" "SFS doc refactor policy command"
assert_contains "${DIST_DIR}/bin/sfs" "sfs agent doctor [--fix]" "CLI usage exposes agent doctor"
assert_contains "${DIST_DIR}/bin/sfs" "sfs doctor [--fix]" "CLI usage exposes top-level doctor"

echo "test-thin-agent-adapter-docs: OK"
