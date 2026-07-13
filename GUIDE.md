---
doc_id: sfs-product-guide-ko
title: "Solon 제품 사용 가이드"
visibility: oss-public
doc_type: user-guide
language: ko
updated: 2026-05-28
summary: "Thin index for Solon 제품 사용 가이드"
load_when: "Start here, then load only the child section needed."
split_children:
  - GUIDE/01-0.md
  - GUIDE/02-1.md
  - GUIDE/03-2-5.md
  - GUIDE/04-3.md
  - GUIDE/05-4.md
  - GUIDE/06-5.md
  - GUIDE/07-6-brainstorm.md
  - GUIDE/08-7-plan.md
  - GUIDE/09-8-implement.md
  - GUIDE/10-9-review.md
  - GUIDE/11-10-retro-sprint.md
  - GUIDE/12-11.md
  - GUIDE/13-12.md
  - GUIDE/14-13.md
  - GUIDE/15-14-sprint.md
  - GUIDE/16-15-team-rollout.md
  - GUIDE/17-16-undocumented-takeover.md
  - GUIDE/18-17-security-audit.md
---
# Solon 제품 사용 가이드


> 목표는 설치 직후 30분 안에 첫 작업 묶음(sprint)을 시작하고, 생각 정리부터 마무리까지
> 어떤 순서로 진행하면 되는지 편하게 감을 잡는 것입니다.

**언어**: 한국어 / [영어 문서](./docs/en/guide.md)

자세한 제품 철학과 운영 구조는 [현재 제품 구조와 운영 흐름](./docs/ko/current-product-shape.md),
AI 시대에 Solon 이 주는 가치는 [Solon 10x 가치](./docs/ko/10x-value.md) 에서 이어서 볼 수 있습니다.

제품 PR 은 Gate 6 self-CPO 와 cross-CPO PASS evidence, 또는 구체적인 cross-review fallback
reason 을 본문에 남겨야 합니다. GitHub `@codex` / PR approval / check PASS 만으로는 SFS
review 를 대체하지 않습니다.

---

## 문서 지도

이 파일은 기존 경로를 유지하는 얇은 진입점입니다. 상세 본문은 아래 child 문서로 분리되어 있고, 각 child 문서는 독립 frontmatter 를 가집니다.

- [0. 이 문서가 알려주는 것](./GUIDE/01-0.md)
- [1. 설치와 초기화](./GUIDE/02-1.md)
- [2. 5초 그림](./GUIDE/03-2-5.md)
- [3. 어디서 어떻게 입력하나](./GUIDE/04-3.md)
- [4. 첫 상태 확인](./GUIDE/05-4.md)
- [5. 새 작업 시작](./GUIDE/06-5.md)
- [6. Brainstorm - 생각 정리 단계](./GUIDE/07-6-brainstorm.md)
- [7. Plan - 실행 전 약속 만들기](./GUIDE/08-7-plan.md)
- [8. Implement - 작은 조각 하나를 실제로 움직이기](./GUIDE/09-8-implement.md)
- [9. Review - 산출물이 받아들일 만한지 확인하기](./GUIDE/10-9-review.md)
- [10. Retro - sprint 마무리](./GUIDE/11-10-retro-sprint.md)
- [11. 필요할 때만 쓰는 명령](./GUIDE/12-11.md)
- [12. 업데이트](./GUIDE/13-12.md)
- [13. 자주 헷갈리는 것](./GUIDE/14-13.md)
- [14. 첫 sprint 예시](./GUIDE/15-14-sprint.md)
- [15. 팀 도입: 챔피언 + 저장소 우선](./GUIDE/16-15-team-rollout.md)
- [16. 무문서 코드베이스 인수 (dig)](./GUIDE/17-16-undocumented-takeover.md)
- [17. 정기 보안 감사 (audit)](./GUIDE/18-17-security-audit.md)
