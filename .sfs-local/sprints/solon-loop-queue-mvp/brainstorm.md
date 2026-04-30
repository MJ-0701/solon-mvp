---
phase: brainstorm
gate_id: G0
sprint_id: "solon-loop-queue-mvp"
goal: "Solon loop queue MVP: file-backed queue for /sfs loop"
created_at: "2026-04-30T23:18:27+09:00"
last_touched_at: 2026-04-30T23:18:40+09:00
status: ready-for-plan        # draft | ready-for-plan | g0-reviewed
---

# Brainstorm — Solon Loop Queue MVP

> Sprint **G0 — Brainstorm Gate** 산출물.
> 목적은 사용자의 raw 요구사항을 바로 plan 으로 굳히지 않고, 문제/대안/제약/범위를 먼저 정리하는 것.
> `/sfs start` 는 workspace 를 만들고, `/sfs brainstorm` 은 raw 를 §8 에 기록한 뒤
> AI runtime 에서 Solon CEO 가 §1~§7 을 채운다. direct bash 는 capture-only 다.

---

## §1. Raw Brief / Conversation Notes

사용자는 `/sfs loop` 고도화를 위해 queue 기반 구현을 승인했다. 현재 loop 는 `PROGRESS.md`
frontmatter 의 `domain_locks` 를 sweep 해서 작업을 집어간다. 이 방식은 prototype 으로는
충분하지만, 작업 등록 / retry / dependency / multi-worker / dashboard 확장을 위해서는 명시적
queue 가 필요하다.

핵심 결정: **queue-first + domain_locks fallback**. 즉 `/sfs loop` 는 먼저 `.sfs-local/queue`
의 pending task 를 claim 하고, queue 가 비어 있으면 기존 domain_locks sweep 으로 fallback 한다.

---

## §2. Problem Space

- 누가 이 문제를 겪는가:
  - `/sfs loop` 를 반복 작업 runner 로 쓰려는 사용자.
  - multi-worker / scheduled loop / 자율 작업을 안전하게 등록하고 싶은 agent runtime.
- 왜 지금 풀어야 하는가:
  - 현재 문서/정합성 작업처럼 loop 에 태울 수 있는 작은 작업이 생겼지만, 등록 단위가 없다.
  - domain_locks 는 큰 도메인 진행상태에는 맞지만, 개별 task backlog 로는 무겁다.
- 기존 방식의 불편함:
  - task 등록/claim/done/fail lifecycle 이 없다.
  - priority/retry/files_scope/verify 를 task 단위로 저장하기 어렵다.
  - multi-worker 가 같은 작업을 집지 않도록 하는 primitive 가 약하다.
- 성공하면 어떤 상태가 되는가:
  - `.sfs-local/queue/{pending,claimed,done,failed,abandoned}` 로 file-backed task queue 가 생긴다.
  - `/sfs loop enqueue`, `/sfs loop queue`, `/sfs loop claim` 이 동작한다.
  - 기본 `/sfs loop --dry-run` 이 queue-first 로 pending task 를 인식한다.

## §3. Constraints / Context

- 기술 제약:
  - bash 3.2 호환이 필요하다.
  - DB 없이 file-backed 로 구현한다.
  - product dist template 과 현재 active `.sfs-local` runtime 양쪽에 반영한다.
- 배포/운영 제약:
  - queue 는 실행 대기열이지 product scope SSoT 가 아니다. 의미/scope 는 plan/decision 이 SSoT 다.
  - git push/commit 은 사용자 manual.
- 시간/비용 제약:
  - MVP 는 enqueue/queue/claim + loop queue-first dry-run 수준으로 닫는다.
- 사용자 역량/학습 맥락:
  - future loop 고도화를 위한 기반 작업이므로 확장 가능한 이름/디렉토리/schema 가 중요하다.
- 아직 모르는 것:
  - 실제 live executor 로 queue body 를 어떻게 prompt 화할지는 다음 단계.

## §4. Options

최소 2개 이상. "아무것도 안 한다" 도 유효한 옵션이다.

- **Option A: domain_locks 유지**
  - 장점: 변경 없음.
  - 단점: 등록 가능한 task queue 가 없어 loop 고도화가 막힌다.
  - 버릴/보류할 이유: 사용자 의도와 반대.
