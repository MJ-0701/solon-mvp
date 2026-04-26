#!/usr/bin/env bash
# verify-install.sh — Solon MVP install.sh 산출물 검증 (사용자 Mac 실행, 현 디렉토리 = consumer repo 루트)
# 출처: Solon docset WU-30 §2 (2026-04-26, fork of verify-w0.sh)
# 대응: WU-21 §F-04(a) + WU22-D9 (b) 두 검증기 분리 결정
# 실행: cd <consumer-repo>/ && bash verify-install.sh   (또는 절대경로)
#
# 적용 대상: solon-mvp install.sh 산출물 전용
#            (SFS.md / CLAUDE.md / AGENTS.md / GEMINI.md 어댑터
#             + .claude/commands/sfs.md
#             + .sfs-local/ 스캐폴드 (scripts + sprint-templates 포함)
#             + .gitignore solon-mvp marker block).
#            setup-w0.sh 산출물은 본 검증기 사용 금지 — verify-w0.sh 사용 (WU-30 §1).
#            근거: install.sh 는 banner / 어댑터 안에 'Solon' 키워드를 의도적으로 출력하므로,
#                  verify-w0.sh check #2 / #7 (Solon 키워드 차단) 을 그대로 적용하면 false-positive.
#                  WU22-D9 (b) 결정 = 두 검증기 분리.

set -euo pipefail

# === pass/fail counter ===
PASS=0
FAIL=0
WARN=0

ok()   { echo "  ✅ $1"; PASS=$((PASS+1)); }
fail() { echo "  ❌ $1"; FAIL=$((FAIL+1)); }
warn() { echo "  ⚠  $1"; WARN=$((WARN+1)); }

echo "=== install.sh 산출물 검증 ==="
echo ""

# 0) 현 디렉토리 = consumer repo 루트 (git 권장, 필수 아님 — install.sh 와 정합)
if git rev-parse --git-dir >/dev/null 2>&1; then
  REPO_ROOT=$(git rev-parse --show-toplevel)
  echo "repo: $REPO_ROOT (git)"
else
  REPO_ROOT="$(pwd)"
  echo "repo: $REPO_ROOT (no git — install.sh pre-flight 에서 warn 발생했어야 함)"
fi
echo ""

# === 1) 어댑터 파일 4종 (SFS / CLAUDE / AGENTS / GEMINI) ===
# 근거: install.sh §6.1 — 4 어댑터 파일을 templates/<X>.md.template 에서 cp.
echo "1) 어댑터 파일 (SFS.md / CLAUDE.md / AGENTS.md / GEMINI.md)"
ADAPTER_FILES=(SFS.md CLAUDE.md AGENTS.md GEMINI.md)
for f in "${ADAPTER_FILES[@]}"; do
  [ -f "$f" ] && ok "$f 존재" || fail "$f 없음"
done

# === 2) Claude Code slash command adapter ===
# 근거: install.sh §6.2 — .claude/commands/sfs.md 설치 (WU-24 adapter dispatch).
echo ""
echo "2) Claude Code /sfs 커맨드 어댑터"
[ -f .claude/commands/sfs.md ] && ok ".claude/commands/sfs.md 존재" || fail ".claude/commands/sfs.md 없음"

# === 3) .gitmodules — Solon submodule 누출 검사 ===
# 근거: install.sh 는 submodule 안 쓰지만, 사용자 환경에서 의도치 않게 들어가면 IP 경계 위반.
echo ""
echo "3) .gitmodules"
if [ -f .gitmodules ]; then
  if grep -iq solon .gitmodules; then
    fail ".gitmodules 에 Solon submodule 존재 — install.sh 는 submodule 사용 안 함"
  else
    warn ".gitmodules 파일 존재 (Solon 항목은 없음) — 의도적이면 OK"
  fi
else
  ok ".gitmodules 없음"
fi

# === 4) .sfs-local/ 구조 ===
# 근거: install.sh §7 — .sfs-local/ 스캐폴드 (merge 모드).
#       scripts/ + sprint-templates/ 는 WU-24 row 5~8 에서 신설된 항목.
echo ""
echo "4) .sfs-local/ 구조"
[ -d .sfs-local ] && ok ".sfs-local/ 디렉토리 존재" || fail ".sfs-local/ 디렉토리 없음"
[ -f .sfs-local/divisions.yaml ] && ok ".sfs-local/divisions.yaml 존재" || fail ".sfs-local/divisions.yaml 없음"
[ -f .sfs-local/events.jsonl ] && ok ".sfs-local/events.jsonl 존재" || fail ".sfs-local/events.jsonl 없음"
[ -d .sfs-local/sprints ] && ok ".sfs-local/sprints/ 존재" || fail ".sfs-local/sprints/ 없음"
[ -d .sfs-local/decisions ] && ok ".sfs-local/decisions/ 존재" || fail ".sfs-local/decisions/ 없음"
# scripts/ 3종 (WU-24 row 5/6/7)
[ -d .sfs-local/scripts ] && ok ".sfs-local/scripts/ 존재" || fail ".sfs-local/scripts/ 없음"
for s in sfs-common.sh sfs-status.sh sfs-start.sh; do
  [ -f ".sfs-local/scripts/$s" ] && ok ".sfs-local/scripts/$s 존재" || fail ".sfs-local/scripts/$s 없음"
