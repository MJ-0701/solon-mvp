---
doc_id: phase1-mvp-quick-start
title: "Phase 1 MVP W0 — 사용자 Mac 5 분 Runbook"
version: 0.1-mvp
created: 2026-04-24 (WU-18)
author: "Claude (direct 지시 by 채명정)"
scope: "PHASE1-KICKOFF-CHECKLIST §2 W0 을 사용자 Mac 에서 5 분 내 exit 하는 실행 guide. phase1-mvp-templates/ + plugin-wip-skeleton/ 에 이미 pre-render 된 산출물을 복사 + placeholder 치환만."
audience: [사용자 (채명정)]
related_docs:
  - PHASE1-KICKOFF-CHECKLIST.md (원본 체크리스트, 상세)
  - phase1-mvp-templates/README.md (템플릿 디렉토리 안내)
  - plugin-wip-skeleton/INSTALL-GUIDE.md (방법 2 선택 시)
---

# Phase 1 MVP W0 — 5 분 Runbook

> **목적**: 2026-04-27 주부터 착수할 **관리자 페이지 MVP** 의 W0 (환경 준비) 을 Mac 터미널 5 분 실행으로 exit.
> **전제**: Solon docset 이 사용자 홈 어딘가에 clone 되어 있음 (예: `~/workspace/solon-docset/` 또는 `~/agent_architect/`).
> **IP 경계**: 본 runbook 실행으로 생성되는 admin panel repo 에는 Solon 파일이 단 1 개도 유입되지 않는다 (cp 는 내용만, `phase1-mvp-templates/` 폴더 자체는 옮기지 않음).

---

## §1 결정 사항 체크 (30 초)

아래 4 가지만 결정. 결정 기록 위치는 HANDOFF-next-session.md §0 에 **N번째 지시** 형태로 사용자가 수기 추가.

- [ ] **D1. Repo ownership** — 권장 B (개인 계정 생성 → 입사 후 회사 org 로 transfer).
  - A 회사 org 계정 바로 / **B 개인 계정 → transfer (권장)** / C 개인 유지
- [ ] **D2. Repo 이름** — 예: `admin-panel-mvp`, `<회사코드>-admin`, `sales-dashboard-mvp`.
- [ ] **D3. Stack** — 권장: Next.js 15 App Router + TypeScript + Prisma + Postgres + shadcn/ui + Tailwind + Vercel.
- [ ] **D4. Solon 참조 방식** — 권장 방법 1 (홈 clone), 원하면 방법 2 (plugin-wip) 병행.

> **팁**: 결정 못 하면 권장값으로 진행해. 첫 cycle 1 회 돌려 보고 cycle 2 시작 시 조정.

---

## §2 실행 스크립트 (1 분)

> **WU-19 간소화** (2026-04-24): 원래 100줄 bash 블록을 `setup-w0.sh` 실행으로 대체.
> 내부 로직은 동일하나 OS 호환 + 에러 핸들링 + IP 경계 pre-check 추가.

### 사전: GitHub 에 private repo 생성

GitHub 에서 먼저 `<PROJECT-NAME>` private repo 생성 (README/gitignore/license 없이 빈 repo).

### 실행

```bash
# === 환경변수 3개 (본인 값으로 치환) ===
export PROJECT_NAME="admin-panel-mvp"                                  # D2 에서 결정
export SOLON_DOCSET="$HOME/workspace/solon-docset/2026-04-19-sfs-v0.4" # Solon docset 실제 경로
export WORKSPACE="$HOME/workspace"                                     # admin panel repo 를 둘 부모 디렉토리

# === optional ===
# export GITHUB_USER="MJ-0701"         # 본인 GitHub 사용자명 (기본 = whoami)
# export GIT_PROTOCOL="ssh"            # ssh (기본) 또는 https

# === 스크립트 실행 ===
"$SOLON_DOCSET/phase1-mvp-templates/setup-w0.sh"
```

스크립트가 자동으로:
1. 사전 체크 (env 누락, repo 기존 존재, git 설치)
2. Repo clone
3. Template cp (CLAUDE.md / README.md / .gitignore / .sfs-local)
4. `<PROJECT-NAME>` / `<DATE>` placeholder 자동 치환
5. 남은 placeholder (Stack 관련) 리포트 — 에디터에서 치환
6. IP 경계 pre-check (Solon 파일 유입 여부)
7. 3 initial commit 생성
8. `git push -u origin main`

**실패 시 동작**: pre-check 실패 → exit 1. push 실패 → exit 0 + 재시도 안내 (`cd <repo> && git push -u origin main`).

---

## §3 (선택) Solon 참조 방식 — 방법 2 (plugin-wip) 설정

D4 에서 방법 2 선택한 경우만. 방법 1 (홈 clone) 이면 이 섹션 skip — Claude 에게 대화에서 `SOLON_DOCSET` 경로를 알려주면 됨.

