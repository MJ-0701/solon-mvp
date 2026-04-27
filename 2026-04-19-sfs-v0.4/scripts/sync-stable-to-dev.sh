#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────
# Solon v0.4-r3 · scripts/sync-stable-to-dev.sh  (v0.1)
# 목적: stable repo (`~/workspace/solon-mvp/`) 의 hotfix commit 을
#       dev staging (`2026-04-19-sfs-v0.4/solon-mvp-dist/`) 로
#       역방향 back-port (R-D1 hotfix path 자동화).
#       stable → dev cp + allowlist 검증 + dev `git add` 만
#       (commit 은 사용자 명시 — `WU-31/sync(stable): <sha>` 표준).
#
# WU: WU-31 (Release tooling Phase 0 — local sh).
# 신설: 24번째 사이클 18번째 scheduled run (user-active-deferred,
#        2026-04-27 ~05:13 KST, codename eager-stoic-pasteur),
#        D-B-WU-31 §7 row 5 1 micro-step.
# SSoT: sprints/WU-31.md §3 (sync-stable-to-dev.sh 사양 verbatim).
#
# 원칙 (WU-31 §0 + §1.13 R-D1):
#   §0.1 MINIMAL change — hotfix back-port only, 추가 기능 신설 금지.
#   §0.2 R-D1 dev-first  — hotfix 는 stable 에서 발견 OK, 단 같은 세션
#                          내 dev staging 동기화 의무. 본 sh 가 그 의무 자동화.
#   §0.3 §1.5 push manual — git add 까지만. commit 은 사용자 명시.
#                          (cut-release.sh 가 stable commit 까지 만들지만
#                           sync-stable-to-dev.sh 는 그보다 보수적으로
#                           commit 도 사용자 manual — hotfix 는 사용자
#                           컨펌이 더 중요.)
#   §0.4 dry-run default  — `--apply` 명시 시만 실 변경.
#
# Allowlist (WU-31 §2.3 정합, hard-coded):
#     ✅ VERSION / CHANGELOG.md / README.md / CLAUDE.md /
#        install.sh / upgrade.sh / uninstall.sh / templates/
#     ❌ APPLY-INSTRUCTIONS.md (dev 운영자 전용, hard blocklist)
#     · stable 에 위 외 파일이 commit 되었으면 WARN (allowlist 외, skip)
#
# Usage:
#   bash scripts/sync-stable-to-dev.sh --stable-sha <sha>           # dry-run default
#   bash scripts/sync-stable-to-dev.sh --stable-sha abc1234 --apply
#   bash scripts/sync-stable-to-dev.sh --stable-sha abc1234 --apply --no-changelog
#   bash scripts/sync-stable-to-dev.sh --help
#
# Exit codes:
#   0 = success (dry-run summary 또는 apply 완료)
#   1 = invalid usage / pre-flight 실패 / allowlist 위반
#   2 = dev staging path 없음
#   3 = stable repo path 없음 / git 비정상
#   4 = stable-sha 가 stable repo 에 없음 또는 invalid commit
#  99 = unknown error
# ────────────────────────────────────────────────────────────────
set -euo pipefail

# ── 기본 변수 ─────────────────────────────────────────────────
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEV_STAGING="${REPO_ROOT}/solon-mvp-dist"
STABLE_REPO="${SOLON_STABLE_REPO:-${HOME}/workspace/solon-mvp}"

STABLE_SHA=""
APPLY=0
NO_CHANGELOG=0
SHOW_HELP=0

# Allowlist (cut-release.sh 와 동일, WU-31 §2.3 verbatim)
ALLOWLIST=(
  "VERSION"
  "CHANGELOG.md"
  "README.md"
  "CLAUDE.md"
  "install.sh"
  "upgrade.sh"
  "uninstall.sh"
  "templates"
)

# Hard blocklist (dev 전용, stable → dev 시 reverse 흐름이라 적용 의미 거의 없지만
# stable 잔존분 검증 차원)
BLOCKLIST=(
  "APPLY-INSTRUCTIONS.md"
)

