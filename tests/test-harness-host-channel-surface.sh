#!/usr/bin/env bash
# sfs harness doctor / map 의 0.7.0 host-channel surface 검사 (0.7.6).
#
# 0.7.0~0.7.5 가 MCP server / permission preset / Agent SDK scaffold 를
# 추가했지만 sfs harness doctor / map 은 그것들을 모르고 있었다. 0.7.6 은
# doctor 에 "Host Channels And 0.7.0 Surface" 절을, map 에 동일 정보의
# 행을 추가했다. 본 테스트는 그 추가가 한 번 들어간 뒤 다시 빠지지
# 않도록 잠근다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"

fail() { echo "FAIL: $*" >&2; exit 1; }

# 임시 프로젝트 초기화 — doctor / map 둘 다 initialized SFS project 가
# 있어야 의미 있는 결과를 낸다.
tmp="$(mktemp -d "${TMPDIR:-/tmp}/sfs-harness-host-channel.XXXXXX")"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT

cd "${tmp}"
git init -q
git config user.email "harness-host@solon.invalid"
git config user.name "Solon Harness Host Test"
printf '# t\n' > README.md
git add . && git commit -qm "init"
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1

# ── 1) harness doctor 의 새 섹션 + 4-line 정상 case ───────────────
doctor_out="$(SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" harness doctor 2>&1 || true)"

grep -qF 'Host Channels And 0.7.0 Surface' <<<"${doctor_out}" \
  || fail "doctor must add a 'Host Channels And 0.7.0 Surface' section"
grep -qF 'CLI channel: sfs <cmd>' <<<"${doctor_out}" \
  || fail "doctor must name the CLI channel"
grep -qF 'MCP channel available' <<<"${doctor_out}" \
  || fail "doctor must check the MCP channel availability"
grep -qF 'Solon-safe permission preset available' <<<"${doctor_out}" \
  || fail "doctor must check the solon-safe permission preset"
grep -qF 'Claude Agent SDK scaffold available' <<<"${doctor_out}" \
  || fail "doctor must check the claude-agent-sdk-zero scaffold"
grep -qF 'agent-build track' <<<"${doctor_out}" \
  || fail "doctor must report the agent-build track signal (present or absent)"

# ── 2) harness map 에 Host channels 행이 들어 있어야 한다. ────────
map_out="$(SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" harness map 2>&1 || true)"

grep -qF '| Host channels (0.7.0+) |' <<<"${map_out}" \
  || fail "map must add a 'Host channels (0.7.0+)' row"
for word in 'CLI' 'MCP' 'solon-safe-permissions.yaml' 'claude-agent-sdk-zero' 'agent-build track'; do
  grep -qF -- "${word}" <<<"${map_out}" \
    || fail "map row must mention: ${word}"
done

# ── 3) detect_* helper 들의 정적 존재 확인 — 미래 리팩토링이 함수
#       이름을 바꾸면 즉시 알린다. ─────────────────────────────────
hsh="${DIST_DIR}/scripts/sfs-harness.sh"
for fn in detect_mcp_server_artifact detect_solon_safe_preset detect_agent_sdk_template detect_agent_build_track; do
  grep -qE "^${fn}\(\)" "${hsh}" \
    || fail "${hsh} missing detector function: ${fn}"
done

# ── 4) Agent-build track 검출이 양성 case 에서 작동하는지 확인. ──
#       임시로 agent.py 를 만든 두 번째 프로젝트에서 doctor 호출. ───
tmp2="$(mktemp -d "${TMPDIR:-/tmp}/sfs-harness-agentbuild.XXXXXX")"
cleanup2() { cleanup; rm -rf "${tmp2}"; }
trap cleanup2 EXIT

cd "${tmp2}"
git init -q
git config user.email "agent-build@solon.invalid"
git config user.name "Solon Agent-Build Test"
printf '# t\n' > README.md
printf '#!/usr/bin/env python3\nprint("hi")\n' > agent.py
git add . && git commit -qm "init"
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1
agent_doctor_out="$(SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" harness doctor 2>&1 || true)"
grep -qF 'agent-build track detected' <<<"${agent_doctor_out}" \
  || fail "doctor must detect the agent-build track when agent.py is present"

echo "test-harness-host-channel-surface: OK"
