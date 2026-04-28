---
doc_id: sfs-v0.4-review-2026-04-28-startup-team-agent-flow
title: "2026-04-28 Review — Startup Team-Agent Flow 보강"
status: draft
created: 2026-04-28
visibility: raw-internal
source_thread: "Codex user-active conversation"
related_docs:
  - "../../04-pdca-redef.md"
  - "../../05-gate-framework.md"
  - "../../../2026-04-19-solo-founder-agent-system-proposal-v0.4-outline.md"
  - "../../../solo-founder-agent-system-proposal.md"
---

# 2026-04-28 Review — Startup Team-Agent Flow 보강

## 1. 사용자 원문 의도

사용자는 백엔드 개발 전문성은 충분하지만, 기획·디자인·프론트·인프라·보안·문서화 전문성은 상대적으로 약하다. 따라서 1인 창업자가 실제 스타트업 규모 팀처럼 일할 수 있도록 agent system 을 설계하고자 했다.

사용자 초안 흐름:

1. 아이디어 제출
2. 브레인스토밍
3. 플랜설계
4. 기획서 및 택소노미(와이어프레임) 설계
5. 구현
6. 분석 및 코드리뷰(Claude + Gemini CLI + Codex 참여)
7. 인프라 구축 및 배포(정보보안 검토는 배포 전 인프라 세팅 단계)
8. 문서화(초기 Notion, 도메인 문서와 팀별 문서, 전문가/비전문가용 분리)

## 2. Review Verdict

방향성은 맞다. 단순 agent 목록이 아니라, 제품을 시장에 내보내는 조직 흐름을 보고 있다는 점이 강하다.

평가:

| 항목 | 점수 | 판단 |
|---|---:|---|
| 비전 완성도 | 80 | "혼자서 스타트업 팀처럼 일한다"는 problem framing 이 명확하다. |
| 프로세스 뼈대 | 70 | 큰 단계 순서는 맞지만, stage contract 와 gate 기준이 덜 고정됐다. |
| MVP 자동화 가능성 | 45~55 | 바로 구현하려면 artifact schema, status model, gate report 가 먼저 필요하다. |
| 제품화 가능성 | 50 | 사용자 1인 workflow 에는 강하지만, 다사용자/상품화는 activation/rbac/observability 가 필요하다. |

## 3. 놓친 핵심

### 3.1 Discovery 가 Plan 앞에 명시돼야 한다

Brainstorm 만으로는 부족하다. 시장 가설, 타겟 사용자, 대체재, 문제 크기, 성공 지표를 묶은 Discovery artifact 가 있어야 한다.

왜 합리적인가:

- LLM agent 는 주어진 목표를 그럴듯하게 실행하는 데 강하지만, 목표 자체가 틀렸는지 자동으로 보장하지 못한다.
- Discovery 없이 Plan 으로 가면 "잘 만든 엉뚱한 제품" 위험이 커진다.
- Discovery 는 heavy market research 가 아니라 `문제 1문장 + 사용자 + 대체재 + 성공 지표 + 불확실성` 수준으로 시작하면 된다.

### 3.2 Taxonomy 는 와이어프레임 부속물이 아니다

사용자 초안에서는 "기획서 및 택소노미(와이어프레임)"처럼 묶였지만, taxonomy 는 wireframe 보다 더 하위 기반이다. Taxonomy 는 도메인 용어, 엔티티, 상태값, API resource, UI label, 문서 용어를 연결하는 공통 언어다.

왜 합리적인가:

- 백엔드 schema, frontend route, UI label, Notion 문서가 서로 다른 단어를 쓰면 agent 간 drift 가 발생한다.
- Solo founder 에게 taxonomy 는 "팀 회의에서 용어를 맞추는 행위"를 대체한다.
- MVP 에서는 full ontology 가 아니라 canonical term / forbidden alias / entity-state map 정도면 충분하다.

### 3.3 Code Review 는 구현 후 1회가 아니라 여러 Gate 중 하나다

Claude/Gemini/Codex 다중 리뷰는 좋은 아이디어다. 그러나 code review 를 한 지점에만 놓으면 PRD 오류, UX 오류, taxonomy 오류, infra 오류를 너무 늦게 발견한다.

보강 구조:

- G0: Discovery / Brainstorm gate
- G1: Plan / PRD / AC gate
- G2: Taxonomy / UX / Design gate
- G3: Technical Design / Pre-Handoff gate
- G4: Implementation / QA / Gap gate
- Release Gate: Infra / Security / Monitoring / Rollback gate
- G5: Docs / Retro / Learning gate

왜 합리적인가:

- 오류는 뒤로 갈수록 수정 비용이 커진다.
- agent 는 단계 사이 문맥 손실이 생기기 쉬우므로, 각 단계가 "다음 agent 에게 넘길 수 있는 상태"인지 확인해야 한다.
- Code review 는 중요하지만 제품 실패의 유일한 원인은 아니다.

### 3.4 Infra/Security 는 배포 직전만 보면 늦다

사용자 초안의 "정보보안 검토는 배포 전에 인프라 세팅단계"는 방향은 맞지만, 최소한 기술 설계 단계에서 먼저 risk sketch 가 필요하다.

왜 합리적인가:

- 인증, 권한, secret, DB 접근, 파일 저장, 로그/PII 는 설계 초기에 구조를 바꿀 수 있다.
- 배포 직전 security review 는 "출시를 막는 체크리스트"가 되기 쉽다.
- MVP 에서 필요한 것은 full threat modeling 이 아니라 `secret / auth / data / dependency / rollback` 5개 항목의 lightweight checklist 다.

