---
doc_id: sfs-v0.4-appendix-template-design
title: "PDCA Design Template"
version: 0.4-r4
status: draft
last_updated: 2026-04-28
audience: [division-heads, workers]
template_type: pdca-design

depends_on:
  - sfs-v0.4-s04-pdca-redef

defines:
  - template/design.md

references:
  - template/plan.md (defined in: appendix/templates/plan.md)
  - invariant/taxonomy-is-root (defined in: s02)
  - division/* (defined in: s03)

affects: []
---

# [PDCA-{ID}] Design — {Feature Name}

> **Template usage**: G1 통과 후 작성. G2 Design Gate 통과 시 lock.

---

## Frontmatter

```yaml
---
pdca_id: PDCA-042
phase: design
status: draft | g2-pending | locked
linked_plan: PDCA-042.plan.md
linked_acs: [AC-001, AC-002]
linked_taxonomy_contract: PDCA-042.plan.md#taxonomy-contract
---
```

---

## 1. 설계 개요

[본부별 산출물 형태 다름 — 아래 본부별 섹션 참조]

---

## 2. 본부별 산출물

> **Taxonomy-first rule**: 디자인/프론트/API 라벨은 Plan 의 `taxonomy_contract` 를 먼저 소비한다. 디자인이 새 용어를 만들면 taxonomy 본부 또는 strategy-pm 에 역제안으로 남긴다.

### 2.1 Strategy-PM 본부
- User Flow Diagram
- 와이어프레임 (low-fi)
- PRD 초안

### 2.2 택소노미 본부
- 분류체계 초안 (tree)
- 라벨 가이드
- canonical term diff (Plan 대비 변경사항)

### 2.3 디자인 본부
- Figma 시안 (high-fi)
- 디자인 토큰 (color, typography, spacing)
- 컴포넌트 스펙

### 2.4 기술개발 본부
- API spec (OpenAPI)
- DB schema (ERD or DDL)
- 모듈 구조

### 2.5 품질 본부
- 테스트 케이스 매트릭스
- QA 시나리오

### 2.6 인프라 본부
- Terraform draft
- 비용 추정 (cost-estimator 결과)
- secret/auth/data/monitoring/rollback/cost preliminary checklist

---

## 3. AC ↔ Design 매핑

```yaml
ac_to_design_map:
  AC-001:
    - DES-001: "회원가입 폼 UI"
    - DES-002: "이메일 발송 서비스"
  AC-002:
    - DES-003: "..."
```

> 이 매핑이 §6 α-1 방식의 부분 재오픈을 가능하게 함.

---

## 4. G2 Design Gate 체크리스트

본부별 evaluator 적용 (s05.2):

- [ ] design-critique (Design 본부) / design-validator (Dev 본부) / ...
- [ ] AC 모두 cover 되는가
- [ ] Plan 의 taxonomy_contract 를 소비했는가
- [ ] downstream 본부에 핸드오프 가능한 형태인가
- [ ] infra/security/cost early risk 가 누락되지 않았는가
- [ ] H6 학습 패턴 적용

---

*(template 끝)*
