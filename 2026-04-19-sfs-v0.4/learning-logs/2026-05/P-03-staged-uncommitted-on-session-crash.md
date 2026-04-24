---
pattern_id: P-03-staged-uncommitted-on-session-crash
title: "세션이 git add 후 commit 전에 종료 → 다음 세션이 staged diff 를 인지 못 하면 유실"
status: resolved
severity: medium
first_observed: 2026-04-25
observed_by: admiring-nice-faraday (15번째 세션, scheduled auto-resume)
resolved_at: 2026-04-25
resolved_by: admiring-nice-faraday (15번째 세션, 같은 세션 안에서 즉시 처리)
resolved_via: |
  (1) staged diff 를 그대로 commit 실체화 (인수인계 원 의도 보존) +
  (2) scripts/resume-session-check.sh 신설 (다음 세션 진입 전 staged/untracked 자동 감지) +
  (3) PROGRESS.md resume_hint.default_action 에 "0. staged diff 확인" 단계 추가.
related_wu: WU-20.1
related_docs:
  - sprints/WU-20.1.md (v1.1 Changelog — 15번째 세션 auto-resume 로 실체화)
  - scripts/resume-session-check.sh (신규 — 진입 직후 staged/untracked/last_heartbeat drift 감지)
  - PROGRESS.md frontmatter resume_hint.default_action (step 0 추가)
  - CLAUDE.md §1.8 (작업 유실 최소화 — 본 패턴의 상위 규율)
  - CLAUDE.md §1.12 (Session mutex — stale TTL 감지와 연계)
visibility: raw-internal
---

# P-03 — staged-uncommitted-on-session-crash

## 현상

14번째 세션 `funny-pensive-hypatia` (2026-04-25 00:05~00:20 KST) 이 WU-20.1 refresh
작업을 수행하면서 아래 3 파일을 **git add 까지 완료**:

- `sprints/WU-20.1.md` (신규)
- `sprints/_INDEX.md` (수정)
- `PROGRESS.md` (수정 — mutex release + "last_final_commits: [TBD_WU_20_1_AMEND, TBD_PROGRESS_SNAPSHOT]" 기록)

그러나 **`git commit` 실행 전에 세션이 종료**. Cowork scheduled task 는 hourly
로 새 세션을 깨우는데, 새 세션 `admiring-nice-faraday` (15번째) 가 진입 시점에
상황은:

- `git log -1` = `6be708b` (13번째 세션 마지막 commit, 차이 없음)
- `git rev-list --count origin/main..HEAD` = 0 (pushed 기준으로 ahead 없음)
- `git status --short` = **3 파일 staged (M/A/M)** ← 유일한 유실 위험 신호
- `PROGRESS.md` 은 "mutex released" 로 써져 있어서 superficial reading 으로는 정상 종료로 보임
- `last_final_commits` 에 `TBD_` 접두사 = 실체화 대기 신호 (실수로 남겨진게 아니라 실제 미실체화)

→ 새 세션이 `git status --short` 를 확인하지 않으면 staged diff 를 **못 보고 덮어쓰기** 가능 (예: PROGRESS.md 를 새로 Write 하면 이전 세션 변경분 전부 유실).

## 근본 원인

- **§1.8 (작업 유실 최소화)** 규율은 "매 micro-step 마다 PROGRESS.md 덮어쓰기 + 필요 시 wip commit" 을 요구하지만, **commit 을 강제**하지는 않음.
- 14번째 세션은 마지막 micro-step 에서 "amend 전제로 일단 add 만 하고 commit 은 sha 취득 후" 플로우를 따랐고, 바로 그 사이 세션 termination 이 발생.
- `PROGRESS.md` 의 `last_final_commits` 필드에 `TBD_` 플레이스홀더가 있으면 "미실체화" 를 의미하지만, `resume_hint.default_action` 은 이걸 명시적으로 감지하도록 요구하지 않았음.

## 재현 경로 (요약)

1. 세션 A: WU 작업 → files 변경 → `git add` → PROGRESS.md 에 "곧 commit" 의도 기록 → **termination**
2. 세션 B: 진입 → PROGRESS.md 의 "released" 를 보고 "정상 종료" 판단 → 새 작업 시작
3. 세션 B 가 같은 파일을 Write 로 덮어쓰면 세션 A 의 staged diff 중 PROGRESS.md 부분 유실 (단, `git add` 한 버전은 staging area 에 남아 있어 `git diff --cached HEAD` 로 복구 가능)

## 해결 (15번째 세션 본 사건)

- **(1) staged diff 즉시 commit 실체화**: `git commit -m "refresh(WU-20.1): ..."` 로 14번째 세션 의도를 그대로 보존 + commit message 에 "Authored-original / Commit-realized-by" 메타 표기. 그 다음 `final_sha` backfill amend. 결과 sha `2709fcf` (pre-amend `5525668`).
- **(2) scripts/resume-session-check.sh 신설**: 세션 진입 직후 (mutex claim 직후) 자동 호출용 helper. `git status --short` 로 staged/untracked 감지 + `PROGRESS.md` frontmatter 의 `TBD_` 플레이스홀더 grep + `last_heartbeat` TTL drift 확인. 감지 시 **중단 메시지 + 복구 가이드** 를 STDOUT 으로 출력 (자동 복구는 하지 않음 — 원칙 2 준수, 의미 판단은 사용자/Claude 판단).
- **(3) PROGRESS.md resume_hint.default_action 에 step 0 추가**: "0. scripts/resume-session-check.sh 실행 → staged diff 감지 시 세션 A 의도 추정 후 commit 실체화 우선".

## 예방 checklist (다음 세션부터)

- [ ] 세션 진입 시 **§1.12 mutex 확인 직후** `git status --short` 실행. 3 상황 분기:
  - 깨끗 → 정상 진입
  - staged diff 존재 → P-03 발동 (본 패턴 참조). `git diff --cached HEAD` 로 의도 파악 후 commit 실체화 or reset.
  - untracked 중요 파일 (PROGRESS/\*.md, WU-\*.md) 존재 → 유실 방지 위해 먼저 확인.
- [ ] PROGRESS.md `last_final_commits` 에 `TBD_*` 존재 시 "실체화 대기 중" 으로 해석. superficial "released" 표시를 믿지 말 것.
- [ ] commit → amend → PROGRESS update 3-step 은 **atomic block** 로 처리. 중간에 중단되면 다음 세션이 확실히 이어받을 수 있도록 intent 주석을 commit message draft 로 기록 (`.git/COMMIT_EDITMSG` 는 휘발성이라 별도 `tmp/next-commit-intent.md` 권장).

## 자동화 (후속)

- **scripts/resume-session-check.sh** (본 세션 신설, v0.1) — 감지만.
- **scripts/resume-session-recover.sh** (후속 예약, 0.4.0-mvp 같이) — 패턴 확인 후 자동 commit 실체화까지. **원칙 2 위반 가능성 있어 사용자 승인 플래그 필수** (`--apply` 없으면 dry-run only).
- **PROGRESS.md resume_hint.default_action step 0 의 실행**: 15번째 세션 이후 모든 세션이 default 로 수행.

## 왜 P-02 와 다른가

- **P-02** = dev/stable **repo 간** divergence (공간적).
- **P-03** = 같은 repo 안에서 **세션 간** staged diff 유실 위험 (시간적). Cowork scheduled task hourly 재기동이 이 패턴의 빈도를 증가시킴 → auto-resume 프로토콜에 **필수 편입**.

## Changelog

- v1.0 (2026-04-25, admiring-nice-faraday 15번째 세션): 신규 실체화.
