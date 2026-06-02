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

Founder lifecycle 로 보면 같은 flow 가 네 단계에 걸쳐 반복됩니다.

| stage | Solon focus | Cowork/Chat | Code/CLI |
|---|---|---|---|
| Idea | `brainstorm`/`plan` 으로 문제, 고객, 포기할 것 정리 | 의도 인터뷰와 옵션 비교 | 필요 시 prototype scaffold |
| MVP | AC 가 있는 작은 `implement` slice | product review, handoff | 구현, 테스트, browser/API 검증 |
| Launch | `review`/release readiness | copy, onboarding, launch notes | deploy/publish 검증과 rollback evidence |
| Scale | `loop`/`retro`/wiki memory | 전략, 지식 정리, next bets | 반복 구현, regression, automation |

---
