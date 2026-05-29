#!/usr/bin/env bash
# install.sh 완료 메시지가 0.7.0+ host-agnostic surface 를 언급한다 (0.7.5).
#
# 0.7.0 이 MCP server + permission preset + agent-build lens + Agent SDK
# scaffold 4개 surface 를 추가했지만 install.sh 의 "다음 단계" 안내는
# 그것들을 모르고 있었다. 0.7.5 는 안내문에 §8 항목을 추가해 신규 사용자
# 가 설치 직후 4개 surface 의 진입점을 한 페이지에서 보게 한다.
#
# 본 테스트는 정적으로 install.sh 안에 4개 surface 의 키워드가 모두
# 등장하는지 확인한다. 메시지 한 줄을 빠뜨려도 즉시 실패.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
INSTALL_SH="${DIST_DIR}/install.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f "${INSTALL_SH}" ]] || fail "missing install.sh"

# ── 1) 0.7.0+ host-agnostic 안내 §8 절이 존재해야 한다. ─────────────
grep -qE '0\.7\.0\+ host-agnostic 진입' "${INSTALL_SH}" \
  || fail "install.sh completion message must add a 0.7.0+ host-agnostic step"

# ── 2) 4개 surface 의 핵심 키워드가 모두 등장해야 한다. ────────────
declare -a phrases=(
  'solon-mcp'
  'mcp-server/README.md'
  'solon-safe-permissions.yaml'
  'claude-agent-sdk-zero'
  'agent-build'
)
for phrase in "${phrases[@]}"; do
  grep -qF -- "${phrase}" "${INSTALL_SH}" \
    || fail "install.sh completion message missing 0.7.0 surface keyword: ${phrase}"
done

# ── 3) 안내문이 PyPI publish 전 상태를 정직하게 명시해야 한다. ──────
grep -qF 'source clone 만 지원' "${INSTALL_SH}" \
  || fail "install.sh must surface the 'source clone only' caveat for solon-mcp"

# ── 4) Agent SDK template 호출 한 줄이 진짜 실행 가능한 명령이어야 한다.
#       (bootstrap 스크립트의 신규 --template 플래그를 사용한다.) ─────
grep -qF 'sfs bootstrap --experimental --template claude-agent-sdk-zero' "${INSTALL_SH}" \
  || fail "install.sh must show the actual scaffold command for claude-agent-sdk-zero"

echo "test-install-completion-hints: OK"