```bash
# 방법 2: ~/.claude/plugins/solon-wip/ 설치
mkdir -p ~/.claude/plugins
cp -r "$SOLON_DOCSET/plugin-wip-skeleton" ~/.claude/plugins/solon-wip
ln -s "$SOLON_DOCSET" ~/.claude/plugins/solon-wip/docs

# 검증
ls ~/.claude/plugins/solon-wip/
ls ~/.claude/plugins/solon-wip/docs/ | head -5
```

자세한 가이드: `plugin-wip-skeleton/INSTALL-GUIDE.md`.

---

## §4 첫 Claude 세션 시작 (Day 1, 2026-04-27 월)

```bash
cd "$WORKSPACE/$PROJECT_NAME"
claude
```

첫 메시지로 **`phase1-mvp-templates/PROMPT-FOR-FIRST-SESSION.md`** 내용을 복붙. Claude 가:
1. `CLAUDE.md` 읽고
2. Sprint 1 브레인스토밍 시작 (`sprint-0-brainstorm.md.template` 참고)
3. G0 verdict 받은 뒤 plan 단계로 진행

---

## §5 결정 기록을 Solon docset 으로 귀환

W0 끝나면 Solon docset 쪽 `HANDOFF-next-session.md §0` 에 새 사용자 지시로 결정 결과 기록 (N번째 추가). 예:

```
N. (YYYY-MM-DD, W0 exit): 관리자 페이지 MVP 환경 셋업 확정 — repo = `<PROJECT-NAME>`
   (ownership B → transfer), stack = Next.js 15 + TS + Prisma + Postgres + shadcn/ui + Vercel,
   Solon 참조 = 방법 1 (홈 clone) / 방법 2 병행. .sfs-local/ 스캐폴드 완료. W1 진입.
```

Solon docset 쪽 새 WU (예: WU-19) 로 기록 + commit + push.

---

## §6 W0 exit 자동 검증

> **WU-19 간소화** (2026-04-24): 체크리스트를 `verify-w0.sh` 로 자동화.

```bash
cd "$WORKSPACE/$PROJECT_NAME"
"$SOLON_DOCSET/phase1-mvp-templates/verify-w0.sh"
```

스크립트가 7 개 항목 자동 검증:
1. commit 수 ≥ 3
2. IP 경계 (`git ls-files | grep -i solon` = 빈 결과)
3. `.gitmodules` 없음 또는 Solon 항목 없음
4. `.sfs-local/` 구조 (divisions.yaml + events.jsonl + sprints + decisions)
5. root CLAUDE.md + README.md 존재
6. placeholder 잔여 리포트 (Stack 결정 전이면 WARN, 결정 후 실행 시 FAIL)
7. CLAUDE.md 에 Solon 경로 / 키워드 하드코딩 없음

출력 형식: `PASS / FAIL / WARN` 카운터 + exit code.

- exit 0 + WARN 0 = **완전 통과**, W1 진입
- exit 0 + WARN>0 = 조건부 통과 (Stack 치환 후 재검증 권장)
- exit 1 = 실패, 문제 해결 후 재실행

**수동 체크리스트 (참고용, 자동 검증 대상과 동일)**:

- [ ] admin panel repo 에 3 commit 이상
- [ ] `git ls-files | grep -i solon` → 빈 결과
- [ ] `.gitmodules` 없음
- [ ] `ls .sfs-local/` → `divisions.yaml` + `events.jsonl` + `sprints/` + `decisions/`
- [ ] `<PROJECT-NAME>` / `<DATE>` placeholder 치환 완료
- [ ] Stack 관련 placeholder 는 W1 Day 1 에 Claude 와 함께 치환 가능 (옵션)
- [ ] `CLAUDE.md` 가 Solon 경로 언급하지 않음 (IP 경계)
- [ ] GitHub 에 push 완료

모두 통과 → **W1 진입**. PHASE1-KICKOFF-CHECKLIST §3 참조.

---

## §7 알려진 리스크

| 리스크 | 해결 |
|---|---|
| GitHub 인증 실패 | `git config --global credential.helper osxkeychain` 또는 `gh auth login` |
| `sed -i ''` macOS 전용 | Linux 사용 시 `sed -i` 로 변경 |
| `.sfs-local/events.jsonl` 이 비어있어 git add 안 됨 | `.gitkeep` 파일 함께 touch |
| Stack 결정 못 함 | 권장 기본값으로 진행 (Next.js 15 + TS + Prisma + Postgres + Vercel). cycle 1 중 교체 가능. |
| placeholder 치환 누락 | `grep -rn '<[A-Z-]*>' .` 로 재검사 |

## §8 cycle 1 이후

- W1 (2026-04-29 수 ~ 05-05 화) 첫 PDCA 1 cycle 완료 후 → §5 결과 기록 → Solon docset WU-19 (회귀 피드백).
- cycle 3 누적 시점 → G5 retro 정식 도입 + 풀스펙 §10.4 재방문 검토.

끝.
