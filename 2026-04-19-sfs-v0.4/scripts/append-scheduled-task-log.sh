#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────
# Solon v0.4-r3 · scripts/append-scheduled-task-log.sh  (v0.1)
# 목적: scheduled task (hourly auto-resume) 가 매 시간 깨워질 때
#       PROGRESS.md frontmatter 의 `scheduled_task_log` 섹션에 한 줄
#       entry 를 append 하고 N=20 rolling tail 을 enforce.
#
# 사용자 지시 (2026-04-25, 17번째 세션 admiring-fervent-dijkstra):
#   "이전세션 이어서 작업하고, 매 시 마다 스케줄 도니까 인수인계가
#    확실하게 자동화 될 수 있도록"
#   → 직접 PROGRESS.md 편집 시 race + N rolling 누락 위험 → helper 신설.
#
# 신설: 17번째 세션 (admiring-fervent-dijkstra, 2026-04-25T09:10+09:00)
# 변경 이력:
#   v0.1 (17번째)  — 초안. Python YAML 파서 사용 안 함 (의존성 회피).
#                    awk + sed 로 frontmatter 섹션 안의 scheduled_task_log
#                    리스트만 in-place rewrite.
# 원칙:
#   - 본 helper 는 PROGRESS.md 의 *frontmatter scheduled_task_log* 만 수정.
#   - 기존 entry 는 보존 (newest-first 정렬, head 에 append + tail trim).
#   - 다른 frontmatter 필드 / 본문은 절대 건드리지 않음.
#   - PROGRESS.md 가 없거나 scheduled_task_log 섹션이 없으면 exit 1 (no-op).
# SSoT: CLAUDE.md §1.8 (유실 최소화) + PROGRESS.md frontmatter 16번째 세션 신설.
#
# Usage:
#   bash scripts/append-scheduled-task-log.sh <codename> <check_exit> "<action>" "<ahead_delta>"
#   bash scripts/append-scheduled-task-log.sh --noop <codename>
#       └─ shorthand: check_exit=0 / action="noop: clean + no drift" / ahead_delta="0"
#
# Examples:
#   bash scripts/append-scheduled-task-log.sh admiring-fervent-dijkstra 0 \
#        "TBD_16TH_SNAPSHOT 백필 + helper 신설" "+1"
#   bash scripts/append-scheduled-task-log.sh --noop admiring-fervent-dijkstra
#
# Exit codes:
#   0 = success (entry appended + rolling enforced)
#   1 = invalid usage / file missing / parse error
#   2 = scheduled_task_log section not found in PROGRESS.md
# ────────────────────────────────────────────────────────────────
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

PROGRESS_FILE="PROGRESS.md"
ROLLING_N="${ROLLING_N:-20}"

# ── 인자 파싱 ──────────────────────────────────────────────────
if [[ "${1:-}" == "--noop" ]]; then
  if [[ -z "${2:-}" ]]; then
    echo "ERROR: --noop requires <codename> as 2nd arg" >&2
    exit 1
  fi
  CODENAME="$2"
  CHECK_EXIT="0"
  ACTION="noop: clean + no drift"
  AHEAD_DELTA="0"
elif [[ $# -ne 4 ]]; then
  echo "Usage: $0 <codename> <check_exit> \"<action>\" \"<ahead_delta>\"" >&2
  echo "       $0 --noop <codename>" >&2
  exit 1
else
  CODENAME="$1"
  CHECK_EXIT="$2"
  ACTION="$3"
  AHEAD_DELTA="$4"
fi

# ── 사전 검증 ──────────────────────────────────────────────────
if [[ ! -f "${PROGRESS_FILE}" ]]; then
  echo "ERROR: ${PROGRESS_FILE} not found at ${REPO_ROOT}" >&2
  exit 1
fi

if ! grep -q '^scheduled_task_log:' "${PROGRESS_FILE}"; then
  echo "ERROR: 'scheduled_task_log:' section not found in ${PROGRESS_FILE}" >&2
  echo "       16번째 세션 (nice-kind-babbage) 이후 신설된 섹션이어야 함." >&2
  exit 2
fi

# ── 현재 시각 (KST) ────────────────────────────────────────────
TS_KST="$(TZ=Asia/Seoul date +%Y-%m-%dT%H:%M:%S+09:00)"

# ── 새 entry 블록 (4 줄: ts/codename/check_exit/action/ahead_delta) ──
NEW_ENTRY=$(cat <<EOF
  - ts: ${TS_KST}
    codename: ${CODENAME}
    check_exit: ${CHECK_EXIT}
    action: "${ACTION}"
    ahead_delta: "${AHEAD_DELTA}"
EOF
)

# ── PROGRESS.md 편집 (Python 으로 YAML-safe in-place rewrite) ────
# 직접 awk/sed 로는 frontmatter `---` 경계 안의 scheduled_task_log 리스트만
# 안전하게 자르기 어려우므로 python3 사용 (Cowork 환경 표준).
python3 - "${PROGRESS_FILE}" "${NEW_ENTRY}" "${ROLLING_N}" <<'PYEOF'
import sys, re, pathlib

path = pathlib.Path(sys.argv[1])
new_entry = sys.argv[2]
rolling_n = int(sys.argv[3])

text = path.read_text(encoding='utf-8')

# frontmatter 경계
fm_pattern = re.compile(r'^(---\n)(.*?)(\n---\n)', re.DOTALL)
m = fm_pattern.match(text)
if not m:
    sys.stderr.write("ERROR: frontmatter (--- ... ---) not found at file head\n")
    sys.exit(1)

fm_open, fm_body, fm_close = m.group(1), m.group(2), m.group(3)

# scheduled_task_log: 섹션 본문 추출
# YAML key 가 행 머리에 0칸 들여쓰기로 시작하면 이전 섹션 종료.
sec_re = re.compile(
    r'(scheduled_task_log:\s*\n)(.*?)(?=\n[A-Za-z_][A-Za-z0-9_]*:\s*\n|\Z)',
    re.DOTALL,
)
sm = sec_re.search(fm_body)
if not sm:
    sys.stderr.write("ERROR: scheduled_task_log: section parse failed\n")
    sys.exit(2)

sec_header = sm.group(1)
sec_body = sm.group(2).rstrip('\n') + '\n'

# 기존 entry 분할: '  - ts:' 로 시작하는 블록 단위로 split.
entry_re = re.compile(r'(?m)^  - ts:.*?(?=^  - ts:|\Z)', re.DOTALL)
existing = entry_re.findall(sec_body)
# 비-entry 잔여 라인 (주석 등) 은 sec_body 에서 첫 entry 이전까지로 한정.
first_entry_idx = sec_body.find('  - ts:')
if first_entry_idx < 0:
    preamble = sec_body
    existing = []
else:
    preamble = sec_body[:first_entry_idx]

# 새 entry 를 head 에 prepend + rolling N
new_entry_block = new_entry.rstrip('\n') + '\n'
all_entries = [new_entry_block] + existing
all_entries = all_entries[:rolling_n]

new_sec_body = preamble + ''.join(all_entries)
new_section = sec_header + new_sec_body
new_fm_body = fm_body[:sm.start()] + new_section + fm_body[sm.end():]
new_text = fm_open + new_fm_body + fm_close + text[m.end():]

path.write_text(new_text, encoding='utf-8')
print(f"✅ appended entry to scheduled_task_log (rolling N={rolling_n}, kept {len(all_entries)} entries)")
PYEOF

exit 0
