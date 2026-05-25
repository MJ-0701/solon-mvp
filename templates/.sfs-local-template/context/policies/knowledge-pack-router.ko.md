---
id: sfs-policy-knowledge-pack-router-ko
summary: 지식팩/review lens 라우터(한글 버전), 활성화 조건과 범위를 가볍게 제어.
language: ko
load_when: [knowledge pack, backend, strategy-pm, qa, design, infra, management-admin, taxonomy, finance, accounting, bookkeeping, tax, 경영관리, 재무, 경리, 세무, 회계, transaction, batch, DDD, TDD, domain model, product behavior, acceptance criteria, integration, API, AWS, Obsidian, 옵시디언, llm wiki, 위키, 문서 이관, enterprise, agent team, 6본부, 대기업급, performance, algorithm, QA/QC, mainline, focus, data validation, mock, fixture, seed, OWASP, Datadog, console.log, checklist, long context]
status: filled-v1
content_policy: "read only this router first; read full packs only when matching signals make them useful"
---

# Knowledge Pack / Review Lens Router

knowledge pack 을 열기 전에 이 router 를 먼저 읽는다. 기본 정책은 project size 와
risk 에 맞는 최소 check 만 활성화하는 것이다. 이 router 는 `.sfs-local/divisions.yaml` 과
같은 표면이 아니다. `divisions.yaml` 은 6개 core activation slot 을 위한 호환성 설정이고,
이 router 는 현재 guidance pack 과 review lens 를 고른다.
이 범위는 knowledge-pack 문서에 한정되며, 별도 요청이 없는 한 나머지 문서는 변경하지 않습니다.
6개 core division 은 brainstorm, plan, implement, review 전 단계의 always-on
Division sub-agent council 이다. `activation_state` 는 read-depth 와 escalation
을 조절할 뿐, strategy-pm/dev/QA/design/infra/taxonomy 참여 여부가 아니다.

## Lens activation

- Backend signals: `backend`, `JVM`, `Spring`, `JPA`, `transaction`, `batch`,
  `integration`, `DevOps`, `AWS`.
- Strategy/PM signals: `strategy`, `PM`, `roadmap`, `SLA`, `rollout`, `partnership`.
- QA signals: `qa`, `test`, `regression`, `release confidence`, `defect`.
- Design/frontend signals: `design`, `UX`, `UI`, `operator`.
- Infra/DevOps signals: `infra`, `deploy`, `release`, `observability`, `secrets`,
  `cost`.
- Management/admin signals: `management-admin`, `finance`, `accounting`,
  `bookkeeping`, `tax`, `invoice`, `cashflow`, `payroll`, `compliance`,
  `경영관리`, `재무`, `경리`, `세무`, `회계`.
- Taxonomy signals: `vocabulary`, `naming`, `state`, `event`, `enum`.
- DDD/TDD signals: `DDD`, `TDD`, `domain model`, `product behavior`,
  `acceptance criteria`, `aggregate`, `value object`, `test-first`, `failing
  test`, `red-green`.
- Obsidian/wiki signals: `Obsidian`, `옵시디언`, `llm-wiki`, `위키`,
  `knowledge base`, `문서 이관`, `existing project`, `new project`,
  `sprint continuity`.
- Enterprise team signals: `enterprise`, `agent team`, `6본부`, `sub-agent`,
  `대기업급`, `team agentic coding`, `QA/QC`, `metrics`.
- Performance/algorithm signals: `performance`, `algorithm`, `optimization`,
  `hot path`, `query plan`, `Core Web Vitals`, `memory`, `concurrency`.
- Mainline focus signals: `mainline`, `focus`, `본론`, `삼천포`, tool/auth/
  model setup, helper setup, 또는 agent 가 진짜 요청을 놓쳤다는 사용자 지적.
- Data validation signals: `mock`, `fixture`, `seed`, `sample data`,
  migration, backfill, API payload, UI state, persistence, auth/session data.
- Security/logging signals: `OWASP`, security, authz, PII, secrets,
  prompt injection, tool permissions, `console.log`, Datadog, observability.
- Checklist signals: long context, multi-step, 반복 product bug, monitor,
  release, 문제가 흐려질 수 있다는 사용자 지적, 프로젝트/agent 를 넘나드는 작업.

## Read order

1. Read only this file to decide coverage.
2. AC/lens 에 맞는 parent pack 을 읽는다.
3. Split pack 은 parent 가 지정한 child 중 active ids 와 matching 되는 파일만 읽는다.
4. Read deeper pack only if the task explicitly asks for detail
   (`deep`, `expand`, `full`, `evidence matrix`, or direct section reference).

