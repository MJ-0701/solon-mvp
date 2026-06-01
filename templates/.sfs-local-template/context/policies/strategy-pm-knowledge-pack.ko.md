---
id: sfs-policy-strategy-pm-knowledge-pack-ko
summary: Strategy/PM 지식 항목 인벤토리(한글 버전).
language: ko
load_when:
  - strategy-pm
  - product
  - roadmap
  - scope
  - stakeholder
  - SLA
  - business
  - rollout
status: filled-v1
content_policy: "compact operating guidance; apply only matching ids and keep strategy depth proportional to commitment risk"
---

# Strategy/PM Knowledge Pack Inventory

이 파일은 Strategy/PM 작업을 위한 compact filled guidance pack 이다. sprint,
plan, review, release 에서 product, scope, rollout, commitment, stakeholder
check 중 무엇이 활성화되는지 판단하고, matching id 만 적용한다.

## Activation Rules

- Activate only the propositions that match the project size and decision risk.
- Do not turn every small feature into a roadmap or governance exercise.
- Product commitments, partner commitments, pricing, SLA, user promises, and
  launch communication increase Strategy/PM depth.
- When the work is SFS product development, all core divisions plus the
  cross-cutting taxonomy lens are eligible.

## PM-SCALE - Review Depth By Project Size

- PM-SCALE-001: A throwaway experiment needs a hypothesis and stop condition, not a full business case.
- PM-SCALE-002: A first MVP needs target user, problem, non-goals, success signal, and release boundary.
- PM-SCALE-003: First production exposure needs rollback, support, communication, and owner clarity.
- PM-SCALE-004: Partner-facing work needs responsibility matrix, SLA/SLO, escalation path, and change notice rules.
- PM-SCALE-005: Paid, regulated, or trust-sensitive work needs risk acceptance and audit-friendly decision records.
- PM-SCALE-006: Multi-team work needs dependency map, milestone ownership, and decision cadence.
- PM-SCALE-007: Platform/product-line work needs compatibility, migration, deprecation, and adoption strategy.

## PM-PROP - Proposition Inventory

- PM-PROP-001: Shared intent must state the user, problem, business reason, expected customer-behavior outcome, and winning theory.
- PM-PROP-002: Scope must include non-goals so AI workers do not expand the wrong surface.
- PM-PROP-003: Acceptance criteria must be measurable by an evaluator without reading the generator's mind.
- PM-PROP-004: Prioritization must name tradeoffs, opportunity cost, and what is deliberately deferred.
- PM-PROP-005: Stakeholder promises must be separated from internal implementation preferences.
- PM-PROP-006: Partner responsibilities must be explicit for ownership, timing, error handling, and support.
- PM-PROP-007: SLA/SLO, RTO/RPO, maintenance windows, and support hours are product commitments, not only infra details.
- PM-PROP-008: Rollout must define audience, gates, kill switch, fallback, and communication channel when users are affected.
- PM-PROP-009: Roadmap items must identify dependencies, sequencing, and decision points.
- PM-PROP-010: Cost, pricing, and unit economics become active when runtime or vendor spend changes materially.
- PM-PROP-011: Metrics must distinguish leading indicators, lagging outcomes, guardrails, and vanity numbers.
- PM-PROP-012: Risk register entries must include assumption, likelihood, impact, owner, and review date.
- PM-PROP-013: Product decisions need ADR or decision-log evidence when they affect future compatibility.
- PM-PROP-014: User feedback loops must say who reviews feedback and what action threshold changes the plan.
- PM-PROP-015: Release notes and stakeholder updates must match the actual user-visible change.
- PM-PROP-016: Deprecation needs notice period, replacement path, compatibility guarantee, and sunset evidence.
- PM-PROP-017: Support and CS readiness become active when users can be blocked or confused by the change.
- PM-PROP-018: Experiments need hypothesis, segment, measurement window, and failure interpretation.

## PM-FILL - Operating Guidance

### PM-FILL-INTENT - Shared Intent

- scope 를 확장하기 전에 user, problem, business reason, expected customer-behavior outcome,
  winning theory 를 한 문단으로 쓴다. 다섯 중 하나가 비면 plan 은 아직 추측이다.
- user-visible promise 와 internal implementation preference 를 분리한다.
  user promise 는 AC/release note 로, preference 는 design/implementation note 로 간다.
- non-goal 을 명명한다. AI-assisted work 에서는 non-goal 이 adjacent surface 확장을 막는다.