### 3.5 Documentation 은 마지막 단계가 아니라 continuous ledger 다

마지막에 문서를 새로 쓰면 agent 가 기억으로 재구성한다. 더 안전한 구조는 각 단계 산출물을 Git L2 에 계속 남기고, 마지막 문서화 agent 가 domain/technical/runbook/Notion view 로 조립하는 것이다.

왜 합리적인가:

- 문서가 implementation 과 drift 나는 가장 흔한 이유는 "마지막에 몰아서 쓰기"다.
- 전문가용/비전문가용 문서는 서로 다른 원본이 아니라 같은 artifact source 의 다른 projection 이어야 한다.
- Notion 은 collaboration view 로 좋지만 SSoT 가 되면 역류 편집 때문에 agent state 가 흔들린다.

## 4. 반영된 수정

`2026-04-19-solo-founder-agent-system-proposal-v0.4-outline.md` 에 다음을 반영했다.

- `Artifact Contract First`, `Shift-left Infra/Security`, `Continuous Documentation` 을 v0.4 신규 도입 항목에 추가
- Design Principles outline 에 `Taxonomy is Root`, `Continuous Documentation Ledger` 등 보강 원칙 추가
- C-Level × Division Matrix 에 책임 경계 표 추가
- PDCA 재정의 섹션에 13단계 full form 추가
- 사용자 8단계 초안을 full form 으로 매핑하는 lightweight MVP projection 추가
- Gate Framework 에 G0/G1/G2/G3/G4/Release/G5 배치 원칙 추가
- Observability 에 L2 artifact source → L3 Notion projection 원칙 추가
- Phase 1 구현 우선순위를 agent 수 확장보다 artifact/gate/status contract 우선으로 명시

## 5. 예상되는 Claude Agent 반박과 답변

### 반박 A: "13단계는 너무 무겁다. MVP 에 맞지 않는다."

답변: full form 은 사고 모델이고, 실행은 lightweight projection 으로 압축한다. 처음부터 6 본부를 모두 active 로 켜지 않는다. strategy-pm + dev 를 기본 active 로 두고, taxonomy/design/infra/qa 는 scoped activation 으로 필요한 순간만 켠다.

### 반박 B: "Taxonomy 를 초기에 분리하면 속도가 느려진다."

답변: full taxonomy 를 만들자는 뜻이 아니다. 최소 taxonomy 는 canonical term, forbidden alias, entity/state naming 정도다. 이 정도도 없으면 backend schema, frontend label, Notion 문서가 곧바로 갈라진다.

### 반박 C: "Infra/Security 는 MVP 배포 직전에 보는 게 효율적이다."

답변: full infra implementation 은 뒤에 해도 된다. 그러나 secret, auth, PII, rollback, monitoring 의 최소 리스크는 기술 설계 단계에서 드러나야 한다. 초기 체크리스트 5줄이 나중의 구조 재작성을 줄인다.

### 반박 D: "문서화를 계속하면 개발 속도가 느려진다."

답변: 사람 손으로 문서를 계속 쓰자는 뜻이 아니다. 각 단계 agent 의 산출물을 L2 Git artifact 로 남기고, 최종 docs agent 가 조립한다. Continuous documentation 은 추가 업무가 아니라 handoff artifact 의 재사용이다.

### 반박 E: "Claude/Gemini/Codex 다중 리뷰는 비용이 커진다."

답변: 모든 변경에 호출하지 않는다. 위험도 높은 gate 에만 selective invocation 한다. 예를 들어 code review 는 high-risk diff, release gate, security-sensitive change 에 우선 적용한다.

## 6. Planner / Evaluator 로컬 리뷰

### Planner 관점

PASS with condition. 사용자 problem framing 은 강하다. 다만 agent organization 을 만들기 전에 "무슨 artifact 를 다음 단계에 넘기는가"를 먼저 고정해야 한다. 그렇지 않으면 조직도는 생기지만 handoff 품질이 흔들린다.

조건:

- Phase 1 은 full 13단계가 아니라 8단계 projection 으로 dogfooding
- 각 단계는 1~2 page artifact 부터 시작
- agent 수 확장보다 gate/report schema 우선

### Evaluator 관점

PASS with condition. 제품 품질 관점에서 가장 위험한 지점은 구현 품질보다 "요구사항/용어/UX/보안 판단이 늦게 발견되는 것"이다. 따라서 review 를 code review 하나로 두면 부족하고, PRD/Taxonomy/Design/Release gate 가 필요하다.

조건:

- 모든 gate 는 hard-block 이 아니라 evidence signal 로 시작
- 사용자 최종 승인 지점은 유지
- Notion 은 읽기 뷰, Git artifact 가 SSoT

## 7. 다음 Claude 세션 권장 행동

1. 이 review memo 를 먼저 읽고 v0.4 outline 의 2026-04-28 반영 내용을 확인한다.
2. 반박하려면 "단계가 많다"가 아니라 어느 artifact/gate 가 불필요한지 구체적으로 지적한다.
3. Phase 1 에서는 13단계를 모두 구현하지 말고 lightweight projection 을 dogfooding 한다.
4. 다음 설계 작업은 `Artifact Contract` 와 `GateReport` schema 를 먼저 구체화한다.