## On-demand full-pack mapping

- `policies/backend-knowledge-pack.md`
- `policies/backend-knowledge-pack.ko.md`
- `policies/backend-knowledge-pack-runtime.md`
- `policies/backend-knowledge-pack-runtime.ko.md`
- `policies/backend-knowledge-pack-transactions.md`
- `policies/backend-knowledge-pack-transactions.ko.md`
- `policies/backend-knowledge-pack-integration.md`
- `policies/backend-knowledge-pack-integration.ko.md`
- `policies/backend-knowledge-pack-operating.md`
- `policies/backend-knowledge-pack-operating.ko.md`
- `policies/strategy-pm-knowledge-pack.md`
- `policies/strategy-pm-knowledge-pack.ko.md`
- `policies/qa-knowledge-pack.md`
- `policies/qa-knowledge-pack.ko.md`
- `policies/design-knowledge-pack.md`
- `policies/design-knowledge-pack.ko.md`
- `policies/design-knowledge-pack-operating.md`
- `policies/design-knowledge-pack-operating.ko.md`
- `policies/infra-knowledge-pack.md`
- `policies/infra-knowledge-pack.ko.md`
- `policies/management-admin-knowledge-pack.md`
- `policies/management-admin-knowledge-pack.ko.md`
- `policies/taxonomy-knowledge-pack.md`
- `policies/taxonomy-knowledge-pack.ko.md`
- `policies/ddd-tdd-knowledge-pack.md`
- `policies/ddd-tdd-knowledge-pack.ko.md`
- `policies/obsidian-llm-wiki.md`
- `policies/obsidian-llm-wiki.ko.md`
- `policies/enterprise-agent-team-pack.md`
- `policies/enterprise-agent-team-pack.ko.md`
- `policies/enterprise-plan-council-pack.md`
- `policies/enterprise-plan-council-pack.ko.md`
- `policies/enterprise-evidence-pack.md`
- `policies/enterprise-evidence-pack.ko.md`
- `policies/enterprise-performance-review-pack.md`
- `policies/enterprise-performance-review-pack.ko.md`
- `policies/mainline-focus-guard.md`
- `policies/mainline-focus-guard.ko.md`
- `policies/gate6-data-validation-pack.md`
- `policies/gate6-data-validation-pack.ko.md`
- `policies/agentic-security-logging-pack.md`
- `policies/agentic-security-logging-pack.ko.md`
- `policies/wiki-mission-checklist-skill.md`
- `policies/wiki-mission-checklist-skill.ko.md`

## Depth Rules

- 첫 pass 는 router signal 과 matching pack 1개만 사용한다.
- multi-division work 는 AC 또는 risk evidence 가 여러 division 을 실제로 건드릴 때만 여러 pack 을 읽는다.
- 모든 pack 을 blocker 로 승격하지 않는다. 각 pack 은 matching scope, evidence,
  review question 을 고르는 decision aid 다.
- non-trivial product-bearing work 의 plan 은 enterprise plan council pack 을 연다.
  review 는 현재 risk/AC 가 닿을 때만 enterprise evidence/performance pack 을 연다.
- Tool/model/auth setup 은 자동으로 product work 가 아니다. 다른 objective 가
  활성화된 상태에서 setup 이 튀어나오면 `mainline-focus-guard.ko.md` 를 로드하고
  mainline/unblocker/deferred_followup/blocked/out_of_scope 로 분류한 뒤,
  unblocker 조건만 만족하면 즉시 본 objective 로 돌아간다.
- Gate 6 는 data, fixture, mock, seed, API payload, UI state, migration,
  auth/session, persistence behavior 가 바뀌면 `gate6-data-validation-pack.ko.md`
  를 로드한다.
- Security/logging/deploy 작업은 `agentic-security-logging-pack.ko.md` 를 로드하고
  관련 finding 을 OWASP 계열 + logging/Datadog evidence 로 매핑한다.
- Long-context 작업은 `wiki-mission-checklist-skill.ko.md` 를 로드한다. checklist 는
  final 에 몰아서가 아니라 evidence 가 생길 때마다 상태를 갱신한다.
- pack 이 MSA, 대형 redesign, release-readiness escalation, finance/admin process,
  tax/accounting advisor checkpoint, governance process 같은 큰 전환을 제안하면
  조용히 scope 를 넓히지 말고 user/product decision 으로 surface 한다.
