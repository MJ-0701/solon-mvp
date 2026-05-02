#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────
# Solon v0.4-r3 · scripts/resume-session-check.sh  (v0.4)
# 목적: 세션 진입 직후 (§1.12 mutex claim 직후) 1회 실행하는 sanity check.
#       - staged/untracked 유실 위험 감지 (P-03 패턴)
#       - PROGRESS.md 의 TBD_ 플레이스홀더 감지
#       - mutex last_heartbeat TTL drift 감지
#       - FUSE index.lock 존재 감지
#       - <sha> angle-bracket 미실체 감지 (v0.2, P-03 변종 — 15번째 cd41dff vs 5d4c6c6 사례)
#       - scheduled_task_log drift 감지 (v0.3, hourly 주기 깨짐 / helper 호출 누락)
#       - product release handoff drift 감지 (v0.4, dist VERSION vs entry SSoT 불일치)
# 변경 이력:
#   v0.1 (15번째 admiring-nice-faraday) — 초안 5 checks.
#   v0.2 (16번째 nice-kind-babbage)     — check #6 추가 (angle-bracket sha + HEAD ancestor 검증).
#                                         inline code (` ... `) 안의 `<sha>` 는 retrospective 참조로 제외.
#   v0.3 (17번째 admiring-fervent-dijkstra)
#                                       — check #7 추가 (scheduled_task_log 마지막 entry timestamp 가
#                                         현재 시간보다 90분 이상 지났으면 exit 16 warning).
#                                         helper 호출 누락 / hourly cron 끊김 추적.
#   v0.4 (codex-handoff-drift-guard)    — check #8 추가 (`solon-mvp-dist/VERSION` 이
#                                         PROGRESS resume_hint / HANDOFF 에 없으면 exit 17).
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
#   15 = PROGRESS.md 에 <sha> 형태 angle-bracket sha 플레이스홀더 존재
#        (15번째 세션 사례: <cd41dff> 예측 sha 가 실체 5d4c6c6 와 mismatch)
#   16 = scheduled_task_log 마지막 entry > 90분 (hourly cron 끊김 / helper 호출 누락)
#   17 = product release handoff drift (dist VERSION 이 entry SSoT 에 미반영)
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

# ── 6. <sha> angle-bracket 플레이스홀더 감지 ────────────────────
# 15번째 세션 (admiring-nice-faraday) 이 본문에 `<cd41dff>` 형태로 예측 sha 를
# 적었지만 실체 commit 은 `5d4c6c6` 로 다른 sha 가 나와 mismatch 발생.
# 패턴: `<` + 7~12 자 hex + `>` (markdown autolink 형태도 매칭하지만 일반 hex 만).
# 실제 git log 에 존재하는 sha 인지 검증 — 없으면 unrealized prediction.
if [[ -f "${PROGRESS_FILE}" ]]; then
  # inline code (` ... `) 는 사후 retrospective 참조 — 검사 대상에서 제외.
  # sed 로 backtick 쌍을 제거 후에 남은 `<sha>` 만 "live" prediction 으로 간주.
  bracket_shas=$(sed -E 's/`[^`]*`//g' "${PROGRESS_FILE}" 2>/dev/null | \
                 grep -oE '<[0-9a-f]{7,12}>' 2>/dev/null | \
                 tr -d '<>' | sort -u || true)
  if [[ -n "${bracket_shas}" ]]; then
    bad=0
    bad_list=""
    for s in ${bracket_shas}; do
      # 단순 존재 (cat-file -e) 만으로는 부족 — dangling commit (rebase/amend 잔재) 도
      # exist 하므로 HEAD ancestor 인지까지 확인해야 P-03 변종 (예측↔실체 sha mismatch) 감지.
      if ! git merge-base --is-ancestor "${s}" HEAD 2>/dev/null; then
        bad=$((bad+1))
        bad_list="${bad_list} ${s}"
      fi
    done
    if [[ "${bad}" -gt 0 ]]; then
      issues+=("bracket_sha_unrealized:${bad}:$(echo ${bad_list} | tr ' ' ',')")
      [[ $exit_code -eq 0 ]] && exit_code=15 || exit_code=99
    fi
  fi
fi

