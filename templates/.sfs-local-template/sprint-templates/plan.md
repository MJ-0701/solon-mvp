---
phase: plan
gate_number: 3
gate_label: "Gate 3 (Plan)"
gate_id: G1
sprint_id: ""
goal: ""
created_at: ""
last_touched_at: ""
user_approval_required: false
user_approval_status: "not-required"
user_approval_evidence: ""
---

# 계획

## 1. 목표

-

## 2. 요구사항

- [ ] R1:
- [ ] R2:

## 3. 완료 기준

- [ ] AC1:  / 검증:
- [ ] AC2:  / 검증:

## 4. 범위

- 할 것:
- 안 할 것:
- 의존성:

## 5. 실행 계약

- 작업 조각:
- 바뀔 파일/산출물:
- 인터페이스/산출물 경계:
- 사용자 결정 지점:
- AI 위임 범위:

## 6. DDD/TDD 기준

- canonical domain terms:
- product behavior boundary:
- domain boundary / aggregate / invariant:
- DDD artifact/layer impact: product / domain / application / interfaces / infrastructure / docs / n/a
- first failing, characterization, smoke, or review evidence:
- TDD waiver / alternate evidence:

## 7. 사용자 검토 / 승인 경계

- required: false
- status: not-required
- reason:
- evidence:

`required` 는 제품 의미, IA, visible UI/workflow, public contract, 보안/개인정보/데이터 손실,
비용/모델 정책, 파괴적 행동, AC 의미를 새로 정의하거나 바꿀 때 true 로 둔다.
Gate 3 review PASS 는 사용자 승인으로 간주하지 않는다. 사용자가 구현 진입을 승인하면
`sfs capture --kind user-approval --gate 3 "..."` 로 evidence 를 남긴다.

## 8. 위험

- 위험:
- 대응:

## 9. 리뷰 준비

- [ ] 완료 기준이 측정 가능하다
- [ ] 한 sprint 안에서 닫힌다
- [ ] 검증 방법이 있다
- [ ] Gate 2 결정이 요구사항과 AC에 연결되어 있다
- [ ] product behavior 변경이면 DDD boundary 와 TDD evidence 또는 waiver 가 있다
- [ ] 제품 의미/IA/visible UI/workflow/public contract/AC 의미 변경이면 사용자 승인 경계가 pending 으로 표시되어 있다
- [ ] slice별 파일/산출물 매핑이 있다
- [ ] worker 모델 라우팅이 명시되어 있다: Codex 일반 worker는 `gpt-5.4`, bounded coding helper는 `gpt-5.3-codex`, Spark는 scope/files_scope/AC/정확한 수정 의도가 잠긴 무판단 기계적 구현 보조 작업에만 쓴다
