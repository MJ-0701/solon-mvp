#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────
# Solon v0.4-r3 · scripts/cut-release.sh  (v0.1)
# 목적: dev staging (`2026-04-19-sfs-v0.4/solon-mvp-dist/`) 의
#       allowlist 파일들을 stable repo (`~/workspace/solon-mvp/`) 로
#       정방향 sync (release cut). VERSION bump + CHANGELOG entry +
#       stable repo commit + (옵션) tag 까지. push 는 안 함 (§1.5).
#
# WU: WU-31 (Release tooling Phase 0 — local sh).
# 신설: 24번째 사이클 17번째 scheduled run (user-active-deferred,
#        2026-04-27 ~04:11 KST), D-B-WU-31 §7 row 4 1 micro-step.
# SSoT: sprints/WU-31.md §2 (cut-release.sh 사양 verbatim).
#
# 원칙 (WU-31 §0):
#   §0.1 MINIMAL change — 옵션 β. GitHub Action 신설 금지 (Phase 1+ 후속 WU).
#   §0.2 R-D1 dev-first  — 본 sh 는 dev staging only, stable 동봉 안 함.
#   §0.3 §1.5 push manual — commit + tag 까지만, push 는 사용자 터미널.
#   §0.4 §1.6 FUSE bypass 자동 — `.git/index.lock` 충돌 시 cp -a + rsync back.
#   §0.5 dry-run default  — `--apply` 명시 시만 실 변경.
#
# Allowlist (WU-31 §2.3, hard-coded — `.visibility-rules.yaml`
#   enforcement_active=true 는 후속 row 7 에서 활성):
#     ✅ VERSION / CHANGELOG.md / README.md / CLAUDE.md /
#        install.sh / upgrade.sh / uninstall.sh / templates/
#     ❌ APPLY-INSTRUCTIONS.md (dev 운영자 전용, hard blocklist)
#
# Usage:
#   bash scripts/cut-release.sh --version 0.3.0-mvp           # dry-run default
#   bash scripts/cut-release.sh --version 0.3.0-mvp --apply
#   bash scripts/cut-release.sh --version 0.3.0-mvp --apply --no-tag
#   bash scripts/cut-release.sh --version 0.3.0-mvp --apply --allow-dirty
#   bash scripts/cut-release.sh --help
#
# Exit codes:
#   0 = success (dry-run summary 또는 apply 완료)
#   1 = invalid usage / pre-flight 실패 / allowlist 위반
#   2 = dev staging path 없음
#   3 = stable repo path 없음 / git 비정상
#   4 = git status not clean (without --allow-dirty)
#   5 = TBD final_sha 검출 (release blocker — `final_sha: TBD_*` 인 WU 잔존)
#  99 = unknown error
# ────────────────────────────────────────────────────────────────
set -euo pipefail

# ── 기본 변수 ─────────────────────────────────────────────────
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEV_STAGING="${REPO_ROOT}/solon-mvp-dist"
STABLE_REPO="${SOLON_STABLE_REPO:-${HOME}/workspace/solon-mvp}"

VERSION=""
APPLY=0
ALLOW_DIRTY=0
NO_TAG=0
SHOW_HELP=0

# Allowlist (8 항목, WU-31 §2.3 verbatim)
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

# Hard blocklist (dev 전용)
BLOCKLIST=(
  "APPLY-INSTRUCTIONS.md"
)

# ── helper: 출력 ─────────────────────────────────────────────
log()  { printf '[cut-release] %s\n' "$*"; }
warn() { printf '[cut-release] ⚠️  %s\n' "$*" >&2; }
fail() { printf '[cut-release] ❌ %s\n' "$1" >&2; exit "${2:-1}"; }

usage() {
  sed -n '/^# Usage:/,/^# ────/p' "${BASH_SOURCE[0]}" \
    | sed '$d' \
    | sed 's/^# \{0,1\}//'
}

