---
doc_id: sfs-current-product-shape-ko-13
title: "Design.md 와 AI 슬롭 방지"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-05-22
parent: docs/ko/current-product-shape.md
summary: "Design.md 와 AI 슬롭 방지"
load_when: "Read when docs/ko/current-product-shape.md routes to this section."
---
## Design.md 와 AI 슬롭 방지

design/frontend 작업은 `design.md` 또는 `docs/solon/design.md` 를 AI 가 읽는
디자인 시스템 계약으로 취급합니다. 이 파일은 colors, typography, spacing, radius, shadow,
component variants, icon style, forbidden values, rationale 을 담는 작은 계약입니다.

AI 가 UI 를 만들 때 가장 흔한 실패는 평균값으로 회귀하는 것입니다. 화면마다 다른 색, 다른
간격, 다른 radius, 섞인 icon weight, generic SaaS gradient 가 생기면 기능은 동작해도 제품의
감도가 사라집니다. Solon 의 디자인본부 review 는 이것을 AI 슬롭 리스크로 보고 token drift,
한국어 typography fit, desktop/mobile screenshot evidence 를 확인합니다.

원티드 몽타주식 컴포넌트, Coolicons 같은 단일 icon family, Pretendard 같은 Korean-capable font 는
한국어 제품의 좋은 starter set 이 될 수 있습니다. 단 이것들은 절대 vendor 규칙이 아니라 출발점입니다.
기존 제품 design system 이 있으면 기존 system 이 우선입니다.

