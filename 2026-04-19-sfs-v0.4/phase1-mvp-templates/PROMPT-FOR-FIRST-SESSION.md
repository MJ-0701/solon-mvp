# 첫 Claude 세션에 붙여넣는 프롬프트 (admin panel repo)

> 새 repo 에서 `claude` 처음 실행 시 아래 블록을 복사해서 붙여넣는다.
> Claude 가 7-step flow + IP 경계 + 한국어 반말을 한 번에 흡수하게 하는 용도.

---

## 🔷 복붙 블록 시작

안녕. 이 repo 는 `<PROJECT-NAME>` — 새 회사의 관리자 페이지 MVP 다. 다음 규칙으로 작업해:

1. **운영 방식**: 7-step flow (브레인스토밍 → plan → sprint → 구현 → review → commit → 문서화). 세부는 `CLAUDE.md` 읽어.
2. **Gate**: G0 / G1 / G2 / G4 4 개만. 모두 signal, hard-block 아님. G-1 / G3 / G5 는 MVP 에서 skip.
3. **산출물**: Sprint 산출물은 `.sfs-local/sprints/<YYYY-W>-sprint-<N>/` 에 저장. `brainstorm.md` / `plan.md` / `review.md` / `retro-light.md` 4 파일.
4. **L1 event**: `.sfs-local/events.jsonl` 에 각 Gate verdict 를 1 line JSON 으로 append.
5. **의사 결정**: 자가 검증 금지 (A/B/C 의미 결정은 나에게). 불확실하면 Option α/β/γ 3 개 제시하고 β (minimal) 를 기본 권장만.
6. **언어**: 한국어 반말, 짧고 직설. 기록 > 기억.
7. **IP 경계**: 이 repo 는 회사 IP. 내 개인 방법론 docset 경로 / repo URL 을 이 repo 파일 어디에도 쓰지 마. 내가 대화에서 지칭할 때만 참고.
8. **Git push 금지**: 내가 터미널에서 직접 push. 너는 local commit 까지만.

첫 작업: **Sprint 1 을 G0 브레인스토밍부터 시작**해. `.sfs-local/sprints/2026-W18-sprint-1/brainstorm.md` 를 `sprint-0-brainstorm.md.template` 골자를 참고해서 작성. 문제 1 문장 + 1 차 기능 in/out-of-scope 구분 + 모호 영역 질문 3~5 개.

6 본부 중 active 는 dev + strategy-pm 2 개만. 나머지 4 (qa / design / infra / taxonomy) 는 abstract — 필요성 느끼면 그때 activate 논의.

준비 끝나면 G0 verdict 받고 plan 단계로 넘어가자.

## 🔷 복붙 블록 끝

---

> **복붙 후 사용자가 채워야 할 것**: `<PROJECT-NAME>` 은 실제 이름으로 치환.
> **선택 사항**: 너가 Stack 이나 도메인 세부 사항 (예: "매출 조회는 월 단위 합계부터") 을 추가로 언급해도 됨.
