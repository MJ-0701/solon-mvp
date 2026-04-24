#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────
# Solon v0.4-r3 · scripts/resume-session-check.sh  (v0.1)
# 목적: 세션 진입 직후 (§1.12 mutex claim 직후) 1회 실행하는 sanity check.
#       - staged/untracked 유실 위험 감지 (P-03 패턴)
#       - PROGRESS.md 의 TBD_ 플레이스홀더 감지
#       - mutex last_heartbeat TTL drift 감지
#       - FUSE index.lock 존재 감지
# 원칙: **감지만 함. 자동 복구 금지** (원칙 2 self-validation-forbidden 준수).
#        감지 시 표준 error code 로 exit + STDERR 에 복구 가이드 출력.
# SSoT: CLAUDE.md §1.8 + §1.12 + learning-logs/2026-05/P-03
# Usage: ./scripts/resume-session-check.sh [--json]
#   --json : structured JSON 출력 (scheduled task 에서 파싱용)
# Exit codes:
#   0 = clean (아무 이슈 없음)
#   10 = staged diff 존재 (P-03 발동 가능)
#   11 = untracked 중요 파일 존재 (PROGRESS/WU-*.md)
#   12 = PROGRESS.md 에 TBD_ 플레이스홀더 존재 (미실체화 commit 의심)
#   13 = mutex last_heartbeat TTL 초과 (stale owner)
#   14 = FUSE index.lock 존재 (직접 제거 불가 상태)
#   99 = 복합 이슈 (여러 개 동시 발견)
# ────────────────────────────────────────────────────────────────
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

PROGRESS_FILE="PROGRESS.md"
TTL_MINUTES="${TTL_MINUTES:-15}"

JSON_MODE=0
if [[ "${1:-}" == "--json" ]]; then
  JSON_MODE=1
fi

issues=()
exit_code=0

# ── 1. staged diff 감지 ─────────────────────────────────────────
staged_count=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
if [[ "${staged_count}" -gt 0 ]]; then
  issues+=("staged:${staged_count}")
  exit_code=10
fi

# ── 2. untracked 중요 파일 감지 ─────────────────────────────────
untracked_important=$(git ls-files --others --exclude-standard 2>/dev/null | \
  grep -E '(PROGRESS\.md|sprints/WU-[0-9]+(\.[0-9]+)?\.md|sessions/2026-.*\.md)' || true)
if [[ -n "${untracked_important}" ]]; then
  issues+=("untracked_important:$(echo "${untracked_important}" | wc -l | tr -d ' ')")
  [[ $exit_code -eq 0 ]] && exit_code=11 || exit_code=99
fi

# ── 3. PROGRESS.md TBD_ 플레이스홀더 감지 ───────────────────────
# `TBD_[A-Z_]+` 형태 (실제 미실체화 sha 플레이스홀더) 만 카운트.
# 단순 `TBD_` 언급 (설명/주석) 은 무시. 또한 YAML 주석 줄 (`#` 로 시작) 도 제외.
if [[ -f "${PROGRESS_FILE}" ]]; then
  tbd_count=$(grep -v '^\s*#' "${PROGRESS_FILE}" 2>/dev/null | \
              grep -oE 'TBD_[A-Z][A-Z0-9_]{2,}' 2>/dev/null | \
              grep -vE '(TBD_\(|`TBD_`|TBD_플레이스홀더|TBD_/)' | \
              wc -l | tr -d ' ')
  if [[ "${tbd_count}" -gt 0 ]]; then
    issues+=("tbd_placeholders:${tbd_count}")
    [[ $exit_code -eq 0 ]] && exit_code=12 || exit_code=99
  fi
fi

# ── 4. mutex last_heartbeat TTL drift 감지 ──────────────────────
# frontmatter 의 current_wu_owner.last_heartbeat 파싱
# 형식: "last_heartbeat: 2026-04-25T00:20:00+09:00"
owner_line=$(awk '/^current_wu_owner:/ {flag=1; next} flag && /^[a-zA-Z_]+:/ && !/^  /{flag=0} flag' "${PROGRESS_FILE}" 2>/dev/null | head -20 || true)
last_hb=$(echo "${owner_line}" | awk -F': *' '/last_heartbeat:/ {print $2; exit}' | tr -d ' ')
owner_codename=$(awk -F': *' '/^  session_codename:/ {print $2; exit}' "${PROGRESS_FILE}" 2>/dev/null | tr -d ' ' || true)

if [[ -n "${last_hb}" && "${last_hb}" != "null" ]]; then
  # date -d 는 GNU 에서만. macOS compat 필요하면 python 사용.
  hb_epoch=$(python3 -c "from datetime import datetime; print(int(datetime.fromisoformat('${last_hb}').timestamp()))" 2>/dev/null || echo 0)
  now_epoch=$(date +%s)
  if [[ "${hb_epoch}" -gt 0 ]]; then
    drift_sec=$((now_epoch - hb_epoch))
    ttl_sec=$((TTL_MINUTES * 60))
    if [[ "${drift_sec}" -gt "${ttl_sec}" ]]; then
      issues+=("stale_mutex:${owner_codename}:${drift_sec}s")
      [[ $exit_code -eq 0 ]] && exit_code=13 || exit_code=99
    fi
  fi
fi

# ── 5. FUSE index.lock 감지 ────────────────────────────────────
if [[ -f ".git/index.lock" ]]; then
  issues+=("fuse_index_lock:exists")
  [[ $exit_code -eq 0 ]] && exit_code=14 || exit_code=99
fi

# ── 출력 ───────────────────────────────────────────────────────
if [[ ${JSON_MODE} -eq 1 ]]; then
  # JSON 한 줄
  joined=$(IFS=, ; echo "${issues[*]:-}")
  printf '{"exit_code":%d,"issues":"%s","timestamp":"%s"}\n' \
    "${exit_code}" "${joined}" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
else
  if [[ ${exit_code} -eq 0 ]]; then
    echo "✅ resume-session-check: clean (no issues detected)"
  else
    echo "⚠️  resume-session-check: issues detected (exit=${exit_code})" >&2
    for i in "${issues[@]:-}"; do
      echo "   - ${i}" >&2
    done
    echo "" >&2
    echo "📖 복구 가이드:" >&2
    [[ "${exit_code}" == 10 || "${exit_code}" == 99 ]] && echo "   [staged] git diff --cached HEAD 로 intent 확인 → commit 실체화 or reset. 참조: P-03" >&2
    [[ "${exit_code}" == 11 || "${exit_code}" == 99 ]] && echo "   [untracked] git status --short 로 파일 확인 → git add + commit or gitignore 판단" >&2
    [[ "${exit_code}" == 12 || "${exit_code}" == 99 ]] && echo "   [TBD_ placeholder] PROGRESS.md 에 미실체화 commit 표식. git log 로 실제 sha 찾아 backfill" >&2
    [[ "${exit_code}" == 13 || "${exit_code}" == 99 ]] && echo "   [stale mutex] §1.12 — 다른 세션 TTL 초과. 사용자 승인 후 takeover. 자동 금지." >&2
    [[ "${exit_code}" == 14 || "${exit_code}" == 99 ]] && echo "   [FUSE lock] §1.6 FUSE bypass — cp -a .git /tmp/solon-git-<ts>/ → 작업 → rsync back" >&2
  fi
fi

exit ${exit_code}
