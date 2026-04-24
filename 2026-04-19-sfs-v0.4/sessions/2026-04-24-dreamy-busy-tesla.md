---
doc_id: session-2026-04-24-dreamy-busy-tesla
session_codename: dreamy-busy-tesla
date: 2026-04-24
session_blocks: [11]
visibility: raw-internal
reconstructed_in: null   # 실시간 작성 (세션 종료 전 mutex release 포함)
reconstruction_limits: |
  [재구성 한계 없음]
  - 본 파일은 세션 진행 중 실시간 작성. transcript 는 PROGRESS.md / sprints/WU-20.md /
    learning-logs/2026-05/P-02-dev-stable-divergence.md / HANDOFF-next-session.md §0 #16~#17
    cross-reference 로 재확인 가능.
---

# Session · 2026-04-24 · dreamy-busy-tesla (11번째 세션)

> **역할**: 10번째 세션 (`amazing-happy-hawking`) WU-20 Phase A 완료 + 사용자 Codex
> 정정 (`40dcc2e`) 이후 재진입. **Phase A 보강 (v0.2.0-mvp)** → 사용자 git log
> 확인으로 **stable repo 선행 진화 발견 (0.1.1~0.2.4-mvp, 6 commits)** → **역전
> 상태 해소를 위한 Reverse Back-port** → 14 파일 stable→staging 완전 동기화 +
> **P-02 learning pattern** 실체화. 사용자 지시 17번째 ("mvp=배포/solon=개발")
> 로 dev SSoT 방향 재확정.

---

## 1. Squashed WU 목록

| WU | final_sha | title | 비고 |
|:---|:---|:---|:---|
| WU-20 Phase A 보강 | (이어서) | SFS core + 3 adapter + `/sfs` slash command (v0.2.0-mvp staging) | 14 파일 작성/재작성. 그러나 stable 과 구조 divergence 발견 |
| WU-20 Back-port | [사용자 터미널 push sha, TBD] | stable (v0.2.4-mvp, `ac98497`) → dev staging reverse reconcile | 14 파일 stable→staging full sync (checksum match) + P-02 learning log + WU-20.md v0.3 Changelog |

**세션 기여**: 실제 git commit 은 단일 back-port 커밋 (사용자 터미널에서 작성). 본 세션
내부는 dev staging 파일 조작 + sprint doc + learning log + PROGRESS/HANDOFF/BRIEFING
갱신.

**세션 ahead 흐름**: 진입 시 ahead 0 → back-port commit 1회 + session release
housekeeping 1회 = 예상 ahead 2. 사용자 push 완료 선언.

## 2. 대화 요약

### 2.1 세션 진입 + Codex 정정 파악

- **세션 진입**: 사용자 "codex에서 추가작업한것들이 좀 있는데 내용 파악좀 할래?"
  → PROGRESS.md frontmatter `resume_hint` 확인 + mutex `amazing-happy-hawking`
  이 잔존 상태 (10번째 세션이 명시적 release 안하고 종료). 본 세션 codename
  `dreamy-busy-tesla` 로 mutex re-claim.
- **Codex 커밋 `40dcc2e` 분석**: `RUNTIME-ABSTRACTION.md` v0.1-mvp →
  v0.2-mvp-correction. `rule/phase1-runtime-scope` (Claude 단일) → `rule/mvp-runtime-neutral-core`
  (MVP 부터 CLAUDE/AGENTS/GEMINI 3 adapter 필수). `sprints/WU-20.md` "명시적
  제외" 섹션에도 "`SFS.md` core + `CLAUDE.md`/`AGENTS.md`/`GEMINI.md` 경량
  adapter 는 MVP 범위였어야 함" 추가.
- **Gap 발견 보고**: 10번째 세션 `solon-mvp-dist/` staging 은 CLAUDE.md 단독 →
  3 adapter 누락. A/B/C 메뉴 제시.

### 2.2 사용자 "A ㄱㄱ" → WU-20 Phase A 보강

- **scope**: SFS.md.template 신설 (runtime-agnostic core) + CLAUDE.md.template 재작성
  (thin adapter, SFS 위임) + AGENTS.md.template / GEMINI.md.template 신설 +
  `.claude-template/commands/sfs.md` 신설 (slash command subcommand 6종) +
  install.sh / upgrade.sh / uninstall.sh 확장 (5 파일 대칭).
