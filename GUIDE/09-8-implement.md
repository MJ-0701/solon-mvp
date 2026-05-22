---
doc_id: sfs-product-guide-ko-9
title: "8. Implement - 작은 조각 하나를 실제로 움직이기"
visibility: oss-public
doc_type: user-guide
language: ko
updated: 2026-05-22
parent: GUIDE.md
summary: "8. Implement - 작은 조각 하나를 실제로 움직이기"
load_when: "Read when GUIDE.md routes to this section."
---
## 8. Implement - 작은 조각 하나를 실제로 움직이기

```bash
sfs implement "첫 실행 조각"
```

Solon 에서 `implement` 는 코드만 뜻하지 않습니다. 제품을 앞으로 움직인 산출물이라면 모두 구현
대상입니다.

| 작업 종류 | 예시 |
|---|---|
| 코드 | API, UI, 배치, DB migration, 테스트 |
| 문서 | README, GUIDE, runbook, 고객 안내 |
| 전략 | PRD, 가격 정책, 실험 계획, 우선순위 결정 |
| 디자인 | 화면 흐름, component handoff, interaction spec |
| QA | 재현 절차, smoke test, regression checklist |
| 운영 | 배포 절차, rollback 방법, 모니터링 메모 |
| 용어 정리 | 도메인 단어, naming, taxonomy |

첫 실행 조각은 작아야 합니다. 전체 기능을 한 번에 맡기기보다, 완료 기준 하나를 증명하는
변경부터 갑니다.

구현 전에는 아래 질문을 확인합니다.

- 기존 프로젝트는 어떤 구조와 이름 규칙을 쓰고 있나?
- 이번 조각이 증명할 완료 기준은 무엇인가?
- 바뀐 것을 어떻게 확인할 것인가?
- 사용자가 직접 결정해야 하는 경계가 남아 있나?

디자인/frontend 조각이면 `design.md` 또는 `docs/solon/design.md` 를 먼저 봅니다. 없다면 넓은 UI
생성 전에 색, type scale, spacing, radius, icon style 의 작은 seed 를 만들거나 gap 으로
기록합니다. review 에서는 token 밖 임의 색상, 임의 spacing, 섞인 icon weight, generic AI 슬롭
느낌을 확인합니다.

백엔드, 디자인, QA, 운영의 깊은 기준은 중요하지만 모든 사용자에게 첫 가이드에서 같은 무게로
설명할 내용은 아닙니다. 필요할 때
[현재 제품 흐름과 최근 변화](./docs/ko/current-product-shape.md) 를 참고하세요.

---

