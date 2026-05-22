---
doc_id: sfs-current-product-shape-ko-7
title: "Plan 은 transcript 가 아니라 계약"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-05-22
parent: docs/ko/current-product-shape.md
summary: "Plan 은 transcript 가 아니라 계약"
load_when: "Read when docs/ko/current-product-shape.md routes to this section."
---
## Plan 은 transcript 가 아니라 계약

`sfs plan` 은 brainstorm 대화를 예쁘게 옮기는 단계가 아닙니다. plan 은 다음 항목을 포함해야 합니다.

- measurable acceptance criteria
- 이번 sprint 에 포함할 scope 와 제외할 scope
- feedback loop 또는 smoke/test/review 방식
- evaluator 가 어떤 기준으로 통과/보류/실패를 판단할지
- 다음 구현 slice 가 무엇인지

중요한 owner decision 이 비어 있으면 plan 을 추측으로 채우지 않습니다. 질문을 유지하고,
사용자의 판단을 기다립니다.

결정 질문은 `Q1`, `A/B/C/D`, `추천 A` 같은 내부 표기만으로 끝내지 않습니다. 선택지가 있으면
각 선택지의 뜻과 결과를 모두 보여주고, 추천은 기본값으로만 표시합니다. 한 화면에 다 담으면
복잡해지는 경우에는 선택지를 숨기지 않고 결정을 하나씩 순차적으로 묻습니다. `A/A/A/C/C 확정`
같은 option bundle 은 사용자-facing 확정 문구로 쓰지 않고, `권장안 그대로 확정`처럼 자연어로
받습니다.