- **출력**: VERSION 0.1.0-mvp → 0.2.0-mvp + CHANGELOG `[0.2.0-mvp]` entry 추가 +
  README 3 runtime 진입 예시 + WU-20.md "Phase A 보강" 섹션 + v0.2 Changelog.
  `bash -n` 3 스크립트 OK. 14 파일 cross-ref 일관성 확인.
- **사용자 lock 이슈**: Cowork 샌드박스 git status 시 `.git/index.lock` 생성되고
  해제 실패 → 사용자 터미널에서 `rm -f .git/index.lock` 수행 후 commit + push.

### 2.3 사용자 `git log --oneline -5` → divergence 발견

- **상황**: 사용자 push 직후 git log 결과 공유:
  ```
  ac98497 fix: honor upgrade prompt defaults
  a48b7fd feat: automate checksum-based upgrades
  41e15ed feat: add checksum-based upgrade preview
  8134a2c feat: add runtime-neutral SFS adapters
  e9cf47a docs: improve /sfs autocomplete help
  ```
  → solon-mvp stable 에 이미 0.1.1 ~ 0.2.4-mvp 6 커밋 merge+push 된 상태 확인.
  8134a2c 는 내 방금 작업 (3 adapter) 과 동일 목적. 41e15ed/a48b7fd 는 내가
  CHANGELOG Unreleased 에 `0.3.0-mvp` 로 예약했던 checksum 기능이 이미 구현됨.
- **방향 불명 → 사용자 확인**: (A) stable SSoT / (B) 양방향 reconcile /
  (C) staging mirror 3 옵션 제시.
- **사용자 답변 17**: "ㄴㄴㄴ mvp는 배포버전이고 solon이 개발버전이어야 함
  solon-mvp가 한마디로 stable 버전이어야 함" → **dev SSoT 방향 재확정**. 즉
  stable 선행 진화 = 규율 위반. 역전 해소 필요.

### 2.4 Reverse Back-port 실행

- **workspace 연결 확인**: `~/workspace/solon-mvp` 가 이미 Cowork workspace 로
  mount 된 상태 (`/sessions/dreamy-busy-tesla/mnt/solon-mvp/`). 5 commit + 기타
  파일 (v0.1.1 `786900a`, `e827775`) 전체 스캔 → stable 전체 구조 파악 완료.
- **주요 차이점**:
  - Directory: staging `.claude-template/` vs stable `.claude/` — 후자가 직관적
  - install.sh: stable 에 `--yes` flag + stderr prompt + `.claude/` 경로
  - upgrade.sh: stable 에 checksum 기반 자동 정책 + placeholder 치환 + TTY 감지 개선
  - templates/adapter 들: stable 이 영문 thin (~22줄) vs staging 한국어 장황
  - SFS.md.template: stable 이 더 간결 + "런타임별 시작법" 섹션
- **동기화 (cp 로 stable → staging full copy)**: 14 파일 전부 checksum 일치.
  `bash -n` 재검증 OK.
- **FUSE 권한 한계**: bash `rm` 이 staging `.claude-template/commands/sfs.md`
  삭제 실패 ("Operation not permitted"). 사용자 터미널에서 `git rm -rf` 로 수동
  처리 위임 (never-hard-block + 사용자 결정 우선).

### 2.5 Learning pattern P-02 실체화

- **P-02 `dev-stable-divergence`** (`learning-logs/2026-05/P-02-...md`):
  - 현상 / 원인 4건 (staging 배포 접근성 / 규율 부재 / 검증 피드백 루프 / Cowork
    샌드박스 제약) / 2026-04-24 reconcile 결과 / R-D1 규율 제안 + hotfix 예외
    절차 / 자동화 idea (scripts/sync-stable-to-dev.sh + cut-release.sh) / 후속
    TODO 4건.
- **R-D1 초안**: "배포 artifact 수정은 dev 에서 먼저. stable hotfix 는 같은 세션
  안에 즉시 staging 으로 back-port 커밋 생성 (24시간 내가 아니라 즉시)."
  정식 채택은 사용자 승인 후 (원칙 2 preserve).

### 2.6 인수인계 (본 세션 종료)

- PROGRESS.md mutex release.
- HANDOFF §0 #17 추가.
- NEXT-SESSION-BRIEFING.md 갱신.
- 본 retrospective 작성 + sessions/_INDEX.md 11번째 행 추가.

## 3. 산출물

