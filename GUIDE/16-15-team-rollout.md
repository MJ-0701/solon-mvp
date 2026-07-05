---
doc_id: sfs-product-guide-ko-16
title: "15. 팀 도입: 챔피언 + 저장소 우선"
visibility: oss-public
doc_type: user-guide
language: ko
updated: 2026-07-05
parent: GUIDE.md
summary: "15. 팀 도입: 챔피언 + 저장소 우선"
load_when: "Read when GUIDE.md routes to this section."
---
## 15. 팀 도입: 챔피언 + 저장소 우선

팀에 AI 작업 방식을 퍼뜨리는 검증된 순서는 **전원 교육이 아니라 소수 챔피언이
핵심 저장소를 먼저 AI 친화적으로 만드는 것**입니다 (대규모 조직 사례,
`idea_wiki:L087-I3·I4`). 이유는 단순합니다 — 저장소는 팀 전원이 매일 지나는
길목이라, 소수가 저장소에 심은 지식이 팀 전체의 바닥을 올립니다
(`idea_wiki:L087-I6`). 강의는 들은 사람만 바꾸지만 저장소 개선은 모두를 바꿉니다.

**표준은 하달하지 않습니다.** 챔피언이 정답 템플릿을 내려보내는 대신, 저장소별로
자율 수렴하게 둡니다 (`idea_wiki:L087-I7`) — solon 의 routed 정책·어댑터 문서가
그 수렴의 공용 골격이고, 프로젝트별 차이는 `.sfs-local/context/` 오버라이드와
저장소 자체 문서로 남깁니다.

### 순서 (저장소 1개 기준)

1. **readiness 감사** — `sfs harness doctor` 의 AI Readiness 섹션으로 현재 위치
   파악. Sanity 4축(테스트 진입점 / dead-code / 컨벤션 / 문서 신선도)과
   AI-friendly 표면 4축(저장소 안내서 / 가드레일 / 커맨드·스킬화 / AI 리뷰어)을
   함께 봅니다. 온보딩의 첫 질문은 "무엇을 도입할까"가 아니라 "지금 어디인가"
   입니다 — AI Maturity 섹션이 5단계 사다리에서 현재 레벨을 알려줍니다.
2. **표면 정비** — 점수가 낮은 축부터: 얇은 `SFS.md` 라우터와 루트 어댑터 문서,
   테스트 진입점, 반복 작업의 커맨드/스킬화. 이것이 위 표면 4요소의 실체입니다.
3. **위임 입구** — 표면이 준비되면 WU 통째 위임을 시작합니다 (`sfs start` →
   plan → implement). 성숙도 레벨 3 이 목표입니다.
4. **리뷰 루프** — 위임이 흐르기 시작한 뒤에 Gate 6 리뷰 레일을 상시화합니다.
   준비 전에 리뷰어부터 켜지 않는 것도 검증된 순서 규율입니다
   (`idea_wiki:L087-I10`) — readiness 의 Sanity-before-Cartography 와 같은 결.

한 저장소에서 사다리가 오르기 시작하면, 챔피언은 다음 핵심 저장소로 같은 순서를
반복합니다. 진단·채점은 전부 signal-only 라서 어떤 명령도 막지 않습니다 —
자세한 루브릭은 routed 정책 `policies/harness-readiness.md` 와
`policies/harness-maturity.md` 에 있습니다.
