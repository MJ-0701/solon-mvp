---
doc_id: sfs-v0.4-s09-differentiation
title: "§9. Differentiation vs bkit (H1/H2/H5/H6)"
version: 0.4
status: draft
last_updated: 2026-04-19
audience: [decision-makers, investors, co-founder-candidates]
required_reading_order: [s00, s02, s03, s04, s05, s06, s07, s08, s09]

depends_on:
  - sfs-v0.4-s00-intro
  - sfs-v0.4-s03-c-level-matrix
  - sfs-v0.4-s06-escalate-plan
  - sfs-v0.4-s08-observability

defines:
  - axis/h1-observability
  - axis/h2-role-scope
  - axis/h5-c-level-strategic-layer
  - axis/h6-self-learning
  - axis/h3-customization
  - axis/h4-production-ops
  - position/bkit-vs-sfs

references:
  - concept/company-as-code (defined in: s00)
  - division/* (defined in: s03)
  - role/* (defined in: s03)
  - channel/l1-s3 (defined in: s08)
  - channel/l2-git-docs-submodule (defined in: s08)
  - channel/l3-notion (defined in: s08)
  - concept/h6-self-learning (defined in: s06)
  - phase/phase2-roadmap (defined in: s07)

affects:
  - sfs-v0.4-s10-phase1-implementation
---

# §9. Differentiation vs bkit

> **Context Recap (자동 생성, 수정 금지)**
> Solon의 차별화 축 6개. Phase 1에서 본격 차별화하는 것은 **H1 / H2 / H5 / H6**.
> H3 / H4는 Phase 2에서 본격화.
> 의사결정자(투자자, 공동창업자 후보)가 "왜 Solon인가"를 빠르게 파악할 수 있도록.

---

## TOC

- 9.1 차별화 축 6개 개관
- 9.2 H1 — 3-Channel Observability
- 9.3 H2 — Role Scope (6 본부)
- 9.4 H5 — C-Level 전략 레이어
- 9.5 H6 — Self-Learning Loop
- 9.6 H3 / H4 (Phase 2 차별화)
- 9.7 포지션 문장
- 9.8 경쟁 도구 비교 매트릭스
- 9.9 차별화가 **아닌** 것 (기술 동류로 오인되는 것)
- 9.10 측정 가능한 차별화 — Phase 1 검증 지표

---

## 9.1 차별화 축 6개 개관

Solon의 차별화는 **축 6개**로 구조화된다. **Phase 1에서 본격화되는 것은 H1·H2·H5·H6** — 이 4개가 v0.4의 **의사결정자 어필 포인트**. H3·H4는 Phase 2로 연기.

| # | 축 | bkit / cowork / 범용 agent | Solon | Phase |
|:-:|---|-------------------------|-----|:---:|
| **H1** | Observability | 로컬 `.bkit-memory.json` / 없음 | **3-Channel (S3 / git / Notion)** | **1** |
| **H2** | Role Scope | 개발 중심 / 디자인 skill / 범용 | **6 본부 (PM/Tax/Design/Dev/QA/Infra) 풀 커버** | **1** |
| **H3** | Customization | 부분 가능 / 없음 | **divisions.yaml 완전 커스터마이징** | 2 |
| **H4** | Production Ops | 없음 | **RBAC + multi-tenant + marketplace** | 2 |
| **H5** | C-Level 전략 레이어 | 평탄한 agent 리스트 | **CEO/CTO/CPO (Opus) 분리, 5-Axis** | **1** |
| **H6** | Self-Learning | 없음 / 없음 | **Escalation → G5 → validator 자동 진화** | **1** |

### 9.1.1 왜 6개인가

6개 축은 **"회사 운영 시스템이 되려면 꼭 있어야 하는 것"** 을 역으로 도출한 것:
- 관측 없으면 개선 불가 → H1
- 도메인 커버 안 되면 공백 발생 → H2
- 조직마다 다름 → H3
- 혼자 쓸 땐 몰라도 상품화 시 필수 → H4
- 전략 판단자 없으면 실무 혼란 → H5
- 실수에서 배우지 못하면 장기 품질 하락 → H6

### 9.1.2 축별 중요도 (의사결정자 관점)

| 축 | 투자자 관심 | 공동창업자 관심 | 1인 창업가 본인 관심 |
|----|:---:|:---:|:---:|
| H1 | 중 (감사·책임) | 중 | 높음 (내 작업 흔적) |
| H2 | 높음 (TAM 확장) | 높음 (같이 할 일) | 매우 높음 (공백 메움) |
| H3 | 중 (vertical 확장성) | 중 | 중 |
| H4 | 매우 높음 (상품화) | 낮음 (Phase 2) | 낮음 |
| H5 | 높음 (차별화 stories) | 높음 (역할 분담) | 높음 (의사결정 가이드) |
| H6 | 높음 (해자) | 중 | 매우 높음 (같은 실수 안 반복) |

→ 관심사가 다르지만 H2·H5·H6는 **3자 모두 높음**. 이것이 Phase 1의 메인 무게중심.

---

## 9.2 H1 — 3-Channel Observability

`axis/h1-observability`: **같은 사실을 독자별 최적화된 세 view로 분리하는 것**이 Solon의 관측 전략.

### 9.2.1 기존 도구의 관측 한계

| 도구 | 관측 방식 | 한계 |
|------|---------|------|
| bkit | `.bkit-memory.json` (로컬 JSON) | 다른 PC와 race, 감사 불가, 비개발자 접근 불가 |
| cowork plugin | 없음 (skill 실행 이력만) | 이력 자체가 없음 |
| ChatGPT Teams | 대화 스레드 | 구조화 X, agent별 분리 X, 비용 집계 불가 |
| AutoGPT 류 | 실행 로그 (로컬) | agent 외부에서 읽기/쿼리 어려움 |
| **Solon** | **L1 (S3) + L2 (git SSoT) + L3 (Notion)** | 독자별 최적화, SSoT 단일화 |

### 9.2.2 Solon의 관측 모델이 해결하는 것

- **감사 가능성**: L2 git commit graph가 모든 결정의 timestamped audit trail (§8.2)
- **PC 간 race 제거**: `.sfs-local/`은 gitignore (§8.5.3) → 동기화 대상이 없어 race 불가능
- **비개발자 가시성**: L3 driver view가 read-only view → 외부 이해관계자가 접근 가능
- **비용 투명성**: L1 → L2 → L3 집계로 Sprint별 비용이 대시보드에 실시간 표면화 (§8.9)

### 9.2.3 "bkit도 git 쓰지 않나?"에 대한 답변

git을 쓰는 것과 **git을 SSoT로 설계한 것**은 다르다:
- bkit: git은 **코드용**, `.bkit-memory.json`은 별도 상태(다른 PC에 동기화 안 됨)
- Solon: **모든 결정의 산출물(plan/design/gate/escalation)을 git에 표준 포맷으로 저장**, local cache(`.sfs-local/`)와 명확 분리

→ **"git 쓰기"가 아니라 "git을 SSoT로 설계하기"** 가 차별점.

---

## 9.3 H2 — Role Scope (6 본부)

`axis/h2-role-scope`: 1인 창업가가 실제로 마주하는 **7 역할 병목**(§0.2)을 조직도로 해결.

### 9.3.1 기존 도구의 role 범위

| 도구 | 커버 role | 공백 |
|------|---------|------|
| bkit | Developer + 부분 QA | PM, Taxonomy, Design, Infra 체계 없음 |
| cowork plugin (design) | Designer 일부 (critique/handoff) | 나머지 모두 |
| v0 / Lovable / Bolt | UI 생성 (Designer + Dev 일부) | 기획/QA/Infra/운영 없음 |
| AutoGPT / BabyAGI | 범용 executor, role 개념 자체 없음 | 역할 분리 자체가 부재 |

### 9.3.2 Solon의 6 본부가 채우는 공백

| Solon 본부 | 커버하는 역할 병목 (§0.2) | bkit/cowork로 못 채우는 이유 |
|---------|-----------------------|---------------------------|
| strategy-pm | PM (기획), CEO 의사결정 보조 | bkit에 "requirements 작성" skill 없음 |
| taxonomy | 도메인 용어 일관성 | 모든 도구가 용어 관리 영역 부재 |
| design | UX flow + 디자인 시스템 + 핸드오프 | cowork 재사용하되 **연결(핸드오프)** 체계 추가 |
| dev | 구현 + 테스트 | bkit 재사용, Solon은 Gate만 덧씌움 |
| qa | 테스트 전략, gap 분석 | bkit의 gap-detector를 G4에서 40% 가중치로 통합 |
| infra | 비용/안정성/배포 | 어떤 AI 도구도 "비용 상한 체크" 체계 없음 |

### 9.3.3 "6개가 충분한가"

§0.2의 7 역할과 Solon 6 본부 mapping:

| 7 역할 | Solon 매핑 |
|-------|---------|
| CEO | role/ceo (strategy C-Level) |
| CTO | role/cto (strategy C-Level) |
| CPO | role/cpo (strategy C-Level) |
| PM | division/strategy-pm |
| Designer | division/design |
| Developer | division/dev |
| QA + Infra | division/qa + division/infra |

→ **C-Level 3 + Division 6 = 9개 역할 정의**가 7 병목을 초과 커버. Taxonomy는 7 병목에 없던 추가 보강.

### 9.3.4 왜 7 역할을 7 Division으로 1:1 매핑 안 했나

- **CEO/CTO/CPO는 C-Level**: 전략(Opus) vs 실무(Sonnet) 계층이 다름. Division과 같은 축으로 놓으면 혼란.
- **QA + Infra를 분리**: 1인 창업가에겐 둘 다 운영 과제이지만 **검증**(QA)과 **운영**(Infra)은 본질이 다름.
- **Taxonomy 추가**: 1인 창업가가 "놓치기 쉬운" 공백. 제품 용어가 흔들리면 기획·디자인·개발이 모두 흔들림.

→ "7 역할 → 3 C-Level + 6 Division"의 매핑은 **병목 해결 + 구조적 명료성** 동시 달성.

---

## 9.4 H5 — C-Level 전략 레이어

`axis/h5-c-level-strategic-layer`: 실무 agent 위에 **전략 판단 agent**를 별도 계층으로 두는 것. **Opus 모델 할당 + 5-Axis 평가**가 물리적 구현.

### 9.4.1 평탄 agent 리스트의 한계

| 증상 | 원인 |
|------|------|
| PDCA가 기술적으로는 완결인데 "왜 만든 건지" 잃어버림 | 전략 판단 주체 부재 |
| 본부 간 충돌 시 해결 의사결정자 없음 | 동일 Tier의 agent들은 권한 동일 |
| Sprint 전체 성공 여부를 누가 판단? | 평가 축 없음 |
| 모델 비용 최적화 (Opus vs Sonnet) 의사결정 근거 없음 | 역할별 required reasoning 수준 구분 없음 |

bkit/cowork/범용 agent는 모두 **평탄 리스트**. worker들끼리 책임 위임 혹은 사용자가 직접 결정.

### 9.4.2 Solon의 C-Level 레이어

§3.2에서 정의된 3 C-Level:
- **CEO (Planner)**: Sprint 우선순위, 출시 결정 — Opus
- **CTO (Generator)**: 아키텍처, 기술 부채 관리 — Opus
- **CPO (Evaluator)**: 결과물 5-Axis 평가 — Opus

이 계층이 있어야:
- Sprint 시작 시 **의사결정** (어떤 PDCA를 이번에 포함할지)
- Gate 실패 시 **분기 판단** (Case-α vs β, §6.1)
- Sprint 종료 시 **학습** (G5 retro, §6.6)
- 전체 **비용·품질 trade-off** (어떤 본부를 Opus로 올릴지)

### 9.4.3 "Opus 쓰는 게 차별화인가?"

Opus 자체는 차별화가 아니다. **Opus를 "어느 역할에 할당하는가"의 체계**가 차별화다.

| 도구 | 모델 선택 |
|------|---------|
| bkit | 사용자가 일괄 지정 (대개 Sonnet) |
| cowork plugin | skill별 내부 고정 |
| 범용 챗봇 | 사용자가 대화당 선택 |
| **Solon** | **역할별 할당 규칙** (C-Level→Opus, Lead/Worker→Sonnet, Prompt→Haiku), `config/models.yaml`로 override 가능 |

→ **모델 할당이 조직 설계의 일부** 라는 것이 Solon의 주장. "누가 얼마나 깊이 생각해야 하는가"를 비용으로 구현.

### 9.4.4 5-Axis 평가 — C-Level의 운영 수단

§5.6의 5-Axis (Value-Fit / User-Outcome / Soundness / Maintainability / Future-Proof)는 **CPO가 모든 본부 G4에 60% 가중치**로 적용하는 공통 평가 프레임. bkit의 `breakdown: {accuracy/completeness/style}`과 달리 **비즈니스 가치 축을 명시적으로 포함** (§5.6.3 비교).

→ "CPO가 없으면 5-Axis는 없다, 5-Axis가 없으면 정성 평가가 기술 메트릭으로 축소된다."

---

## 9.5 H6 — Self-Learning Loop

`axis/h6-self-learning`: **같은 실수를 두 번 반복하지 않게 하는 구조적 루프**. Solon이 시간이 지날수록 더 똑똑해진다는 주장의 엔진.

### 9.5.1 기존 도구의 학습 부재

| 도구 | 실패 → 다음 작업 반영 | 메커니즘 |
|------|---|---------|
| bkit | ❌ | 실패는 로그에 남지만 다음 Plan validation에 자동 반영 안 됨 |
| cowork plugin | ❌ | skill은 stateless |
| AI 챗봇 | ❌ | 대화 스레드 안에서만 memory, 다음 대화로 이어지지 않음 |
| Anthropic auto-memory | ⚠️ | 명시 저장만, 학습 패턴 추출 없음 |
| **Solon H6** | ✅ | Escalation → G5 Retro → validator check 추가 → 다음 Sprint plan에 강제 적용 |

### 9.5.2 Solon H6 파이프라인 (§6.6 상세)

```
[Sprint N]
   │
   │ Gate 실패 → escalation-record.yaml 작성 (§6.7)
   │ L2 SSoT에 저장 (docs/03-analysis/escalations/)
   │
   ▼
[G5 Sprint Retro]
   sprint-retro-analyzer (Opus) 가 전체 escalation 스캔
   → 3회 이상 같은 root cause 발견 시 pattern 추출
   → memory/learnings-v1.md에 append (status: proposed)
   │
   ▼
[사용자 승인 (Haiku prompt)]
   status: proposed → active
   │
   ▼
[Sprint N+1]
   plan-validator가 memory/learnings-v1.md 읽음
   → 신규 check를 G1 평가 시 자동 적용
   → 같은 실패를 plan 단계에서 선제 차단
```

### 9.5.3 학습 항목의 라이프사이클 (§6.6.3)

`proposed → active → dormant → archived`의 수명주기. 학습이 폭발해서 plan-validator가 느려지는 것을 방지.

- **active → dormant**: 6 Sprint 동안 위반 0건 → 비활성
- **dormant → active**: 동일 패턴 재발 → 부활
- **archived**: 12 Sprint dormant → 영구 보존하되 평가에서 제외

### 9.5.4 H6의 측정 가능성

Phase 1에서 H6의 유효성은 다음으로 측정:
- **학습 항목 적용 후 동일 패턴 재발률** (목표: < 10%)
- **active 학습 항목 수** (안정화 목표: 10~30개)
- **Sprint N+1 G1 pass rate 향상** (학습 적용 전후)

→ 이 3지표가 **Solon이 시간이 지나면서 똑똑해진다는 주장의 반증 가능한 근거**.

### 9.5.5 bkit/cowork가 H6을 추가할 수 없는 이유

기술적으로 불가능은 아니지만 구조적으로 어렵다:
- bkit은 1-프로젝트 scope — Sprint/cross-PDCA 집계가 설계에 없음
- cowork skill은 stateless — 누적 학습 저장 위치 부재
- 양쪽 모두 **escalation 개념 자체가 없어** 학습 원자 단위를 정의할 수 없음

→ H6은 §3(C-Level)·§4(Sprint)·§5(Gate)·§6(Escalate)·§8(SSoT)가 **함께 있어야** 성립. 시스템 전체의 결과물이지 단일 feature가 아니다.

---

## 9.6 H3 / H4 (Phase 2 차별화)

Phase 1에서는 기본 골격만, 본격 차별화는 Phase 2.

### 9.6.1 H3 Customization

`axis/h3-customization`: 조직마다 다른 본부 구성을 **YAML 수정만으로** 반영.

**Phase 1 현재 상태**:
- `config/divisions.yaml`로 6 본부 정의 (§7.3)
- 본부 추가/제거 가능, Evaluator 교체 가능
- 수정 영향 범위는 `/doc-validate`가 기계적으로 검증

**Phase 2 확장**:
- 본부 템플릿 라이브러리 (`sfs-commerce`, `sfs-saas`, `sfs-medical` 등)
- 마켓플레이스 fork/publish
- wizard UI로 비개발자도 편집

→ Phase 1부터 **기반은 구현**, Phase 2에서 **상품화**.

### 9.6.2 H4 Production Ops

`axis/h4-production-ops`: Solon이 1인 창업 도구를 넘어 **소규모 팀 → 중견 기업**까지 쓰일 수 있게 하는 운영 기능.

**Phase 1 현재 상태**:
- 솔로 가정, RBAC 없음
- 1 tenant (본인)
- L3 driver view 1개 (`none` 이면 local report, notion 이면 workspace)

**Phase 2 추가 기능**:
- **RBAC**: 본부별 권한 분리 (디자이너는 design 본부만, 외부 리뷰어는 read-only)
- **Multi-tenant**: 1 Solon 인스턴스 → N 조직. 조직별 divisions.yaml / git repo / Notion DB 격리
- **Enterprise observability**: 자체 대시보드 바이너리, audit log, compliance 리포트
- **SSO/SAML**: 조직 인증 연동

→ H4는 **Phase 1 완주 후 상품화 방향성**.

### 9.6.3 H3/H4가 Phase 1에 없는 이유

- 1인 창업가에게 Phase 1의 RBAC/multi-tenant는 **오버엔지니어링** (복잡도만 증가)
- Phase 1은 "혼자서 회사를 돌린다"가 증명 목표. Phase 2는 "2명~10명으로 확장"
- Phase 1 dogfooding 결과가 Phase 2 기능 선정의 근거 (§7.6)

---

## 9.7 포지션 문장

**bkit vs Solon 한 줄 위치**:

> **bkit** = 개발자 PDCA 워크플로우 도구 (Starter / Dynamic / Enterprise 레벨)
> **Solon** = **1인 창업가의 회사 전체 운영 시스템** (6 도메인 × 3 C-Level × 3-Channel Observability × 자기학습 루프)

### 9.7.1 이 문장이 의미하는 것

- bkit은 **도구**, Solon은 **운영 시스템 (OS)**
- bkit의 scope는 **프로젝트**, Solon의 scope는 **회사**
- bkit은 **개발자**가 사용, Solon은 **1인 창업가 (개발자 포함)**가 사용
- bkit은 **제품 PDCA**, Solon은 **제품 × 도메인 × 학습의 Sprint**

### 9.7.2 포지션 검증 질문

투자자·공동창업자 후보·초기 사용자가 흔히 물을 질문과 Solon의 답:

| 질문 | 답변 (한 줄) |
|------|---|
| "bkit 쓰면 되는 거 아니에요?" | bkit은 개발 PDCA만. Solon은 기획~인프라까지 6 도메인. |
| "LangChain 에이전트 프레임워크로 만들면?" | LangChain은 실행 엔진. Solon은 **조직 설계**. 둘은 다른 레이어. |
| "AutoGPT 변형 아닌가?" | AutoGPT는 loop. Solon은 **외부 검증 게이트 + 학습**. 자기검증 금지(원칙 2.2)가 정반대. |
| "혼자 쓰는데 Multi-tenant 필요해요?" | Phase 1은 불필요. Phase 2 상품화 때 필요. 지금은 H1·H2·H5·H6에 집중. |
| "Claude만 지원하면 lock-in 아닌가?" | Phase 2에서 모델 adapter 도입. Phase 1은 빠른 검증 우선. |

---

## 9.8 경쟁 도구 비교 매트릭스

| 도구 | H1 Observ. | H2 Role Scope | H3 Custom. | H4 Prod Ops | H5 C-Level | H6 Self-Learn | 전반 포지션 |
|------|:---:|:---:|:---:|:---:|:---:|:---:|------|
| **bkit** | △ (local) | △ (dev) | △ | ❌ | ❌ | ❌ | 개발자 PDCA |
| **cowork plugin (design)** | ❌ | △ (design) | ❌ | ❌ | ❌ | ❌ | skill 모음 |
| **ChatGPT Teams** | ❌ | ❌ | ❌ | △ | ❌ | ❌ | 범용 챗봇 |
| **LangChain Agents** | △ (trace) | ❌ | ❌ | ❌ | ❌ | ❌ | 실행 framework |
| **AutoGPT / BabyAGI** | △ | ❌ | ❌ | ❌ | ❌ | ❌ | single-agent loop |
| **Lovable / v0 / Bolt** | ❌ | △ (UI) | ❌ | ❌ | ❌ | ❌ | UI 생성 |
| **AutoDev / Devin류** | △ | △ (dev) | ❌ | ❌ | ❌ | ❌ | autonomous dev |
| **Cursor / Windsurf** | ❌ | △ (dev) | ❌ | ❌ | ❌ | ❌ | IDE agent |
| **Solon** | ✅ | ✅ | ✅ P1 기반 / P2 상품화 | ✅ P2 | ✅ | ✅ | **회사 운영 OS** |

### 9.8.1 매트릭스 해석

- Solon이 6축 모두 ✅인 **유일** 도구. 다만 H3·H4는 Phase 2 본격화 — Phase 1은 H1/H2/H5/H6에 집중.
- bkit이 개발 PDCA에서 가장 가까운 상대. Solon은 bkit을 **재사용**하되 위에 5축(H2 외 전부)을 얹는다.
- LangChain/AutoGPT/Devin류는 다른 레이어(실행 엔진). Solon은 그 위에서 **조직 설계**를 한다. 충돌 아니라 **상보적**.

### 9.8.2 매트릭스가 말하지 않는 것

- **완성도**: bkit은 성숙, Solon은 설계 단계. 완성도 축은 시간 문제.
- **학습 곡선**: Solon 은 6 본부/5 Phase/G-1/G0/G1~G5/RELEASE 등 **개념 밀도**가 높음. bkit이 훨씬 배우기 쉬움.
- **비용**: Solon 은 Opus 사용 빈도가 높아 **월 운영비가 비쌈**. bkit/cowork보다 비쌀 수 있음.

→ Solon 은 "더 많은 것을 하지만 더 무겁다". **모두의 첫 도구는 아니다** — 1인 창업가가 실제로 7 역할 병목을 느낄 때의 도구.

---

## 9.9 차별화가 아닌 것 (기술 동류로 오인되는 것)

경쟁사/투자자가 "비슷한 거 있어요" 라고 말할 때 혼동 방지.

### 9.9.1 "multi-agent orchestration이랑 같은 거 아냐?"

**아니다**. Multi-agent orchestration(LangGraph, AutoGen 등)은:
- agent들의 **실행 순서**를 정하는 framework
- role은 사용자 정의, 구조적 강제 없음

Solon은:
- **조직 설계의 결과물** (6 본부, 3 C-Level, 외부 검증)
- Orchestration framework 위에서 돌아갈 수 있지만 **core는 조직**

→ framework vs organization. 비유: "Unix vs Kubernetes"가 다르듯이.

### 9.9.2 "에이전트 role play잖아"

**형식은 비슷하지만 동작이 다르다**:
- Role play: LLM에게 "너는 CEO다" prompt → 여전히 같은 context에서 판단
- Solon: **다른 세션, 다른 모델, 다른 파일 권한, 다른 read-only 플래그** — 구조적으로 분리

→ role play는 prompt, Solon은 runtime.

### 9.9.3 "PDCA 템플릿 모음 아냐?"

bkit의 PDCA 템플릿(docs/standards/pdca/)과 Solon의 차이:
- bkit 템플릿: plan/design/analysis/report의 markdown 양식
- Solon: **템플릿 + Gate + Escalate + 학습 루프 + 3-Channel sync + 6 본부** 의 총합

→ 템플릿은 Solon의 **일부 (appendix/templates/)**, 전부가 아님.

### 9.9.4 "프롬프트 엔지니어링 체계 아냐?"

- 프롬프트 엔지니어링: agent 1개에 더 좋은 프롬프트를 주는 것
- Solon: **프롬프트 간 관계 + 산출물 스키마 + 검증 루프**를 구조화

→ 프롬프트는 worker agent의 일부, Solon의 core는 **워크플로우 구조**.

---

## 9.10 측정 가능한 차별화 — Phase 1 검증 지표

주장만으로는 부족하다. Phase 1에서 다음 5개 지표로 차별화를 **측정**한다.

| 지표 | 축 | Phase 1 목표치 | 측정 방법 |
|------|:--:|:-----:|------|
| **Sprint당 실패 회복 시간** (first gate fail → resolution) | H6 | 평균 < 24시간 (사용자 응답 제외) | L2 escalation timestamps |
| **동일 패턴 재발률** (같은 root_cause 반복) | H6 | < 10% | H6 학습 항목 추적 |
| **6 본부 중 Phase 1 active 본부 수** | H2 | ≥ 3 (dev + strategy-pm + 최소 1개 abstract 승격) | L2 PDCA 커밋 수 + `division.activation.changed` event |
| **Gate pass rate** (전체 Gate SUCCESS / Total) | H1 | ≥ 70% (Phase 1 baseline) | L3 driver view 또는 local report |
| **L2 → L3 sync 성공률** | H1 | ≥ 99% (best-effort) | observability-sync hook 로그 |

### 9.10.1 지표 달성이 의미하는 것

- 5개 모두 달성 → **Solon의 주장이 증거 기반으로 뒷받침됨** → Phase 2 투자 근거
- 1~2개 미달 → 해당 축 재설계 후 Phase 1 연장
- 3개 이상 미달 → Solon 설계 자체를 재검토 (구조적 결함 가능성)

### 9.10.2 지표의 특성

- 모두 **L2/L3에서 기계적으로 추출** 가능 (사용자 자기 평가 의존 X)
- `sprint-retro-analyzer`가 G5마다 자동 집계
- 지표 자체가 H1(관측)의 산물 — "측정 가능하다"는 것이 이미 차별화 증명

---

*(끝)*