### PM-FILL-SCOPE - Scope And Tradeoff

- scope 결정은 included, excluded, why now, reopen signal 을 함께 가져야 한다.
- install, upgrade, release, public docs, pricing, support, partner behavior 를
  건드리면 파일 변경이 작아도 product commitment 로 본다.
- deferral 은 owner, trigger, 또는 "이 product line 에서는 하지 않음" 이유가 있을 때만 유효하다.

### PM-FILL-AC - Acceptance Contract

- AC 는 구현자와 대화하지 않은 reviewer 도 확인할 수 있어야 한다.
- AC 는 evidence form 을 말해야 한다: command output, screenshot,
  generated file, release artifact, user flow, metric, decision record 등.
- non-code 작업도 AC 가 있다. docs clarity, terminology consistency,
  package inclusion, support handoff, user-facing copy 도 검증 가능해야 한다.

### PM-FILL-ROLLOUT - Launch And Communication

- release note 는 실제 user-visible behavior 와 맞아야 한다. 사용자의 행동이
  바뀌지 않는 internal detail 은 user note 에 넣지 않는다.
- 사용자가 막히거나 혼란스러울 수 있으면 rollout 은 audience, entry point,
  fallback, support owner, stop condition 을 가져야 한다.
- existing user 에게는 migration path, compatibility expectation, 안전하게 무시해도 되는 것을 알려준다.

### PM-FILL-METRICS - Feedback And Decision Cadence

- 유용한 metric 은 actor, action, time window, baseline, decision 을 포함한다.
  decision 이 없는 숫자는 vanity number 다.
- feedback loop 는 owner 와 threshold 가 있어야 한다. "피드백 수집"은 누가
  언제 plan 을 바꿀지 정해져야 loop 가 된다.
- experiment 는 hypothesis, segment, measurement window, success threshold,
  negative result 해석을 기록한다.

## PM-REVIEW - Review Questions

- reviewer 가 implementation note 없이 user value 를 설명할 수 있는가?
- non-goal 이 adjacent-scope expansion 을 막을 만큼 명확한가?
- 각 AC 에 concrete evidence 와 owner 가 있는가?
- release/user-facing message 가 실제 변경과 맞는가?
- deferred item 은 잊힌 것이 아니라 의도적으로 parked 되었는가?

## PM-EVIDENCE - Suggested Evidence

- one-paragraph shared-intent statement.
- AC table with evidence command/path/result.
- scope ledger: included, excluded, deferred, reason.
- 사용자 영향이 있을 때 release note 또는 stakeholder update draft.
- compatibility, pricing, SLA, partner, migration choice 에 대한 decision log.

## PM-GAP - Deepening Slots

- PM-GAP-001: Pricing and packaging decision framework.
- PM-GAP-002: Partner negotiation and responsibility matrix templates.
- PM-GAP-003: Roadmap sequencing and dependency scoring.
- PM-GAP-004: Launch communication and release-note quality rubric.
- PM-GAP-005: User research synthesis and feedback triage.
- PM-GAP-006: Product risk register examples.
- PM-GAP-007: Adoption and migration playbook for existing users.
- PM-GAP-008: Decision log templates for AI-assisted product work.

## PM-AIERA - AI 시대 기획 lens

2026-05 실무 강연에서 추린 review-lens 프롬프트. plan/scope/decision 작업의
토의용 체크이지 hard rule 이 아니다. 인용된 배수·업체·모델 주장은 강연 시점
주장으로 보고 행동 전 검증한다.

- PM-AIERA-001: "코드 생성 속도"와 "엔지니어링 처리량"을 분리한다. 코드 출력이
  빨라져도 통합·리뷰·테스트·릴리스가 빨라지는 건 아니다. AI 가속 작업을 기획할
  때 질문: 출력이 10x 되면 무엇이 먼저 무너지나 — 리뷰 용량, 테스트 실행시간,
  인프라, 토큰 예산?
- PM-AIERA-002: 각 plan 에 2-질문 시스템 lens — "왜?"(현재 이해) + "만약?"(미래·
  2차 효과) — 를 scope 확정 전에 적용한다.
- PM-AIERA-003: AI 도입을 "대체 ROI"가 아니라 "협업 생산성 극대화"로 프레이밍.
  "몇 명 줄이나?"를 안티패턴으로 보고, 단계적 내부 우선 rollout + human-in-the-
  loop 를 지키는 검증 인력 육성을 우선한다.
