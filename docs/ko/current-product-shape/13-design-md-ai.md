---
doc_id: sfs-current-product-shape-ko-13
title: "Design.md 와 AI 슬롭 방지"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-08-29
parent: docs/ko/current-product-shape.md
summary: "Design.md 와 AI 슬롭 방지"
load_when: "Read when docs/ko/current-product-shape.md routes to this section."
---
## Design.md 와 AI 슬롭 방지

design/frontend 작업은 `design.md` 또는 `docs/solon/design.md` 를 AI 가 읽는
디자인 시스템 계약으로 취급합니다. 이 파일은 colors, typography, spacing, radius, shadow,
component variants, icon style, forbidden values, rationale 을 담는 작은 계약입니다.

## 초심자 디자인 인테이크

초심자 route는 `sfs context cat policies/design-intake-flow.ko`로 엽니다. 여섯 문항
brief는 디자인 도움이 필요하거나 디자인 경험이 없다고 한 요청, 또는 확인된 seed가
없는 넓은 새 화면·흐름·리디자인에만 씁니다. 확인된 seed는 바로 구현하고, 기존
visible UI의 작은 수정은 기존 pattern을 지키며 필요한 경우에만 좁은 `UNVERIFIED`
gap을 기록합니다.

Figma가 있으면 먼저 쓰고, 없으면 screenshot 또는 reference page를 씁니다. 셋 다
없으면 기존 product system을 우선하고, 없을 때는 차분한 task-first layout, 읽기 쉬운
type, 단일 icon family, 절제된 accent, 일정한 spacing, 과하지 않은 radius를 쓰는
안전한 starter direction을 제안합니다. 남의 treatment 복제와 generic gradient는
피합니다. seed에는 token, component/icon rule, prohibited value, reference rationale을
기록합니다. 사람이 있으면 확인은 한 번만 묻습니다. 확인이 없거나 noninteractive/CI
작업이면 proposed seed 또는 gap을 `UNVERIFIED`로 기록하고 `Ready`라고 부르지
않습니다. 이는 새 hard gate가 아니라 evidence 상태입니다. seed 또는 기존 화면에
있는 값으로 구현하고 desktop/mobile evidence를 모읍니다.

AI 가 UI 를 만들 때 가장 흔한 실패는 평균값으로 회귀하는 것입니다. 화면마다 다른 색, 다른
간격, 다른 radius, 섞인 icon weight, generic SaaS gradient 가 생기면 기능은 동작해도 제품의
감도가 사라집니다. Solon 의 디자인본부 review 는 이것을 AI 슬롭 리스크로 보고 token drift,
한국어 typography fit, desktop/mobile screenshot evidence 를 확인합니다.

원티드 몽타주식 컴포넌트, Coolicons 같은 단일 icon family, Pretendard 같은 Korean-capable font 는
한국어 제품의 좋은 starter set 이 될 수 있습니다. 단 이것들은 절대 vendor 규칙이 아니라 출발점입니다.
기존 제품 design system 이 있으면 기존 system 이 우선입니다.