# ── 인자 파싱 ────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)       VERSION="${2:-}"; shift 2 ;;
    --version=*)     VERSION="${1#*=}"; shift ;;
    --apply)         APPLY=1; shift ;;
    --dry-run)       APPLY=0; shift ;;
    --allow-dirty)   ALLOW_DIRTY=1; shift ;;
    --no-tag)        NO_TAG=1; shift ;;
    -h|--help)       SHOW_HELP=1; shift ;;
    *)               fail "unknown arg: $1 (use --help)" 1 ;;
  esac
done

if [[ "${SHOW_HELP}" == "1" ]]; then
  usage
  exit 0
fi

if [[ -z "${VERSION}" ]]; then
  fail "missing --version (예: --version 0.3.0-mvp)" 1
fi

# semver-mvp 형식 검증: X.Y.Z-mvp (간단 regex)
if ! [[ "${VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+-mvp$ ]]; then
  fail "invalid --version format '${VERSION}' (expected X.Y.Z-mvp)" 1
fi

MODE="dry-run"
[[ "${APPLY}" == "1" ]] && MODE="apply"

log "─── cut-release.sh v0.1 ───"
log "version    = ${VERSION}"
log "mode       = ${MODE}"
log "dev        = ${DEV_STAGING}"
log "stable     = ${STABLE_REPO}"
log "allow-dirty= ${ALLOW_DIRTY}  no-tag=${NO_TAG}"
log ""

# ── §2.2.1 Pre-flight ────────────────────────────────────────
log "[1/5] Pre-flight"

if [[ ! -d "${DEV_STAGING}" ]]; then
  fail "dev staging not found: ${DEV_STAGING}" 2
fi

if [[ ! -d "${STABLE_REPO}" ]]; then
  fail "stable repo not found: ${STABLE_REPO} (set SOLON_STABLE_REPO env if relocated)" 3
fi

if [[ ! -d "${STABLE_REPO}/.git" ]]; then
  fail "stable repo missing .git: ${STABLE_REPO}" 3
fi

# git status clean 체크 (둘 다)
check_clean() {
  local repo="$1" label="$2"
  if [[ "${ALLOW_DIRTY}" == "1" ]]; then
    return 0
  fi
  local dirty
  dirty=$(git -C "${repo}" status --porcelain 2>/dev/null || true)
  if [[ -n "${dirty}" ]]; then
    warn "${label} repo is dirty:"
    git -C "${repo}" status --short | sed 's/^/    /' >&2
    fail "${label} not clean (use --allow-dirty to bypass)" 4
  fi
}

# DEV repo = REPO_ROOT 의 상위 (agent_architect host repo 자체)
DEV_REPO_ROOT="$(git -C "${REPO_ROOT}" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${DEV_REPO_ROOT}" ]]; then
  warn "dev repo not under git (REPO_ROOT=${REPO_ROOT}) — skipping dev-side clean check"
else
  check_clean "${DEV_REPO_ROOT}" "dev"
fi
check_clean "${STABLE_REPO}" "stable"

log "  ✅ paths ok / git clean"

# TBD final_sha 검출 (WU-31 후속 강화: 0.3.0-mvp release cut 시
# WU-24 처럼 final_sha=TBD placeholder 인 WU 가 있으면 abort).
# placeholder 패턴: `final_sha: TBD_*` 또는 `final_sha: null` 인데 status: done.
TBD_HITS=$(grep -rEn '^final_sha:[[:space:]]*(TBD_|"TBD_)' \
  "${REPO_ROOT}/sprints" 2>/dev/null || true)
if [[ -n "${TBD_HITS}" ]]; then
  warn "TBD final_sha placeholder 발견 (release blocker):"
  printf '%s\n' "${TBD_HITS}" | sed 's/^/    /' >&2
  if [[ "${APPLY}" == "1" ]]; then
    fail "TBD final_sha 잔존 — 사용자 manual commit 후 backfill 필요 (--dry-run 으로 미리 확인 OK)" 5
  else
    warn "(dry-run 이므로 진행, --apply 시는 abort)"
  fi
fi
log ""