# ── helper: 출력 ─────────────────────────────────────────────
log()  { printf '[sync-stable] %s\n' "$*"; }
warn() { printf '[sync-stable] ⚠️  %s\n' "$*" >&2; }
fail() { printf '[sync-stable] ❌ %s\n' "$1" >&2; exit "${2:-1}"; }

usage() {
  sed -n '/^# Usage:/,/^# ────/p' "${BASH_SOURCE[0]}" \
    | sed '$d' \
    | sed 's/^# \{0,1\}//'
}

# ── 인자 파싱 ────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --stable-sha)    STABLE_SHA="${2:-}"; shift 2 ;;
    --stable-sha=*)  STABLE_SHA="${1#*=}"; shift ;;
    --apply)         APPLY=1; shift ;;
    --dry-run)       APPLY=0; shift ;;
    --no-changelog)  NO_CHANGELOG=1; shift ;;
    -h|--help)       SHOW_HELP=1; shift ;;
    *)               fail "unknown arg: $1 (use --help)" 1 ;;
  esac
done

if [[ "${SHOW_HELP}" == "1" ]]; then
  usage
  exit 0
fi

if [[ -z "${STABLE_SHA}" ]]; then
  fail "missing --stable-sha (예: --stable-sha abc1234)" 1
fi

# stable-sha 형식 검증 (간단 — short or full SHA)
if ! [[ "${STABLE_SHA}" =~ ^[0-9a-f]{4,40}$ ]]; then
  fail "invalid --stable-sha format '${STABLE_SHA}' (expected hex 4~40 chars)" 1
fi

MODE="dry-run"
[[ "${APPLY}" == "1" ]] && MODE="apply"

log "─── sync-stable-to-dev.sh v0.1 ───"
log "stable-sha = ${STABLE_SHA}"
log "mode       = ${MODE}"
log "stable     = ${STABLE_REPO}"
log "dev        = ${DEV_STAGING}"
log "no-changelog=${NO_CHANGELOG}"
log ""

# ── §3.2.1 Pre-flight ────────────────────────────────────────
log "[1/4] Pre-flight"

if [[ ! -d "${STABLE_REPO}" ]]; then
  fail "stable repo not found: ${STABLE_REPO} (set SOLON_STABLE_REPO env if relocated)" 3
fi

if [[ ! -d "${STABLE_REPO}/.git" ]]; then
  fail "stable repo missing .git: ${STABLE_REPO}" 3
fi

if [[ ! -d "${DEV_STAGING}" ]]; then
  fail "dev staging not found: ${DEV_STAGING}" 2
fi

# stable-sha 가 실제 commit 인지 확인
if ! git -C "${STABLE_REPO}" rev-parse --verify --quiet "${STABLE_SHA}^{commit}" >/dev/null; then
  fail "stable-sha not found in stable repo: ${STABLE_SHA}" 4
fi

# 정확한 full SHA 로 정규화
STABLE_SHA_FULL=$(git -C "${STABLE_REPO}" rev-parse "${STABLE_SHA}")
STABLE_SHA_SHORT="${STABLE_SHA_FULL:0:7}"
COMMIT_SUBJECT=$(git -C "${STABLE_REPO}" log -1 --format='%s' "${STABLE_SHA_FULL}")
COMMIT_DATE=$(git -C "${STABLE_REPO}" log -1 --format='%ai' "${STABLE_SHA_FULL}")

log "  ✅ paths ok / stable-sha verified"
log "    full sha = ${STABLE_SHA_FULL}"
log "    subject  = ${COMMIT_SUBJECT}"
log "    date     = ${COMMIT_DATE}"
log ""

# ── §3.2.2 stable commit 변경 파일 추출 ──────────────────────
log "[2/4] Extract changed files (git show --name-only)"

# git show --name-only 로 변경 파일 list (Added/Modified/Deleted 모두)
mapfile -t CHANGED_FILES < <(
  git -C "${STABLE_REPO}" show --name-only --pretty=format: "${STABLE_SHA_FULL}" \
    | sed '/^[[:space:]]*$/d'
)

