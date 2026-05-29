#!/usr/bin/env bash
# host-channel docs 의 coverage 잠금 (0.7.4).
#
# 0.7.0 이 MCP server / agent-build lens / permission preset / Agent SDK
# scaffold 4개 host-agnostic surface 를 추가했고, 0.7.4 는 그것을 사용자
# 가 처음 진입하는 문서들에 명시했다. 본 테스트는 그 명시가 한 번 들어간
# 뒤 다시 빠지지 않도록 잠근다 — 새 host 채널 추가 시에는 이 테스트의
# expected_phrases / files 만 확장하면 된다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() { echo "FAIL: $*" >&2; exit 1; }

# ── 1) docs/{en,ko}/current-product-shape 에 23-host-channels 자식이 존재
#       하고 parent index 의 split_children 에 등재되어 있어야 한다. ─────
ko_parent="${DIST_DIR}/docs/ko/current-product-shape.md"
en_parent="${DIST_DIR}/docs/en/current-product-shape.md"
ko_child="${DIST_DIR}/docs/ko/current-product-shape/23-host-channels-and-mcp.md"
en_child="${DIST_DIR}/docs/en/current-product-shape/23-host-channels-and-mcp.md"

for f in "${ko_parent}" "${en_parent}" "${ko_child}" "${en_child}"; do
  [[ -f "${f}" ]] || fail "missing host-channel doc: ${f}"
done

grep -qF 'docs/ko/current-product-shape/23-host-channels-and-mcp.md' "${ko_parent}" \
  || fail "ko parent index does not list the 23-host-channels child"
grep -qF 'docs/en/current-product-shape/23-host-channels-and-mcp.md' "${en_parent}" \
  || fail "en parent index does not list the 23-host-channels child"

# Each child must name all three channels by their canonical label.
for child in "${ko_child}" "${en_child}"; do
  for label in 'CLI' 'MCP' 'Agent SDK'; do
    grep -qF -- "${label}" "${child}" \
      || fail "${child}: must name host channel: ${label}"
  done
  # And must cross-link to the underlying 0.7.0 artifacts so a reader has
  # a single hop to registration snippets and the lens policy.
  grep -qF 'mcp-server/README.md' "${child}" \
    || fail "${child}: must cross-link to mcp-server/README.md"
  grep -qF 'agent-build-review-lens.md' "${child}" \
    || fail "${child}: must cross-link to agent-build-review-lens.md"
  grep -qF 'solon-safe-permissions.yaml' "${child}" \
    || fail "${child}: must cross-link to solon-safe-permissions.yaml"
done

# ── 2) README/04-section (설치) 에 MCP host 채널 절이 있어야 한다. ─────
readme_install="${DIST_DIR}/README/04-section.md"
[[ -f "${readme_install}" ]] || fail "missing README/04-section.md"
grep -qF 'MCP host 채널' "${readme_install}" \
  || fail "${readme_install}: must add an 'MCP host 채널' subsection"
grep -qF 'mcp-server/README.md' "${readme_install}" \
  || fail "${readme_install}: must cross-link to mcp-server/README.md"

# ── 3) docs/maintenance/methodology-7-step.md 에 host-agnostic 진입 절
#       이 있어야 한다 (CLI + MCP + Agent SDK 세 채널 명시). ──────────────
method="${DIST_DIR}/docs/maintenance/methodology-7-step.md"
[[ -f "${method}" ]] || fail "missing ${method}"
grep -qF 'Host-agnostic 진입' "${method}" \
  || fail "${method}: must add a 'Host-agnostic 진입' section"
for label in 'CLI' 'MCP' 'Agent SDK'; do
  grep -qF -- "${label}" "${method}" \
    || fail "${method}: host-agnostic section must name ${label}"
done

# ── 4) adapter doc frontmatter 의 detail_sources 에 mcp-server/README.md
#       와 solon-safe-permissions.yaml 가 모두 들어 있어야 한다. ─────────
adapters=(
  "${DIST_DIR}/templates/SFS.md.template"
  "${DIST_DIR}/templates/CLAUDE.md.template"
  "${DIST_DIR}/templates/AGENTS.md.template"
  "${DIST_DIR}/templates/GEMINI.md.template"
)
for f in "${adapters[@]}"; do
  [[ -f "${f}" ]] || fail "missing adapter template: ${f}"
  grep -qF -- '- mcp-server/README.md' "${f}" \
    || fail "${f}: detail_sources must include mcp-server/README.md"
  grep -qF -- '- .sfs-local/presets/solon-safe-permissions.yaml' "${f}" \
    || fail "${f}: detail_sources must include .sfs-local/presets/solon-safe-permissions.yaml"
done

# ── 5) SFS.md.template 의 frontmatter detail_sources 에 mcp-server/README.md
#       가 들어 있어야 한다. (SFS.md 는 thin router 라 body 에 host-channel
#       절을 추가하지 않는다 — sfs-router-doc-refactor 의 75 라인 룰 보존.)
sfs_tpl="${DIST_DIR}/templates/SFS.md.template"
awk '/^---$/{f++; next} f==1' "${sfs_tpl}" | grep -qF -- '- mcp-server/README.md' \
  || fail "${sfs_tpl}: detail_sources must include mcp-server/README.md (host-channel cross-link)"

echo "test-host-channel-docs-coverage: OK"