- PM-AIERA-004: 만들기 전에 요구를 명확히 한다. "앞 2번 질문이 뒤 5번 수정보다
  낫다" — 애매한 작업은 착수 전 질문/스펙 lock, 묵시 가정 금지.
- PM-AIERA-005: 방향을 저울질할 때 "좋은 기회" 축을 명시한다(일·돈·시간·성장;
  현재 안락보다 미래 상방) — 1인 운영자 커리어·사업 방향 brainstorm 에 유용.
- PM-AIERA-006: 분석·백테스트를 신뢰하기 전에 편향 체크리스트 — 생존편향·
  룩어헤드·데이터 스누핑·과적합 — 를 돌려, 확신에 찬 숫자를 건전한 결정으로
  오인하지 않는다.
- PM-AIERA-007: 요청에 4요소가 있는지 확인한다 — 목표·수용기준·금지·검증 방법.
  PM-AIERA-004 스펙 lock 의 구체 구조이며, 검증 기준이 포함돼 agent 가 리뷰를
  기다리지 않고 self-check(flowcheck/self-CPO)할 수 있는지 묻는다.
- PM-AIERA-008: scope 전에 문제 깊이를 캔다. "어렵다"에 멈추지 말고 근본원인까지
  왜 어려운지 묻는다. brainstorm/plan 진입은 '근본원인 1줄'을 ask-first 와 함께
  담는다.
- PM-AIERA-009: 옵션이 무한이 아니라 소수 정예로 큐레이션됐는지 묻는다. 옵션이
  폭증할수록 잘 고른 3~4개가 가치가 크다 — AskUserQuestion 에서 옵션 수를 제한
  하고 추천을 앞세워 반영한다.
- PM-AIERA-010: 자동화 경계가 어디인지 묻는다. 대략 70-80%는 자동화하되 마지막
  ~20%는 사람 판단이 필요하다; 운영자의 레버리지는 생성량이 아니라 그 판단이다.
  작업의 human-in-the-loop 위치를 밝힌다.
- PM-AIERA-011: trust-sensitive domain 에서는 배포 방식과 데이터 위치가 제품
  약속이다. local-first, cloud, sync, backup, migration 선택이 기술 보안 모델뿐
  아니라 사용자의 불안 모델과도 맞는지 묻는다.
- PM-AIERA-012: 얼리어답터의 기능 요청과 더 넓은 시장의 불안을 분리한다. PMF
  증거는 고급 기능을 보존하기 전에 interview, 결제 행동, support pattern, 반복
  objection 을 함께 본다.
- PM-AIERA-013: support 와 community 를 after-sales 잡무가 아니라 adoption loop 로
  본다. 빠른 응대, 보이는 개선, mentor network, 현장 전용 자료는 쌓인 신뢰를 만들
  때 해자가 된다.
- PM-AIERA-014: 도메인이 불신하는 기술 label 을 앞세우지 않는다. "AI" 같은 구현
  용어가 도입 마찰을 만들면 사용자 outcome, control boundary, manual override 를
  먼저 말한다.
- PM-AIERA-015: 바이브코딩/agent skill 을 수익화 전략이 아니라 레버리지로 본다. 유료 작업을 기획하기 전 무엇을 왜 만들지 설명하는 제품·도메인 뿌리지식이 있는지 묻는다.
- PM-AIERA-016: 프리랜스/서비스 작업은 구현만이 아니라 문제 진단과 로드맵을 판다. 의사결정권자에게는 비전, 실무자에게는 내부 보고 자료, enterprise 계정에는 장기 신뢰 cadence 로 artifact 를 맞춘다.
- PM-AIERA-017: product work 는 build 전에 선주문, landing/fake-door, 모객 신호 같은 demand evidence 가 필요하다. B2B/B2G 에서 도메인 전문성이 없으면 도메인 파트너 또는 stop condition 을 우선한다.
- PM-AIERA-018: AX 는 tool-use training 이 아니라 측정 가능한 시간/비용 절감 프로세스 재설계다. top-down sponsor, lead-workflow 자동화 대상, 측정 방법, 보상/변화저항 계획을 명명한다.
- PM-AIERA-019: activity-list strategy 를 거부한다. plan 은 통제 가능한 일을, strategy 는 통제 불가능한 고객 행동 변화·winning theory·사실이어야 하는 가정·베팅 조정 evidence cadence 를 명명한다.