if [[ ${#CHANGED_FILES[@]} -eq 0 ]]; then
  warn "stable-sha ${STABLE_SHA_SHORT} 에 변경 파일 없음 (merge commit?)"
  log "  ⏭️  nothing to sync"
  exit 0
fi

log "  변경 파일 ${#CHANGED_FILES[@]}건:"
for f in "${CHANGED_FILES[@]}"; do
  log "    · ${f}"
done
log ""

# ── §3.2.3 Allowlist 검증 + filter ───────────────────────────
log "[3/4] Allowlist filter"

# allowlist 매칭 헬퍼: 파일이 ALLOWLIST 의 어느 항목 아래 있는지 (또는 같은지) 검증
in_allowlist() {
  local file="$1"
  for item in "${ALLOWLIST[@]}"; do
    # exact match (파일 자체)
    if [[ "${file}" == "${item}" ]]; then return 0; fi
    # prefix match (templates/...)
    if [[ "${file}" == "${item}/"* ]]; then return 0; fi
  done
  return 1
}

in_blocklist() {
  local file="$1"
  for item in "${BLOCKLIST[@]}"; do
    if [[ "${file}" == "${item}" ]]; then return 0; fi
  done
  return 1
}

ALLOWED_FILES=()
SKIPPED_FILES=()
BLOCKED_FILES=()

for f in "${CHANGED_FILES[@]}"; do
  if in_blocklist "${f}"; then
    BLOCKED_FILES+=("${f}")
    log "  ✗ blocked: ${f} (BLOCKLIST — dev 전용 파일이 stable 에 commit 됨)"
    continue
  fi
  if in_allowlist "${f}"; then
    ALLOWED_FILES+=("${f}")
    log "  ✓ allowed: ${f}"
  else
    SKIPPED_FILES+=("${f}")
    log "  · skipped: ${f} (allowlist 외, sync 안 함)"
  fi
done

if [[ ${#BLOCKED_FILES[@]} -gt 0 ]]; then
  warn "BLOCKLIST hit ${#BLOCKED_FILES[@]}건 — stable 에 dev 전용 파일이 잘못 commit 됨"
  warn "(역방향 sync 는 skip, 별도 cleanup 필요)"
fi

log ""
log "  summary: allowed=${#ALLOWED_FILES[@]} skipped=${#SKIPPED_FILES[@]} blocked=${#BLOCKED_FILES[@]}"
log ""

if [[ ${#ALLOWED_FILES[@]} -eq 0 ]]; then
  warn "allowlist 매칭 변경 0건 — sync 할 파일 없음"
  log "  ⏭️  nothing to apply"
  exit 0
fi

# ── §3.2.4 Apply (--apply 시만) ──────────────────────────────
if [[ "${APPLY}" == "0" ]]; then
  log "[4/4] Apply  ⏭️  skipped (dry-run, use --apply to copy + git add)"
  log ""
  log "  preview: dev staging 에 다음 ${#ALLOWED_FILES[@]} 파일 동기화 예정:"
  for f in "${ALLOWED_FILES[@]}"; do
    src="${STABLE_REPO}/${f}"
    dst="${DEV_STAGING}/${f}"
    if [[ -e "${src}" && -e "${dst}" ]]; then
      # diff 짧은 summary
      if cmp -s "${src}" "${dst}"; then
        log "    = ${f}  (identical, no-op)"
      else
        # diff 는 differ 시 exit 1, wc -l 은 0 — set -e+pipefail 회피용 분리 호출
        set +e
        diff_out=$(diff -u "${dst}" "${src}" 2>/dev/null)
        set -e
        diff_lines=$(printf '%s\n' "${diff_out}" | wc -l | tr -d ' ')
        log "    M ${f}  (~${diff_lines} diff lines)"
      fi
    elif [[ -e "${src}" && ! -e "${dst}" ]]; then
      log "    + ${f}  (new in dev)"
    elif [[ ! -e "${src}" && -e "${dst}" ]]; then
      log "    - ${f}  (deleted in stable, would remove from dev)"
    fi
  done
  log ""
  log "✅ dry-run complete · 0 changes applied"
  exit 0
fi

log "[4/4] Apply (stable → dev cp + dev git add)"

DEV_REPO_ROOT="$(git -C "${REPO_ROOT}" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${DEV_REPO_ROOT}" ]]; then
  warn "dev repo not under git (REPO_ROOT=${REPO_ROOT}) — git add skipped"
fi

COPIED=0
DELETED=0
for f in "${ALLOWED_FILES[@]}"; do
  src="${STABLE_REPO}/${f}"
  dst="${DEV_STAGING}/${f}"
  if [[ -e "${src}" ]]; then
    mkdir -p "$(dirname "${dst}")"
    cp -p "${src}" "${dst}"
    COPIED=$((COPIED+1))
    log "  ✓ ${f}"
  else
    # stable 에서 삭제된 파일 → dev 에서도 삭제
    if [[ -e "${dst}" ]]; then
      rm -f "${dst}"
      DELETED=$((DELETED+1))
      log "  ✗ removed dev/${f}"
    fi
  fi
done

log ""
log "  copied=${COPIED} deleted=${DELETED}"

# git add (dev side, commit 안 함 — 사용자 manual)
if [[ -n "${DEV_REPO_ROOT}" ]]; then
  for f in "${ALLOWED_FILES[@]}"; do
    rel_dev="${DEV_STAGING}/${f}"
    # repo root 기준 relative path 로 변환
    rel_in_repo=$(realpath --relative-to="${DEV_REPO_ROOT}" "${rel_dev}" 2>/dev/null || echo "${rel_dev}")
    git -C "${DEV_REPO_ROOT}" add "${rel_in_repo}" 2>/dev/null || warn "git add 실패: ${rel_in_repo}"
  done
  log "  ✓ dev git add 완료"
fi

# CHANGELOG hotfix entry (옵션)
if [[ "${NO_CHANGELOG}" == "0" ]]; then
  DEV_CHLOG="${DEV_STAGING}/CHANGELOG.md"
  if [[ -f "${DEV_CHLOG}" ]]; then
    TODAY=$(date -u +"%Y-%m-%d")
    HOTFIX_HEADER="## [hotfix] - ${TODAY}"
    if ! grep -qF "stable ${STABLE_SHA_SHORT}" "${DEV_CHLOG}"; then
      TMPFILE="$(mktemp)"
      {
        printf '%s\n\n' "${HOTFIX_HEADER}"
        printf -- '- (sync from stable %s) %s\n\n' "${STABLE_SHA_SHORT}" "${COMMIT_SUBJECT}"
        cat "${DEV_CHLOG}"
      } > "${TMPFILE}"
      mv "${TMPFILE}" "${DEV_CHLOG}"
      log "  ✓ dev/CHANGELOG.md hotfix entry prepended"
      [[ -n "${DEV_REPO_ROOT}" ]] && git -C "${DEV_REPO_ROOT}" add "${DEV_CHLOG}" 2>/dev/null || true
    else
      log "  · dev/CHANGELOG.md 이미 stable ${STABLE_SHA_SHORT} entry 존재"
    fi
  fi
fi

log ""
log "✅ apply complete"
log "    copied=${COPIED} deleted=${DELETED} (allowlist 매칭만)"
[[ ${#SKIPPED_FILES[@]} -gt 0 ]] && log "    skipped=${#SKIPPED_FILES[@]} (allowlist 외)"
[[ ${#BLOCKED_FILES[@]} -gt 0 ]] && log "    blocked=${#BLOCKED_FILES[@]} (BLOCKLIST hit)"
log ""
log "⚠️  commit 안 함 (§1.5' AI commit 권한 회수). 사용자 터미널에서:"
log "    cd ${DEV_REPO_ROOT:-<dev-repo>} && git status  # 변경 확인"
log "    git commit -m 'WU-31/sync(stable): ${STABLE_SHA_SHORT}'"
exit 0