# ── §2.2.2 Visibility filter (allowlist hard-coded) ──────────
log "[2/5] Allowlist filter (${#ALLOWLIST[@]} items + ${#BLOCKLIST[@]} blocklist)"

# allowlist 안의 각 항목이 dev staging 에 존재하는지 검증
MISSING=()
for item in "${ALLOWLIST[@]}"; do
  if [[ ! -e "${DEV_STAGING}/${item}" ]]; then
    MISSING+=("${item}")
  fi
done
if [[ ${#MISSING[@]} -gt 0 ]]; then
  warn "allowlist 항목이 dev staging 에 없음:"
  for m in "${MISSING[@]}"; do warn "    - ${m}"; done
  fail "allowlist 무결성 위반 (${#MISSING[@]} 항목 누락)" 1
fi

# blocklist 항목이 stable 에 흘러갔는지 검증 (이전 release 결함 점검)
for bad in "${BLOCKLIST[@]}"; do
  if [[ -e "${STABLE_REPO}/${bad}" ]]; then
    warn "blocklist 항목이 stable 에 존재 (이전 release 결함): ${bad}"
    if [[ "${APPLY}" == "1" ]]; then
      log "  → --apply 시 stable 에서 제거"
    fi
  fi
done
log "  ✅ allowlist verified"
log ""

# ── §2.2.3 Diff preview (dry-run 단계, 항상 수행) ─────────────
log "[3/5] Diff preview (dev → stable)"

# rsync --dry-run -avi 로 변경 파일 목록 + summary
# --delete 는 안 함 (allowlist 외 stable 파일 보호 = .gitignore / .checksums.txt 등)
RSYNC_DRYRUN_FLAGS=(-avi --dry-run --itemize-changes)
for bad in "${BLOCKLIST[@]}"; do
  RSYNC_DRYRUN_FLAGS+=(--exclude="${bad}")
done

CHANGED=0
NEW=0
DELETED=0
for item in "${ALLOWLIST[@]}"; do
  src="${DEV_STAGING}/${item}"
  dst="${STABLE_REPO}/${item}"
  if [[ -d "${src}" ]]; then
    src="${src}/"
    dst="${dst}/"
    [[ -d "${dst}" ]] || mkdir -p "${dst%/}"
  fi
  while IFS= read -r line; do
    case "${line}" in
      \>f+++++++++*) NEW=$((NEW+1));    log "  + ${line}" ;;
      \>f*)          CHANGED=$((CHANGED+1)); log "  M ${line}" ;;
      \*deleting*)   DELETED=$((DELETED+1)); log "  - ${line}" ;;
      cd+++++++++*)  log "  D ${line}" ;;  # 신규 디렉토리
      *)             [[ -n "${line}" ]] && log "    ${line}" ;;
    esac
  done < <(rsync "${RSYNC_DRYRUN_FLAGS[@]}" "${src}" "${dst}" 2>/dev/null \
            | grep -E '^(>|c|\*)' || true)
done

log ""
log "  summary: changed=${CHANGED} new=${NEW} deleted=${DELETED}"
log ""

# ── §2.2.4 Apply (--apply 시만) ───────────────────────────────
if [[ "${APPLY}" == "0" ]]; then
  log "[4/5] Apply  ⏭️  skipped (dry-run, use --apply to commit)"
  log ""
  log "[5/5] Post-flight  ⏭️  skipped"
  log ""
  log "✅ dry-run complete · 0 changes applied"
  exit 0
fi

log "[4/5] Apply (rsync + VERSION bump + CHANGELOG + git commit)"

RSYNC_APPLY_FLAGS=(-av --itemize-changes)
for bad in "${BLOCKLIST[@]}"; do
  RSYNC_APPLY_FLAGS+=(--exclude="${bad}")
done

for item in "${ALLOWLIST[@]}"; do
  src="${DEV_STAGING}/${item}"
  dst="${STABLE_REPO}/${item}"
  if [[ -d "${src}" ]]; then
    src="${src}/"
    dst="${dst}/"
    mkdir -p "${dst%/}"
  fi
  rsync "${RSYNC_APPLY_FLAGS[@]}" "${src}" "${dst}" | sed 's/^/    /'