- **Option B: file-backed queue MVP**
  - 장점: bash 만으로 구현 가능, atomic `mv` claim 가능, product install 에 부담이 작다.
  - 단점: dependency/locking 고도화는 다음 단계로 남는다.
  - 채택 이유: 현재 확장성 대비 구현비가 가장 좋다.
- **Option C: SQLite/DB queue**
  - 장점: query/locking/retry 관리가 강하다.
  - 단점: 설치 복잡도와 cross-platform 부담이 커진다.
  - 버릴/보류할 이유: Solon local-first MVP 에 과하다.

## §5. Scope Seed

- 이번 sprint 에 넣을 것:
  - queue directory scaffold.
  - task markdown frontmatter schema.
  - `/sfs loop enqueue <title>` command.
  - `/sfs loop queue` status command.
  - `/sfs loop claim` command.
  - default `/sfs loop` queue-first selection + domain_locks fallback.
- 이번 sprint 에서 뺄 것:
  - full executor prompt generation from queue body.
  - dependency graph.
  - retry auto-requeue.
  - dashboard/UI.
- 다음 sprint 후보:
  - queue task execution prompt.
  - `complete/fail/retry` subcommands.
  - verify command runner.
  - dependency and files_scope collision guard.

## §6. Plan Seed

`/sfs plan` 으로 넘길 때 필요한 최소 재료.

- Goal:
  - `/sfs loop` 에 file-backed queue MVP 를 붙여 task 등록/조회/claim 과 queue-first loop pick 을 가능하게 한다.
- Acceptance Criteria 후보:
  - AC1: `.sfs-local/queue/{pending,claimed,done,failed,abandoned}` 구조가 생성된다.
  - AC2: `/sfs loop enqueue "title"` 이 pending task markdown 을 만든다.
  - AC3: `/sfs loop queue` 가 pending/claimed/done/failed/abandoned count 를 출력한다.
  - AC4: `/sfs loop claim --owner test-owner` 가 pending task 를 claimed/test-owner 로 이동한다.
  - AC5: `/sfs loop --dry-run` 이 pending task 를 domain_locks 보다 먼저 pick 한다.
- 주요 risk:
  - queue 를 scope SSoT 처럼 쓰는 혼동.
  - active `.sfs-local` 과 product dist template divergence.
  - bash portability.
- generator agent 가 만들 산출물:
  - `sfs-loop.sh` queue helpers/subcommands.
  - queue scaffold `.gitkeep`.
  - log/plan update.
- evaluator agent 가 검증할 기준:
  - bash syntax.
  - sandbox enqueue/queue/claim/dry-run smoke.
  - active runtime과 dist template sync.

## §7. G0 Checklist

- [x] raw brief / 대화 메모가 남아 있다
- [x] 문제와 성공 상태가 한 줄로 설명된다
- [x] 대안 2개 이상을 비교했다
- [x] in/out scope seed 가 있다
- [x] generator/evaluator 계약에 넘길 재료가 있다

> checklist 가 대체로 채워지면 `/sfs plan` 으로 이동한다.

## §8. Append Log

`/sfs brainstorm <text>` 또는 `/sfs brainstorm --stdin` 입력이 append 되는 영역.

### 2026-04-30T23:18:40+09:00 — raw input

```text
Implement a queue MVP for /sfs loop. User approved queue direction because loop high-level evolution needs queue for extensibility and advanced scheduling. Current loop only sweeps PROGRESS.md domain_locks. Proposed design: queue-first + domain_locks fallback. File-backed queue under .sfs-local/queue/{pending,claimed,done,failed,abandoned}. Task as markdown with YAML frontmatter: task_id, title, status, priority, mode, sprint_id, files_scope, verify, max_attempts, attempts, created_at. Claim by atomic mv pending/task.md to claimed/<owner>/task.md. New commands: /sfs loop queue, /sfs loop enqueue <title>, /sfs loop claim, plus queue-first run path in /sfs loop. MVP should avoid DB, avoid full scheduler, avoid semantic decisions, and remain bash 3.2 compatible. Implement in product dist template and active .sfs-local runtime for dogfooding. Keep domain_locks fallback.
```