# ── 7. scheduled_task_log drift 감지 (v0.3) ─────────────────────
# 17번째 세션 (admiring-fervent-dijkstra) 신설.
# scheduled_task_log 마지막 entry (newest-first 정렬이므로 첫 entry) 의 ts 가
# 현재 시간 기준 90분을 초과하면 hourly cron 끊김 또는 helper 호출 누락.
# 90분 = 1시간 cron 주기 + 30분 grace period.
DRIFT_THRESHOLD_SEC="${DRIFT_THRESHOLD_SEC:-5400}"  # 90분
if [[ -f "${PROGRESS_FILE}" ]]; then
  # frontmatter 안의 첫 `  - ts:` 줄에서 ISO timestamp 추출.
  # awk 로 'scheduled_task_log:' 블록 진입 후 첫 ts 만 잡음.
  first_ts=$(awk '
    /^scheduled_task_log:/ {flag=1; next}
    flag && /^  - ts:/ {sub(/^  - ts: */, "", $0); print $0; exit}
    flag && /^[A-Za-z_].*:/ {flag=0}
  ' "${PROGRESS_FILE}" 2>/dev/null | tr -d ' ')
  if [[ -n "${first_ts}" ]]; then
    last_log_epoch=$(python3 -c "from datetime import datetime; print(int(datetime.fromisoformat('${first_ts}').timestamp()))" 2>/dev/null || echo 0)
    now_epoch=$(date +%s)
    if [[ "${last_log_epoch}" -gt 0 ]]; then
      drift_sec=$((now_epoch - last_log_epoch))
      if [[ "${drift_sec}" -gt "${DRIFT_THRESHOLD_SEC}" ]]; then
        drift_min=$((drift_sec / 60))
        issues+=("sched_log_drift:${drift_min}m")
        [[ $exit_code -eq 0 ]] && exit_code=16 || exit_code=99
      fi
    fi
  fi
fi

# ── 8. product release handoff drift 감지 (v0.4) ───────────────
# 새 세션의 전제는 이전 release/handoff 가 완결됐다는 것. dist VERSION 이
# resume_hint / handoff 에 반영되지 않았으면 product code 를 다시 훑기 전에
# entry SSoT 를 먼저 복구해야 한다.
PRODUCT_VERSION_FILE="solon-mvp-dist/VERSION"
HANDOFF_FILE="HANDOFF-next-session.md"
if [[ -f "${PRODUCT_VERSION_FILE}" && -f "${PROGRESS_FILE}" ]]; then
  product_version=$(head -n1 "${PRODUCT_VERSION_FILE}" 2>/dev/null | tr -d '[:space:]' || true)
  if [[ -n "${product_version}" && "${product_version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+-product$ ]]; then
    resume_hint_block=$(awk '/^resume_hint:/ {flag=1} flag {print} flag && /^---[[:space:]]*$/ {exit}' "${PROGRESS_FILE}" 2>/dev/null || true)
    if ! printf '%s\n' "${resume_hint_block}" | grep -Fq "${product_version}"; then
      issues+=("release_handoff_drift:progress_resume_hint:${product_version}")
      [[ $exit_code -eq 0 ]] && exit_code=17 || exit_code=99
    fi
    if [[ -f "${HANDOFF_FILE}" ]] && ! grep -Fq "${product_version}" "${HANDOFF_FILE}" 2>/dev/null; then
      issues+=("release_handoff_drift:handoff:${product_version}")
      [[ $exit_code -eq 0 ]] && exit_code=17 || exit_code=99
    fi
  fi
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
    [[ "${exit_code}" == 15 || "${exit_code}" == 99 ]] && echo "   [bracket_sha] PROGRESS.md 에 <sha> 형태 미실체 예측 sha. git log 에서 실제 sha 찾아 backfill (15번째 세션 cd41dff→5d4c6c6 사례 참조)" >&2
    [[ "${exit_code}" == 16 || "${exit_code}" == 99 ]] && echo "   [sched_log_drift] scheduled_task_log 마지막 entry > 90분. hourly cron 끊김 or helper 누락. 세션 종료 직전 'bash scripts/append-scheduled-task-log.sh <codename> <check_exit> \"<action>\" \"<ahead_delta>\"' 호출 확인" >&2
    [[ "${exit_code}" == 17 || "${exit_code}" == 99 ]] && echo "   [release_handoff_drift] solon-mvp-dist/VERSION 이 PROGRESS resume_hint / HANDOFF 에 미반영. product code 재검증 전에 entry SSoT 를 최신 release 로 갱신." >&2
  fi
fi

exit ${exit_code}
