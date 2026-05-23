---
phase: implement
status: draft
sprint_id: ""
goal: ""
created_at: ""
last_touched_at: ""
---

# 실행

## 1. 작업 조각

- 대상:
- 계획 출처:
- 포함된 완료 기준:
- 제외:
- agent_mode: single
- agents: worker/generator-default

## 1.1 Agent 실행 옵션

- 기본값: single agent 가 이 조각 전체를 맡습니다.
- parallel 선택 조건: 각 lane 의 files_scope 가 겹치지 않고, lane 별 proposed commit message 를 한 문장으로 쓸 수 있을 때만 선택합니다.
- parallel 명령 예시: `sfs implement --agent-mode parallel --agents codex,claude[,gemini] "<work slice>"`
- split 금지 조건: 커밋 메시지를 확실히 설명하지 못하는 작업은 나누지 않습니다.
- lane 계약: 각 lane 은 AC/ADR subset, files_scope, non-goals, expected
  tests/evidence, output report path, proposed commit message 를 먼저 적고
  시작합니다.

## 2. 가드레일

- 가장 작은 유효 변경:
- 따를 기존 패턴:
- 건드리는 용어/이름:
- product behavior boundary:
- DDD boundary: domain / application / interfaces / infrastructure / n/a
- broad entrypoint policy owner:
- AC/ADR acceptance map:
- domain invariant / aggregate:
- TDD first check / product evidence:
- TDD waiver / alternate evidence:
- 피할 위험:

## 3. 변경

- 코드:
- 문서:
- 테스트/체크:
- 기타:

## 4. 검증

- first failing/characterization/smoke/review evidence:
- 명령:
```text
```
- 결과:
- 수동 확인:
- agent cross review:

## 5. Implementation Acceptance Ledger

| AC/ADR/decision | status (implemented/missing/deferred/waived) | files/artifacts | tests/evidence | gap/follow-up |
|---|---|---|---|---|
|  |  |  |  |  |

## 6. 리뷰 인계

- 리뷰 준비: no
- 알려진 위험:
- 다음 명령: `sfs review --gate 6`
- 리뷰 규칙: 구현 후 review 는 필수입니다. parallel agent 로 구현했다면 Gate 6 전 agent 간 cross review 도 필수입니다.

## 7. Commit Unit Plan

- lane:
  - agent:
  - AC/ADR subset:
  - files_scope:
  - non-goals:
  - expected tests/evidence:
  - output report path:
  - proposed commit message:
  - verification:
  - cross reviewer:
  - merge/conflict policy:
