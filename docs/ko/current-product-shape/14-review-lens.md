---
doc_id: sfs-current-product-shape-ko-14
title: "본부 / 지식팩 / Review Lens"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-05-25
parent: docs/ko/current-product-shape.md
summary: "본부 / 지식팩 / Review Lens"
load_when: "Read when docs/ko/current-product-shape.md routes to this section."
---
## 본부 / 지식팩 / Review Lens

현재 Solon 은 본부, 지식팩, review lens 를 같은 층위로 섞지 않습니다.
`.sfs-local/divisions.yaml` 은 기존 프로젝트 호환을 위한 6개 core activation slot
(`dev`, `strategy-pm`, `qa`, `design`, `infra`, `taxonomy`) 입니다. 이 파일은 activation 상태를
읽기 위한 runtime 설정이지, 전체 지식팩/review lens registry 가 아닙니다.
다만 6개 core division 은 brainstorm 부터 Gate 6 까지 always-on conceptual sub-agent
council 로 참여합니다. `activation_state` 는 read-depth/escalation 을 뜻하며, division 이
참여하지 않아도 된다는 뜻이 아닙니다.

현재 filled guidance 는 product-level DDD/TDD, backend, 전략/PM, QA, 디자인/frontend,
infra/DevOps, management-admin, taxonomy 지식팩/review lens 와 enterprise agent-team
팩으로 제공됩니다. DDD/TDD 는 backend 전용이 아니라 모든 product behavior 에 걸리는
기본선이고, backend 는 그 specialization 중 하나입니다. enterprise plan council/evidence/
performance pack 은 plan 을 실제 설계 단계로 만들고 Gate 6 주장을 측정 가능하게 만듭니다.

중요한 점은 사용자가 이 목록을 외우지 않아도 된다는 것입니다. Solon 은 작업 성격을 보고 필요한
관점만 읽습니다. 작은 문서 수정은 작게 보고, 배포나 구조 변경처럼 위험이 큰 작업은 더 단단하게
봅니다. 기준은 늘어나지만, 사용자가 마주하는 표면은 그대로 가볍게 유지하는 것이 방향입니다.
enterprise-triggered work 에서는 관련 본부마다 risk flag 와 finding/evidence/waiver 또는
구체적 not-applicable reason 을 남깁니다. 성능/알고리즘 PASS 는 측정, bounded proof, 또는
explicit N/A waiver 가 있어야 합니다.
backend 는 `dev` 의 기술 specialization 이고, management-admin 은 재무/경리/세무/회계 관점입니다.
taxonomy slot 은 legacy activation 호환성 때문에 남아 있지만, 제품 설명에서는 독립 조직 본부가
아니라 모든 본부에 걸치는 용어/분류 lens 로 다룹니다.

agent-skills 벤치마크에서 유용한 discipline 도 같은 방식으로 흡수했습니다.
공식 문서 기반 구현은 `implement` 와 `source-docs` review lens 로, stop-the-line 디버깅은
`implement` 검증 정책으로, deprecation/migration 은 `adopt`/`tidy` 정리 기준으로, shipping
check 는 `release` 정책으로 들어갑니다. 새 lifecycle command 를 늘리는 대신 기존 흐름의
판단 기준을 더 선명하게 만든 것입니다.