done
# sprint-templates 4종 (WU-24 row 8)
[ -d .sfs-local/sprint-templates ] && ok ".sfs-local/sprint-templates/ 존재" || fail ".sfs-local/sprint-templates/ 없음"
for t in plan.md log.md review.md retro.md; do
  [ -f ".sfs-local/sprint-templates/$t" ] && ok ".sfs-local/sprint-templates/$t 존재" || fail ".sfs-local/sprint-templates/$t 없음"
done

# === 5) .gitignore solon-mvp marker block ===
# 근거: install.sh §8 — idempotent marker-based 주입.
echo ""
echo "5) .gitignore solon-mvp marker block"
if [ -f .gitignore ]; then
  if grep -qF "### BEGIN solon-mvp ###" .gitignore && grep -qF "### END solon-mvp ###" .gitignore; then
    ok ".gitignore solon-mvp BEGIN/END marker 모두 존재"
  else
    fail ".gitignore solon-mvp marker 누락 (install.sh §8 미적용)"
  fi
else
  fail ".gitignore 없음 — install.sh 가 touch + 주입했어야 함"
fi

# === 6) placeholder 잔여 (Stack 결정 전이면 WARN, 결정 후이면 FAIL) ===
# 정규식: WU22-D9 (i) minimal — `<[A-Z]{2,}[A-Z0-9_-]*>` (2자 이상 placeholder, 1자 설명 마커 회피).
# 검증 대상: 어댑터 파일 4종 (install.sh §6.3 자동 치환 후 잔여 = 사용자 수동 치환 대상).
#   - <DATE> / <SOLON-VERSION> = install.sh 가 자동 치환 (잔여 시 FAIL 신호)
#   - <PROJECT-NAME> / <STACK> / <DB> / <DEPLOY> / <DOMAIN> = 사용자 수동 치환 (잔여 시 WARN)
echo ""
echo "6) placeholder 잔여 (Stack 결정 전이면 WARN, 결정 후이면 FAIL)"
PLACEHOLDER_FILES=(SFS.md CLAUDE.md AGENTS.md GEMINI.md)
PLACEHOLDER_HITS=0
for f in "${PLACEHOLDER_FILES[@]}"; do
  [ -f "$f" ] || continue
  if grep -nE '<[A-Z]{2,}[A-Z0-9_-]*>' "$f" >/dev/null; then
    PLACEHOLDER_HITS=$((PLACEHOLDER_HITS+1))
    warn "$f 에 placeholder 잔여:"
    grep -nE '<[A-Z]{2,}[A-Z0-9_-]*>' "$f" | sed 's/^/     /'
  fi
done
[ $PLACEHOLDER_HITS -eq 0 ] && ok "placeholder 전부 치환됨"

# === 7) install.sh 자동 치환 검증 (<DATE> / <SOLON-VERSION>) ===
# 근거: install.sh §6.3 — 4 어댑터 파일에 대해 <DATE> / <SOLON-VERSION> sed 치환.
#       잔여 시 = install.sh 자동 치환 단계가 실패했거나, 어댑터 template 갱신 누락.
# verify-w0.sh check #7 (Solon 키워드 차단) 는 본 검증기에서 수행 안 함 —
# install.sh 의도적 'Solon' 출력은 false-positive (WU-21 §F-04(a) / WU22-D9 (b)).
echo ""
echo "7) install.sh 자동 치환 (<DATE> / <SOLON-VERSION>) 잔여 검사"
AUTO_HITS=0
for f in "${ADAPTER_FILES[@]}"; do
  [ -f "$f" ] || continue
  if grep -nE '<DATE>|<SOLON-VERSION>' "$f" >/dev/null; then
    AUTO_HITS=$((AUTO_HITS+1))
    fail "$f 에 자동 치환 placeholder 잔여 — install.sh §6.3 sed 실패 가능"
    grep -nE '<DATE>|<SOLON-VERSION>' "$f" | sed 's/^/     /'
  fi
done
[ $AUTO_HITS -eq 0 ] && ok "<DATE> / <SOLON-VERSION> 모두 치환됨"

# === 요약 ===
echo ""
echo "=== 결과 ==="
echo "  PASS: $PASS"
echo "  FAIL: $FAIL"
echo "  WARN: $WARN"
echo ""

if [ $FAIL -eq 0 ]; then
  if [ $WARN -eq 0 ]; then
    echo "✅ install.sh 산출물 검증 — 완전 통과. 사용자 수동 치환 항목 0건."
    exit 0
  else
    echo "⚠  install.sh 산출물 검증 — 조건부 통과 ($WARN WARN). 사용자 수동 치환 (PROJECT-NAME/STACK/DB/DEPLOY/DOMAIN 등) 후 재검증 권장."
    exit 0
  fi
else
  echo "❌ install.sh 산출물 검증 실패 ($FAIL FAIL). 문제 해결 후 재실행."
  exit 1
fi
