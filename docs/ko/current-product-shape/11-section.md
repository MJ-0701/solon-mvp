---
doc_id: sfs-current-product-shape-ko-11
title: "얇은 멀티 에이전트 감독"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-05-22
parent: docs/ko/current-product-shape.md
summary: "얇은 멀티 에이전트 감독"
load_when: "Read when docs/ko/current-product-shape.md routes to this section."
---
## 얇은 멀티 에이전트 감독

SFS 는 Claude, Codex, Gemini 를 무조건 동시에 돌리는 제품이 아닙니다. 기본값은 한 agent 가
작은 작업 단위를 끝내고, 필요한 순간에만 역할을 분리하는 방식입니다.

- 리서처는 넓은 코드베이스, 낯선 도메인, 의존성 변경처럼 먼저 읽어야 할 것이 많을 때만 씁니다.
- 구현자는 plan 과 files_scope 가 고정된 뒤 작은 내부 조각을 맡습니다.
- 평가자는 생성자가 스스로 승인하지 않도록 별도 context 에서 검토합니다.
- 공유 메모리는 긴 대화록이 아니라 sprint workbench, `review.md`, `report.md`, 그리고 필요한 경우
  `docs/solon/domain-map.md` 입니다.

이 방식은 컨텍스트 오염을 줄이면서도 SFS 의 원칙인 "남길 것만 남긴다"를 지키기 위한 얇은
supervisor 패턴입니다.