done

# blocklist 잔존분 제거 (안전망)
for bad in "${BLOCKLIST[@]}"; do
  if [[ -e "${STABLE_REPO}/${bad}" ]]; then
    rm -f "${STABLE_REPO}/${bad}"
    log "  ✗ removed stable/${bad} (blocklist)"
  fi
done

# VERSION bump (stable)
echo "${VERSION}" > "${STABLE_REPO}/VERSION"
log "  ✓ stable/VERSION = ${VERSION}"

# CHANGELOG entry (stable) — 단순 prepend, 사용자 사후 정리 가능
TODAY=$(date -u +"%Y-%m-%d")
CHLOG="${STABLE_REPO}/CHANGELOG.md"
if [[ -f "${CHLOG}" ]]; then
  TMPFILE="$(mktemp)"
  {
    printf '## [%s] - %s\n\n' "${VERSION}" "${TODAY}"
    printf -- '- (release: cut from dev staging via cut-release.sh)\n\n'
    cat "${CHLOG}"
  } > "${TMPFILE}"
  mv "${TMPFILE}" "${CHLOG}"
  log "  ✓ stable/CHANGELOG.md prepended"
fi

# git add + commit (stable)
git -C "${STABLE_REPO}" add -A
if git -C "${STABLE_REPO}" diff --cached --quiet; then
  log "  ⚠️  stable 변경 없음 (nothing to commit)"
  STABLE_SHA=""
else
  git -C "${STABLE_REPO}" commit -m "release: ${VERSION}" >/dev/null
  STABLE_SHA=$(git -C "${STABLE_REPO}" rev-parse HEAD)
  log "  ✓ stable commit ${STABLE_SHA:0:7}"
fi

# tag (옵션)
if [[ "${NO_TAG}" == "0" && -n "${STABLE_SHA}" ]]; then
  TAG="v${VERSION}"
  if git -C "${STABLE_REPO}" rev-parse "${TAG}" >/dev/null 2>&1; then
    warn "tag ${TAG} 이미 존재 — skip"
  else
    git -C "${STABLE_REPO}" tag "${TAG}" "${STABLE_SHA}"
    log "  ✓ stable tag ${TAG}"
  fi
fi
log ""

# ── §2.2.5 Post-flight (dev-side bump) ────────────────────────
log "[5/5] Post-flight (dev VERSION/CHANGELOG bump + R-D1)"

echo "${VERSION}" > "${DEV_STAGING}/VERSION"
log "  ✓ dev/VERSION = ${VERSION}"

DEV_CHLOG="${DEV_STAGING}/CHANGELOG.md"
if [[ -f "${DEV_CHLOG}" ]]; then
  if ! grep -q "^## \[${VERSION}\]" "${DEV_CHLOG}"; then
    TMPFILE="$(mktemp)"
    {
      printf '## [%s] - %s\n\n' "${VERSION}" "${TODAY}"
      printf -- '- (release cut → stable %s)\n\n' "${STABLE_SHA:0:7}"
      cat "${DEV_CHLOG}"
    } > "${TMPFILE}"
    mv "${TMPFILE}" "${DEV_CHLOG}"
    log "  ✓ dev/CHANGELOG.md prepended"
  else
    log "  · dev/CHANGELOG.md 이미 ${VERSION} entry 존재"
  fi
fi

log ""
log "✅ apply complete"
log "    stable: ${STABLE_REPO} (commit ${STABLE_SHA:0:7}${NO_TAG:+, no tag})"
log "    dev:    ${DEV_STAGING} (VERSION/CHANGELOG bumped)"
log ""
log "⚠️  push 안 함 (§1.5 manual). 사용자 터미널에서:"
log "    cd ${STABLE_REPO} && git push origin main && git push origin --tags"
log "    cd ${DEV_REPO_ROOT:-<dev-repo>} && git add -A && \\"
log "      git commit -m 'WU-31/cut(stable): v${VERSION} ${STABLE_SHA:0:7}' && git push"
exit 0