### 3.1 신규 파일 (2)

- `learning-logs/2026-05/P-02-dev-stable-divergence.md`
- `sessions/2026-04-24-dreamy-busy-tesla.md` (본 파일)

### 3.2 수정 파일 (주요, reverse back-port 포함 시 15+)

- `solon-mvp-dist/VERSION` — 0.1.0-mvp → 0.2.4-mvp (stable 동기화)
- `solon-mvp-dist/CHANGELOG.md` — 6 entry 로 확장
- `solon-mvp-dist/README.md` — 런타임별 사용법 + `/sfs` 사용법 섹션
- `solon-mvp-dist/install.sh` — `--yes` / stderr prompt / `.claude/` 경로
- `solon-mvp-dist/upgrade.sh` — checksum 기반 자동 정책 + placeholder 치환
- `solon-mvp-dist/uninstall.sh` — SFS/CLAUDE/AGENTS/GEMINI/sfs.md 5 파일 loop
- `solon-mvp-dist/APPLY-INSTRUCTIONS.md` — historical 표시 (이미 apply 완료)
- `solon-mvp-dist/templates/SFS.md.template` — 간결 축소
- `solon-mvp-dist/templates/CLAUDE.md.template` — 영문 thin adapter (22줄)
- `solon-mvp-dist/templates/AGENTS.md.template` — 영문 thin adapter (22줄)
- `solon-mvp-dist/templates/GEMINI.md.template` — 영문 thin adapter (22줄)
- `solon-mvp-dist/templates/.claude/commands/sfs.md` — `name:` frontmatter + description 다중줄
- `sprints/WU-20.md` — "Phase A Back-port" 섹션 + v0.3 Changelog
- `PROGRESS.md` — ⓪~④ 전면 재작성 (세션 진입/보강/Back-port/인수인계 흐름)
- `sessions/_INDEX.md` — 11번째 행

### 3.3 Deprecated (사용자 git rm 대기)

- `solon-mvp-dist/templates/.claude-template/` — bash FUSE lock 으로 agent 제거 불가.
  사용자 터미널에서 `git rm -rf` 필요.

## 4. Decisions / Learnings

### 4.1 사용자 지시 17 (dev=개발, stable=배포)

- verbatim: "ㄴㄴㄴ mvp는 배포버전이고 solon이 개발버전이어야 함 solon-mvp가 한마디로 stable 버전이어야 함"
- 함의: dev (Solon docset `solon-mvp-dist/`) 이 SSoT. stable (solon-mvp GitHub) 은
  cut 된 release 만 받음. 본 세션의 reverse back-port 는 **1회성 divergence
  해소**. 향후 Codex/Gemini CLI 작업도 dev 먼저 → stable cut 순서 엄수.

### 4.2 P-02 / R-D1 기대 효과

- 동일 divergence 재발 시 감지 비용 하락 (checksum diff + 커밋 메시지 prefix).
- hotfix 경로가 규정되므로 "당장 stable 고치고 싶다" 충동에도 back-port 의무화.
- 자동화 script (후속) 로 사용자 인지 부하 0.

### 4.3 FUSE 샌드박스 운영 제약

- bash `rm` 이 특정 파일에 대해 "Operation not permitted" 반환하는 경우 존재.
  cp / Write 는 되는데 삭제만 안 되는 패턴. 사용자 터미널로 위임이 안전한 우회책.
- `.git/index.lock` 생성 후 해제 실패 → 사용자 `rm -f` 필요. 앞으로 내가
  `git status` / `git diff` 실행 시 `--no-optional-locks` 플래그 선제 적용 검토.

## 5. 참고

- **CLAUDE.md v1.16** (Solon docset 루트): 규율 12 + §1.12 mutex protocol
- **RUNTIME-ABSTRACTION.md v0.2-mvp-correction**: `rule/mvp-runtime-neutral-core`
- **sprints/WU-20.md v0.3**: Phase A + Phase A 보강 + Phase A Back-port 3 단계
- **learning-logs/2026-05/P-01-solon-mvp-scope-pivot.md**: 10번째 세션 learning
- **learning-logs/2026-05/P-02-dev-stable-divergence.md**: 본 세션 learning

## 6. 다음 세션 권장 진입 경로

`PROGRESS.md` §④ 메뉴 참조. default = (a) R-D1 규율 정식 채택 + P-02 resolved 스탬핑.
