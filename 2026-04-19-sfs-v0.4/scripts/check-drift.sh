#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────
# Solon v0.4-r3 · scripts/check-drift.sh  (v0.1)
# 목적: dev staging (`2026-04-19-sfs-v0.4/solon-mvp-dist/`) ↔
#       stable repo (`~/workspace/solon-mvp/`) 간 drift 를
#       **dry-run only preview** 로 가시화. 변경 0.
#       cut-release.sh / sync-stable-to-dev.sh 호출 직전에
#       사용자가 "예상 변경" 빠르게 확인용.
#
# WU: WU-31 (Release tooling Phase 0 — local sh).
# 신설: 24번째 사이클 19번째 scheduled run (user-active-deferred,
#        2026-04-27 ~06:08 KST, codename great-kind-turing),
#        D-B-WU-31 §7 row 6 1 micro-step.
# SSoT: sprints/WU-31.md §5 ((선택) check-drift.sh helper 사양).
#
# 원칙 (WU-31 §0 + §1.13 R-D1):
#   §0.1 MINIMAL change — preview only, 변경 0.
#   §0.5 dry-run default — `--apply` 플래그 자체 없음 (preview 전용 helper).
#   cut-release.sh / sync-stable-to-dev.sh 와 동일 allowlist + blocklist 사용
#   (3 sh 가 같은 .visibility-rules.yaml policy enforce, 후속 row 7 활성).
#
# Allowlist (WU-31 §2.3 verbatim, hard-coded):
#     ✅ VERSION / CHANGELOG.md / README.md / CLAUDE.md /
#        install.sh / install.ps1 / upgrade.sh / upgrade.ps1 /
#        uninstall.sh / uninstall.ps1 / templates/
#     ❌ APPLY-INSTRUCTIONS.md (dev 운영자 전용, hard blocklist)
#
# Usage:
#   bash scripts/check-drift.sh                     # dev↔stable preview
#   bash scripts/check-drift.sh --quiet             # summary 만 출력
#   bash scripts/check-drift.sh --help
#
# Env:
#   SOLON_STABLE_REPO=...    # stable repo 경로 override (default: ~/workspace/solon-mvp)
#
# Exit codes:
#   0 = no drift (dev↔stable 완전 일치 + leak 0)
#   1 = invalid usage
#   2 = dev staging path 없음
#   3 = stable repo path 없음
#   8 = drift 존재 (정상 preview, release cut 시 변경 예정)
#   9 = leak 위험 검출 (BLOCKLIST hit + visibility 미설정 — release blocker)
#  99 = unknown error
# ────────────────────────────────────────────────────────────────
set -euo pipefail

# ── 기본 변수 ─────────────────────────────────────────────────
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEV_STAGING="${REPO_ROOT}/solon-mvp-dist"
STABLE_REPO="${SOLON_STABLE_REPO:-${HOME}/workspace/solon-mvp}"

QUIET=0
SHOW_HELP=0

# Allowlist (cut-release.sh / sync-stable-to-dev.sh 와 동일, WU-31 §2.3 verbatim)
ALLOWLIST=(
  "VERSION"
  "CHANGELOG.md"
  "README.md"
  "CLAUDE.md"
  "AGENTS.md"
  "GUIDE.md"
  "install.sh"
  "install.ps1"
  "upgrade.sh"
  "upgrade.ps1"
  "uninstall.sh"
  "uninstall.ps1"
  "templates"
)

# Hard blocklist (dev 전용 — stable 잔존 시 leak)
BLOCKLIST=(
  "APPLY-INSTRUCTIONS.md"
)

# ── helper: 출력 ─────────────────────────────────────────────
log()  { [[ "${QUIET}" == "1" ]] || printf '[check-drift] %s\n' "$*"; }
say()  { printf '[check-drift] %s\n' "$*"; }
warn() { printf '[check-drift] ⚠️  %s\n' "$*" >&2; }
fail() { printf '[check-drift] ❌ %s\n' "$1" >&2; exit "${2:-1}"; }

usage() {
  sed -n '/^# Usage:/,/^# ────/p' "${BASH_SOURCE[0]}" \
    | sed '$d' \
    | sed 's/^# \{0,1\}//'
}

# ── 인자 파싱 ────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --quiet|-q)    QUIET=1; shift ;;
    --dry-run)     shift ;;   # default & only mode (no-op flag for symmetry with sibling sh)
    -h|--help)     SHOW_HELP=1; shift ;;
    *)             fail "unknown arg: $1 (use --help)" 1 ;;
  esac
done

if [[ "${SHOW_HELP}" == "1" ]]; then
  usage
  exit 0
fi

# ── Pre-flight ───────────────────────────────────────────────
if [[ ! -d "${DEV_STAGING}" ]]; then
  fail "dev staging not found: ${DEV_STAGING}" 2
fi

if [[ ! -d "${STABLE_REPO}" ]]; then
  fail "stable repo not found: ${STABLE_REPO} (set SOLON_STABLE_REPO env if relocated)" 3
fi

log "─── check-drift.sh v0.1 (dry-run only preview) ───"
log "dev    = ${DEV_STAGING}"
log "stable = ${STABLE_REPO}"
log ""

# ── 헬퍼: allowlist 항목 expand → 실제 파일 list ─────────────
# (templates/ 같은 디렉토리는 recursive 로 확장)
expand_files() {
  local base="$1" item="$2"
  local full="${base}/${item}"
  if [[ -f "${full}" ]]; then
    printf '%s\n' "${item}"
  elif [[ -d "${full}" ]]; then
    (cd "${base}" && find "${item}" -type f 2>/dev/null | LC_ALL=C sort)
  fi
}

# ── 파일 목록 수집 ───────────────────────────────────────────
DEV_FILES=()
STABLE_FILES=()
for item in "${ALLOWLIST[@]}"; do
  while IFS= read -r f; do
    [[ -n "${f}" ]] && DEV_FILES+=("${f}")
  done < <(expand_files "${DEV_STAGING}" "${item}")
  while IFS= read -r f; do
    [[ -n "${f}" ]] && STABLE_FILES+=("${f}")
  done < <(expand_files "${STABLE_REPO}" "${item}")
done

# ── 비교: dev → stable (M / A) ───────────────────────────────
DEV_TO_STABLE=()
IDENTICAL=0
for f in "${DEV_FILES[@]:-}"; do
  [[ -z "${f:-}" ]] && continue
  src="${DEV_STAGING}/${f}"
  dst="${STABLE_REPO}/${f}"
  if [[ -f "${dst}" ]]; then
    if cmp -s "${src}" "${dst}"; then
      IDENTICAL=$((IDENTICAL+1))
    else
      if [[ "${f}" == "VERSION" ]]; then
        dev_v=$(head -n1 "${src}" 2>/dev/null | tr -d ' \t\r' || echo "?")
        stb_v=$(head -n1 "${dst}" 2>/dev/null | tr -d ' \t\r' || echo "?")
        DEV_TO_STABLE+=("M ${f}  (dev: ${dev_v} / stable: ${stb_v})")
      else
        # diff 는 differ 시 exit 1 — set -e+pipefail 회피용 분리 호출
        # (sync-stable-to-dev.sh 의 디버그 fix 패턴 재사용)
        set +e
        diff_out=$(diff -u "${dst}" "${src}" 2>/dev/null)
        set -e
        diff_lines=$(printf '%s\n' "${diff_out}" | wc -l | tr -d ' ')
        DEV_TO_STABLE+=("M ${f}  (~${diff_lines} diff lines)")
      fi
    fi
  else
    DEV_TO_STABLE+=("A ${f}  (dev only, stable 없음)")
  fi
done

# ── 비교: stable → dev (D = stable에만 존재) ─────────────────
STABLE_TO_DEV=()
for f in "${STABLE_FILES[@]:-}"; do
  [[ -z "${f:-}" ]] && continue
  if [[ ! -f "${DEV_STAGING}/${f}" ]]; then
    STABLE_TO_DEV+=("D ${f}  (stable only, dev 없음)")
  fi
done

# ── Leak 검사: BLOCKLIST 가 stable 에 잔존하는지 ─────────────
LEAK_BLOCKED=()
for item in "${BLOCKLIST[@]}"; do
  if [[ -e "${STABLE_REPO}/${item}" ]]; then
    LEAK_BLOCKED+=("${item}")
  fi
done

# ── Leak 검사: frontmatter visibility 미설정 (placeholder) ───
# WU-31 row 7 에서 .visibility-rules.yaml enforcement 활성 시 실 동작.
# 현 시점은 enforcement 비활성 placeholder (false-positive 방지).
LEAK_VISIBILITY=()

# ── 출력 ─────────────────────────────────────────────────────
log "dev → stable 동기 안 된 파일 ${#DEV_TO_STABLE[@]}건:"
if [[ ${#DEV_TO_STABLE[@]} -eq 0 ]]; then
  log "  (없음)"
else
  for line in "${DEV_TO_STABLE[@]}"; do
    log "  ${line}"
  done
fi
log ""

log "stable → dev 동기 안 된 파일 ${#STABLE_TO_DEV[@]}건:"
if [[ ${#STABLE_TO_DEV[@]} -eq 0 ]]; then
  log "  (없음)"
else
  for line in "${STABLE_TO_DEV[@]}"; do
    log "  ${line}"
  done
fi
log ""

log "leak 위험 (BLOCKLIST 가 stable 에 잔존):"
if [[ ${#LEAK_BLOCKED[@]} -eq 0 ]]; then
  log "  (없음)"
else
  for f in "${LEAK_BLOCKED[@]}"; do
    log "  ⚠️  ${f}  (dev 전용 파일이 stable 에 commit 됨)"
  done
fi
log ""

log "leak 위험 (frontmatter visibility 미설정):"
log "  (visibility enforcement 비활성, WU-31 §7 row 7 활성화 후 동작)"
log ""

# ── Summary + exit code 결정 ─────────────────────────────────
DRIFT_TOTAL=$(( ${#DEV_TO_STABLE[@]} + ${#STABLE_TO_DEV[@]} ))
LEAK_TOTAL=$(( ${#LEAK_BLOCKED[@]} + ${#LEAK_VISIBILITY[@]} ))

say "summary: drift=${DRIFT_TOTAL} (dev→stable=${#DEV_TO_STABLE[@]} · stable→dev=${#STABLE_TO_DEV[@]}) · identical=${IDENTICAL} · leak=${LEAK_TOTAL}"

if [[ ${LEAK_TOTAL} -gt 0 ]]; then
  warn "leak 위험 ${LEAK_TOTAL}건 검출 — release cut 전 cleanup 필요 (exit 9)"
  exit 9
fi

if [[ ${DRIFT_TOTAL} -gt 0 ]]; then
  log "✅ preview complete · drift ${DRIFT_TOTAL}건 (cut-release / sync-stable-to-dev 호출 시 변경 예정, exit 8)"
  exit 8
fi

log "✅ no drift · dev↔stable 완전 일치 · 0 changes (exit 0)"
exit 0
