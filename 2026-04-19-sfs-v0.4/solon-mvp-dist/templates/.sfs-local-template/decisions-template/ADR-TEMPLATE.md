---
phase: decision
decision_id: "{{DECISION_ID}}"
sprint_id: ""    # filled by /sfs decision (current sprint)
created_at: "{{NOW}}"
status: proposed   # proposed | accepted | rejected | deprecated | superseded
---

# Decision {{DECISION_ID}} — {{TITLE}}

## Context

<문제 상황 / 결정이 필요한 트리거 / 관련 WU·sprint 단계 / 이미 시도한 접근.>

## Decision

<채택한 옵션 + 핵심 근거 1~3 줄. 단정적 시제, "we will ...">

## Alternatives

<고려한 다른 옵션들 + 각각 reject 사유. 최소 1개 (만약 alternative 가 없다면 "none considered" 명시).>

## Consequences

<긍정적 결과 / 부정적 결과 / trade-off / 영향 받는 영역. 미래형 시제, "this means ...">

## References

<관련 commit sha / 다른 decision id (`0042-...`) / WU 번호 / 외부 링크 / 인용 문서.>
