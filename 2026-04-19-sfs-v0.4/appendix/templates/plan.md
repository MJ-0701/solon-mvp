---
doc_id: sfs-v0.4-appendix-template-plan
title: "PDCA Plan Template"
version: 0.4-r4
status: draft
last_updated: 2026-04-28
audience: [division-heads, workers]
template_type: pdca-plan

depends_on:
  - sfs-v0.4-s04-pdca-redef

defines:
  - template/plan.md
  - template/ac-yaml-block

references:
  - concept/pdca-phase (defined in: s04)
  - concept/artifact-contract (defined in: s04)
  - invariant/taxonomy-is-root (defined in: s02)
  - concept/ac-metadata (defined in: s04)
  - division/* (defined in: s03)

affects: []
---

# [PDCA-{ID}] Plan — {Feature Name}

> **Template usage**: 본부장이 G1 통과 전 작성. status가 `locked`이면 Escalate-Plan 외에는 변경 금지.

---

## Frontmatter (PDCA 레벨 메타)

```yaml
---
pdca_id: PDCA-042
division: dev | strategy-pm | design | taxonomy | qa | infra
sprint_id: SPR-2026-04-W3
created_at: 2026-04-19T10:00:00Z
status: draft | g1-pending | locked | reopened | aborted
related_pdcas:
  upstream: []     # 이 PDCA가 의존하는 다른 본부 PDCA
  downstream: []   # 이 PDCA에 의존할 다른 본부 PDCA
artifact_contract:
  inputs: ["brainstorm.md", "discovery-report.md(optional)"]
  outputs: ["prd", "taxonomy_contract", "acceptance_criteria", "risk_register"]
  downstream_consumers: ["design", "dev", "qa", "infra"]
---
```

---

## 1. 배경 / Why

[작성: 사용자 / CEO 입력]

---

## 2. 목표 / What

[작성: 본부장]

---

## 3. Taxonomy Contract

> FI-2 Taxonomy Is Root. 디자인/프론트/API/문서는 아래 용어와 분류를 기준으로 정렬한다. 불명확하면 구현 전에 taxonomy 본부 또는 strategy-pm 이 먼저 정리한다.

```yaml
taxonomy_contract:
  canonical_entities:
    - name: "User"
      korean_label: "사용자"
      description: "서비스를 실제로 사용하는 사람"
  canonical_actions:
    - name: "CreateOrder"
      korean_label: "주문 생성"
  reserved_terms:
    - term: "customer"
      use_instead: "user"
      reason: "B2B 관리자와 end-user 혼동 방지"
  open_questions:
    - "관리자와 운영자의 권한 라벨을 분리할지"
```

---

## 4. Acceptance Criteria (AC)

```yaml
acceptance_criteria:
  - id: AC-001
    description: "사용자는 이메일로 회원가입할 수 있다"
    measurable: "회원가입 후 30초 내 welcome 이메일 수신"
    relates_to_design: []   # G2 통과 후 채워짐
    relates_to_do: []       # G3 통과 후 채워짐
    status: locked          # locked | reopened (s06)
    locked_at: 2026-04-19T11:00:00Z

  - id: AC-002
    description: "..."
    measurable: "..."
    status: locked
```

> **AC Metadata 강제 이유**: §6 Escalate-Plan의 α-1 방식 (AC 단위 부분 재오픈)을 가능하게 하기 위함.

---

## 5. 범위 (Scope) & 비범위 (Non-Scope)

[작성: 본부장]

### In Scope
- ...

### Out of Scope (의도적 제외)
- ...

---

## 6. 의존성

| 본부 | PDCA | 필요 산출물 |
|------|------|----------|
| ... | ... | ... |

---

## 7. G1 Plan Gate 체크리스트

[plan-validator + {division}-reqs-validator 자동 체크 항목]

- [ ] 모든 AC가 measurable인가
- [ ] taxonomy_contract 가 비어있지 않은가
- [ ] canonical term 과 UI/API/문서 용어가 충돌하지 않는가
- [ ] AC 간 충돌이 없는가
- [ ] Out of Scope가 명시됐는가
- [ ] 다운스트림 본부의 입장이 반영됐는가
- [ ] infra/security/cost 관점의 early risk 가 risk_register 또는 Out of Scope 에 기록됐는가
- [ ] H6 학습 패턴이 체크됐는가 (자동, validator가 PTRN-* 적용)

---

*(template 끝)*
