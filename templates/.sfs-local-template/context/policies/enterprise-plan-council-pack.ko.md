---
id: sfs-policy-enterprise-plan-council-pack-ko
summary: plan 단계에서 6본부가 실제 설계 검토를 수행하도록 하는 계약 팩.
language: ko
load_when:
  - plan
  - Gate 3
  - 6본부
  - enterprise council
  - division_subagent_ledger
status: filled-v1
parent_doc: enterprise-agent-team-pack.ko.md
content_policy: "plan 생성, plan rework, Gate 3 review 때 로드"
---

# Enterprise Plan Council Pack

Gate 2 brainstorm 이후, Gate 3 review 전에 사용한다. 목적은 plan 을 실제
설계 단계로 만드는 것이다.

## Council 절차

1. brainstorm, 최신 handoff/user intent, active sprint, wiki/domain map 을 확인한다.
2. 가장 작은 유용한 work slice 와 AC 를 만든다.
3. 각 본부마다 finding, risk flag, AC/files/evidence mapping,
   `asset_candidate`, waiver/N/A, next action 을 기록한다.
4. 해당 row 에 트리거가 있을 때만 deep pack 을 연다.
5. 관련 본부의 finding/evidence/waiver 가 없으면 Gate 3 는 partial 이다.

## 본부별 산출

| division | plan output |
|---|---|
| strategy-pm | 사용자 가치, scope/non-goal, rollout, decision boundary |
| dev | domain/application/interface/infra boundary, files_scope, slice split |
| QA | 첫 failing/characterization/smoke/review signal, edge case |
| design | workflow, interaction state, accessibility, visible risk 또는 N/A |
| infra | runtime, deploy, data, secret, observability, cost/latency, rollback |
| taxonomy | canonical terms, states/events, forbidden aliases, UI/API/docs/log wording |

각 row 는 재사용할 domain asset 도 함께 이름 붙인다. 기존 asset 재사용, 신규 asset 생성,
명시적 gap/waiver 중 하나를 적는다. 이것이 6본부 council 의 존재 이유다.

## Risk Flag

- security/privacy/auth/permission/PII/payment/finance/production write
- public API/schema/CLI/docs contract 또는 destructive/data-loss behavior
- broad entrypoint 에 product policy 가 들어가는 경우
- hot path, batch, DB query, concurrency, storage, network, bundle risk
- multi-agent lane, 반복 partial/fail, 최신 handoff 와 stale sprint 충돌

## Plan 필수 항목

- `enterprise_council_ledger` 또는 확장 `division_subagent_ledger`
- risk flags 와 선택된 child pack
- 본부별 asset candidate 또는 concrete N/A reason
- AC to file/artifact/evidence mapping
- 모든 product-bearing entrypoint 의 DDD/TDD boundary
- 진짜 제품 판단에만 user approval boundary
- 첫 구현 slice 와 예상 verification command/evidence

## 빈칸 금지

6본부 표를 장식으로 채우지 않는다. 관련 없으면 concrete reason 과 함께
`not-applicable` 을 적고, 관련 있으면 finding 과 evidence 를 적는다.
