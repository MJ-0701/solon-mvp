---
description: "Solon MVP 7-step flow 명령. subcommand: status / brainstorm / plan / review / retro / decision"
argument-hint: "<subcommand> [arguments...]"
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
---

# /sfs — Solon MVP 7-step flow command

`solon-mvp` (https://github.com/MJ-0701/solon-mvp) 의 `/sfs` slash command. 본 repo
의 `.sfs-local/` 산출물을 조작한다. 플로우 본문은 `SFS.md`, Claude 특화 hint 는
`CLAUDE.md` 참조.

## 인자

$ARGUMENTS

## 동작 (subcommand 별)

### `/sfs status`

- `.sfs-local/sprints/` 의 최신 디렉토리 (`YYYY-W??-sprint-N`) 탐색.
- 해당 sprint 의 `brainstorm.md` / `plan.md` / `review.md` / `retro-light.md` 존재 여부
  + 각 파일의 frontmatter 요약 제시.
- `.sfs-local/events.jsonl` 마지막 10 이벤트 tail.
- 현재 어느 step 에 있는지 (G0 / G1 / G2 / G4) 추론하고 다음 step 제안.
- 의미 결정이 필요한 지점이 있으면 ⚠️ 표기 후 사용자에게 1-line 질문.

### `/sfs brainstorm [topic]`

- 새 sprint 디렉토리 필요 시 `.sfs-local/sprints/<YYYY-W??>-sprint-<N+1>/` 생성.
- `brainstorm.md` skeleton 작성 (topic + 4~6 탐색 질문 + 후보 안 3개 이상).
- G0 verdict 는 사용자 승인 후 `events.jsonl` append.

### `/sfs plan`

- 최신 sprint 디렉토리에 `plan.md` skeleton 작성.
- 포함: metadata (sprint-id / window / divisions active / G1 verdict 공란) + scope +
  non-goals + risks + cycle success conditions + rollback plan.
- brainstorm.md 가 없으면 먼저 brainstorm 요청.

### `/sfs review`

- 최신 sprint 의 commit 범위 (`git log` 사용) 수집.
- `review.md` skeleton 작성: 구현 요약 / 기능별 verdict / G4 pass/fail / 남은 TODO.
- commit sha 리스트 frontmatter 에 자동 기록.

### `/sfs retro [--with-divisions-review]`

- `retro-light.md` 작성: 이번 cycle 의 works/doesn't-work/keep/change/learn 5 축.
- `--with-divisions-review` 옵션 시 `divisions.yaml` 각 본부 activation 재검토 + 승격
  후보 `.sfs-local/decisions/` mini-ADR 제안.

### `/sfs decision <title>`

- `.sfs-local/decisions/` 안의 기존 번호 확인 → `<N+1>-<kebab-case-title>.md` 생성.
- skeleton: context / options / decision / consequences (각 1~3줄).
- 본문은 사용자가 채우고, agent 는 제출 후 `events.jsonl` 에 `decision_added` 이벤트 append.

## 공통 규칙

- 모든 산출물은 `.sfs-local/` 하위에만 쓴다. 프로젝트 소스 / git 자동 수정 금지.
- `events.jsonl` append 는 각 step 의 verdict 확정 시 1 라인 JSON (`{ts, gate, verdict,
  sprint, note}`).
- `git push` 는 절대 자동 실행하지 않는다 (SFS.md §절대 금지).
- 의미 결정 (scope trade-off, priority pick) 은 1-line 질문으로 사용자에게 위임.

## 힌트

- 인자가 없으면 `status` 로 fallback.
- subcommand 오타 시 가장 가까운 이름 제안 (fuzzy).
- 최초 실행 시 `.sfs-local/` 이 없으면 `solon-mvp/install.sh` 실행 권고 (본 command 는
  스캐폴드 생성은 하지 않음 — 책임 분리).
