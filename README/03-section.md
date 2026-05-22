---
doc_id: sfs-product-readme-3
title: "기본 흐름"
visibility: oss-public
doc_type: product-intro
language: ko
updated: 2026-05-22
parent: README.md
summary: "기본 흐름"
load_when: "Read when README.md routes to this section."
---
## 기본 흐름

```text
sfs status
-> sfs start "<goal>"
-> sfs brainstorm [--simple|--hard] "<raw context>"
-> sfs plan
-> sfs implement "<first slice>"
-> sfs review
-> sfs retro
```

각 단계가 하는 일은 짧습니다.

- `start`: 지금부터 어떤 작업 묶음을 진행할지 엽니다.
- `brainstorm`: 의도, 우선순위, 포기할 것, 성공 기준을 정리합니다.
- `plan`: 목표, 범위, 완료 기준, 검증 방법을 한 sprint 안에서 닫히는 계약으로 만듭니다.
- `implement`: 코드, 문서, 전략, 디자인 handoff, QA evidence, 운영/runbook 중 필요한 산출물을 만듭니다.
- `review`: 만든 쪽이 스스로 통과시키지 않도록 검토 역할과 근거를 분리합니다.
- `retro`: 결과, 배운 점, 다음 action 을 남기고 sprint 를 닫습니다.

---

