---
doc_id: sfs-product-readme-1
title: "왜 Solon인가"
visibility: oss-public
doc_type: product-intro
language: ko
updated: 2026-05-22
parent: README.md
summary: "왜 Solon인가"
load_when: "Read when README.md routes to this section."
---
## 왜 Solon인가

AI 로 만드는 속도는 이미 빠릅니다. 문제는 속도가 아니라 흐름입니다.

- 대화는 길어지는데 결정은 어디에도 남지 않습니다.
- AI 가 많이 바꿨지만 무엇을 통과 기준으로 봐야 할지 흐려집니다.
- 구현자는 자기 결과를 스스로 승인하고, review 는 뒤늦게 몰립니다.
- Claude, Codex, Gemini 를 같이 쓰면 각 agent 가 서로 다른 프로젝트를 보는 것처럼 움직입니다.
- sprint 가 끝나도 다음 사람이 이어받을 한 장짜리 맥락이 없습니다.

Solon 은 이 문제를 앱 generator 로 풀지 않습니다. 앱 뼈대는 각 프레임워크와 AI 가 가장 잘하는
방식으로 만들고, Solon 은 그 다음부터의 제품 운영을 맡습니다.

Wiki, RAG, graph, ingest 같은 기억 장치는 이 흐름을 더 정확하고 빠르게 만들기 위한 보조 도구일 뿐이며, Solon 의 제품 방향은 여전히 SFS flow, 사람의 product judgment, 검증 가능한 계약, review/handoff 에 둡니다.

```text
fuzzy idea
-> shared intent
-> scoped sprint
-> acceptance criteria
-> implementation slice
-> independent review
-> handoff / retro
```

Solon 을 쓰면 AI 는 더 멀리 혼자 달리는 대신, 사용자가 이해할 수 있는 작은 계약과 검증 루프 안에서
움직입니다. 결과는 단순히 더 많은 output 이 아니라, 다음 변경도 믿고 이어갈 수 있는 iteration 입니다.

Founder 관점에서 Solon 은 "내가 전부 prompt 하는 사람"을 "AI 팀을 지휘하는 사람"으로 바꿉니다.
Idea 에서는 의도와 포기할 것을 묻고, MVP 에서는 가장 작은 검증 가능한 slice 로 줄이고, Launch 에서는
보안/UX/review evidence 를 남기며, Scale 에서는 같은 루프를 더 짧고 안전하게 반복합니다.

더 깊은 설명은 [Solon 10x 가치](./docs/ko/10x-value.md)에 정리했습니다.

---
