---
doc_id: sfs-current-product-shape-ko-18
title: "언제 어떤 모드를 고르나"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-05-22
parent: docs/ko/current-product-shape.md
summary: "언제 어떤 모드를 고르나"
load_when: "Read when docs/ko/current-product-shape.md routes to this section."
---
## 언제 어떤 모드를 고르나

| 상황 | 추천 |
|---|---|
| 이미 구현할 범위가 분명함 | `sfs brainstorm --simple` 또는 바로 `sfs plan` |
| 새 기능을 처음 정의함 | `sfs brainstorm` |
| 사용자의 의도와 우선순위가 흔들림 | `sfs brainstorm --hard` |
| 설계/용어/검증 기준이 불명확함 | `sfs brainstorm --hard` |
| 이전 sprint 의 plan/ADR 을 이어받음 | inherit 기록 후 바로 `sfs implement` |

Solon 의 좋은 사용감은 빠르게 달리는 것이 아니라, 피드백 없이 너무 멀리 달리지 않는 것입니다.
