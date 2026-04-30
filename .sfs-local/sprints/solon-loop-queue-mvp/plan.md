---
phase: plan
gate_id: G1
sprint_id: "solon-loop-queue-mvp"
goal: "Solon loop queue MVP: file-backed queue for /sfs loop"
created_at: "2026-04-30T23:18:27+09:00"
last_touched_at: 2026-04-30T23:18:43+09:00
---

# Plan — Solon Loop Queue MVP

> Sprint **G1 — Plan Gate** 산출물. 본 문서의 목적은 **요구사항·AC 의 측정 가능성 확보**.
> 변경 이력은 `.sfs-local/events.jsonl` 의 `phase_change` / `gate_review` event 로 추적.
> SSoT: `05-gate-framework.md §5.1` (Gate 매트릭스).
> 입력 기준: 같은 sprint 의 `brainstorm.md` (G0) 를 먼저 읽고 작성한다.

---

## §1. 요구사항 (Requirements)

본 sprint 가 풀어야 할 문제 / 사용자 니즈 / 비즈니스 입력. 1줄 요약 + 배경 컨텍스트.

- [x] R1: `/sfs loop` 가 queue-first 로 task 를 pick 할 수 있어야 한다.
- [x] R2: queue 는 file-backed 이며 DB 의존성이 없어야 한다.
- [x] R3: task 등록/조회/claim 이 CLI subcommand 로 가능해야 한다.
- [x] R4: 기존 domain_locks sweep 은 fallback 으로 유지되어야 한다.
- [x] R5: active runtime 과 product dist template 이 같은 구현을 가져야 한다.

## §2. Acceptance Criteria (AC, 측정 가능)

각 요구사항에 대해 **측정 가능한 통과 조건** 정의. "되면 안 되는 것" (anti-AC) 도 명시.

- [x] AC1: queue scaffold path 5개가 존재한다 — verify by `find .../queue`.
- [x] AC2: `sfs-loop.sh enqueue "Queue smoke"` 가 pending markdown task 를 만든다 — verify by sandbox command.
- [x] AC3: `sfs-loop.sh queue` 가 상태별 count 를 출력한다 — verify by stdout.
- [x] AC4: `sfs-loop.sh claim --owner smoke-owner` 가 task 를 `claimed/smoke-owner/` 로 이동한다 — verify by file path.
- [x] AC5: `sfs-loop.sh --dry-run` 이 pending queue task 를 먼저 pick 한다 — verify by stdout.
- [x] AC6: `bash -n` 이 active/dist 양쪽 `sfs-loop.sh` 에서 통과한다.

## §3. 범위 (Scope)

- **In scope**:
  - `sfs-loop.sh` queue helpers/subcommands.
  - `.sfs-local-template/queue/*/.gitkeep` scaffold.
  - active `.sfs-local` runtime sync for dogfooding.
  - sandbox smoke tests.
- **Out of scope**:
  - full task body execution.
  - dependency graph.
  - retry auto-requeue.
  - UI/dashboard.
  - release cut / stable sync.
- **Dependencies**:
  - Existing loop executor/live mode remains unchanged.
  - Existing domain_locks fallback remains unchanged.

## §4. G1 Gate 자기 점검

- [x] R/AC 가 측정 가능 (정량 또는 binary)
- [x] 범위가 sprint 1개 안에서 닫힘
- [x] 의존성 / 결정 대기 항목이 명시됨

> 본 체크리스트 통과 = `/sfs review --gate G1` 진입 조건. verdict (pass / partial / fail) 는 `review.md` 에 기록.

## §5. Sprint Contract (Generator ↔ Evaluator)

`brainstorm.md` 의 G0 맥락을 기반으로 이번 sprint 의 실행 계약을 명시한다.
역할 흐름은 **CEO → CTO Generator ↔ CPO Evaluator → CTO 구현 → CPO 리뷰 → CTO rework/final confirm → retro** 이다.

- **CEO 요구사항/plan 결정**:
  - 문제 정의: domain_locks 만으로는 loop 작업 등록/claim/retry/multi-worker 확장이 어렵다.
  - 최종 목표: file-backed queue MVP 를 `/sfs loop` 에 붙이고 queue-first fallback 구조를 만든다.
  - 이번 sprint 에서 버릴 것: DB queue, full scheduler, dependency graph, release cut.
- **CTO Generator 가 만들 것**:
  - persona: `.sfs-local/personas/cto-generator.md`
  - preferred executor: codex
  - 산출물:
    - queue-aware `sfs-loop.sh`.
    - queue directory scaffold.
    - sprint log.
  - 변경 파일/모듈:
    - `.sfs-local/scripts/sfs-loop.sh`
    - `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`
    - `.sfs-local/queue/*/.gitkeep`
    - `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/queue/*/.gitkeep`
  - 구현하지 않을 것:
    - `sfs-common.sh` 변경.
    - retry/dependency executor.
    - version/changelog bump.
- **CPO Evaluator 가 검증할 것**:
  - persona: `.sfs-local/personas/cpo-evaluator.md`
  - preferred executor: claude/gemini later; current runtime performs smoke checks.
  - self-validation 방지: 구현한 agent/tool 과 다른 evaluator instance/tool 사용 권장
  - AC 검증 방법: `bash -n`, sandbox enqueue/queue/claim/dry-run, active/dist diff.
  - 회귀/위험 체크: existing `status/stop/replay/domain_locks fallback` 가 깨지지 않는지.
  - 통과/부분통과/실패 기준:
    - pass: AC1~AC6 전부 충족.
    - partial: subcommand 는 되지만 default loop queue-first 가 안 됨.
    - fail: 기존 loop 동작을 깨거나 bash portability 문제 발생.
- **CTO ↔ CPO 재작업 계약**:
  - CPO `pass`: 최종 통과 + retro 진입
  - CPO `partial`: 지정된 항목만 CTO 재구현 후 재리뷰
  - CPO `fail`: plan/scope 재검토 또는 구현 재작업
- **사용자 최종 결정이 필요한 지점**:
  - 다음 sprint 에서 `complete/fail/retry` 와 task body execution 을 구현할지 여부.
