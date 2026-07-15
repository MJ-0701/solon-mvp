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

## 1.1 AI Work Intake Carryover

- materials:
- ask-back rule:
- output format:
- work size: one-off / repeated / batch workspace

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
- references (경로/리포/커밋 + 모방할 점 한 줄, 지정 시 구현 전 필독 + 로그 흔적):

## 5.1 Mainline Focus Ledger

- main objective:
- current step:
- side-work classification: mainline / unblocker / deferred_followup / blocked / out_of_scope
- return condition:
- evidence:

보조 도구/인증/모델 설정은 본 objective 를 막는 진짜 unblocker 일 때만 interrupt 한다.
그 외에는 본론 종료 후 follow-up 으로 남긴다.

## 6. DDD/TDD 기준

- canonical domain terms:
- product behavior boundary:
- domain boundary / aggregate / invariant:
- DDD artifact/layer impact: product / domain / application / interfaces / infrastructure / docs / n/a
- first failing, characterization, smoke, or review evidence:
- TDD waiver / alternate evidence:

## 7. Division Sub-agent Ledger

| division | AC/files/evidence mapping | asset_candidate | status/finding/waiver |
|---|---|---|---|
| strategy-pm |  |  |  |
| dev |  |  |  |
| QA |  |  |  |
| design |  |  |  |
| infra |  |  |  |
| taxonomy |  |  |  |

## 7.1 Domain Asset Promotion Ledger

| source/ref | owner/expert | division | asset_candidate | promotion action | behavior check |
|---|---|---|---|---|---|
|  |  |  | reuse / create / gap / waiver |  |  |

## 8. Enterprise Plan Council

- risk flags:
- selected knowledge packs:
- enterprise_council_ledger:

| division | risk flag | finding | AC/files/evidence | asset_candidate | waiver/N/A |
|---|---|---|---|---|---|
| strategy-pm |  |  |  |  |  |
| dev |  |  |  |  |  |
| QA |  |  |  |  |  |
| design |  |  |  |  |  |
| infra |  |  |  |  |  |
| taxonomy |  |  |  |  |  |

## 9. Data Validation / Security / Checklist Plan

- data validation trigger: none / fixture / mock / seed / API payload / UI state / auth-session / migration / persistence / logs
- representative data set:
- fixture/mock/seed invariant:
- expected validation command/result:
- OWASP/security families:
- production console/debug log policy:
- Datadog/equivalent observability evidence:
- mission checklist path:

## 10. 사용자 검토 / 승인 경계

- required: false
- status: not-required
- reason:
- evidence:

`required` 는 제품 의미, IA, visible UI/workflow, public contract, 보안/개인정보/데이터 손실,
비용/모델 정책, 파괴적 행동, AC 의미를 새로 정의하거나 바꿀 때 true 로 둔다.
Gate 3 review PASS 는 사용자 승인으로 간주하지 않는다. 사용자가 구현 진입을 승인하면
`sfs capture --kind user-approval --gate 3 "..."` 로 evidence 를 남긴다.

## 11. 위험

- 위험:
- 대응:

## 12. 리뷰 준비

- [ ] 완료 기준이 측정 가능하다
- [ ] 한 sprint 안에서 닫힌다
- [ ] 검증 방법이 있다
- [ ] AI work intake 의 goal/materials/ask-back/output format/work size 가 계획에 반영되어 있다
- [ ] main objective 와 보조 작업 분류/복귀 조건이 적혀 있다
- [ ] Gate 2 결정이 요구사항과 AC에 연결되어 있다
- [ ] product behavior 변경이면 DDD boundary 와 TDD evidence 또는 waiver 가 있다
- [ ] data/mock/fixture/seed/API/UI/auth/session/persistence 변경이면 대표 데이터와 invariant 검증 계획이 있다
- [ ] security/logging/deploy 변경이면 OWASP family, console/debug log 정책, Datadog/equivalent evidence 가 있다
- [ ] 긴 컨텍스트/멀티 결함이면 wiki/workbench mission checklist 경로가 있다
- [ ] strategy-pm/dev/QA/design/infra/taxonomy division ledger 가 AC/files/evidence, `asset_candidate`, 또는 waiver 로 채워져 있다
- [ ] 재사용 가능한 도메인 노하우가 있으면 Domain Asset Promotion Ledger 에 source/owner/promotion/check 가 있다
- [ ] non-trivial product-bearing work 이면 Enterprise Plan Council risk flag / selected pack / AC evidence / asset row 가 있다
- [ ] 제품 의미/IA/visible UI/workflow/public contract/AC 의미 변경이면 사용자 승인 경계가 pending 으로 표시되어 있다
- [ ] 인터뷰 열린 질문이 남아 있지 않다 (답변이 스펙에 병합되었거나 명시적 skip 사유가 기록되어 있다)
- [ ] blind_spots 항목이 전부 answered / delegated 상태다
- [ ] references 가 있으면 구현 전 필독 + 구현 로그 확인 흔적 계획이 있다
- [ ] slice별 파일/산출물 매핑이 있다
- [ ] worker 모델 라우팅이 명시되어 있다: Codex 일반 worker는 `gpt-5.4`, bounded coding helper는 `gpt-5.3-codex`, Spark는 scope/files_scope/AC/정확한 수정 의도가 잠긴 무판단 기계적 구현 보조 작업에만 쓴다
