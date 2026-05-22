---
doc_id: sfs-10x-value-ko-5
title: "병렬 agent 10x 루프"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-05-22
parent: docs/ko/10x-value.md
summary: "병렬 agent 10x 루프"
load_when: "Read when docs/ko/10x-value.md routes to this section."
---
## 병렬 agent 10x 루프

여러 agent 를 동시에 쓰는 것은 "많이 시키면 빨라진다"가 아닙니다. Solon 에서 병렬성의 10x 는
작업을 **커밋 단위로 설명 가능한 lane** 으로 나누고, 서로 다른 agent 가 서로의 산출물을
검토하게 만드는 데서 나옵니다.

기본값은 Single Agent 입니다. `--agent-mode parallel` 은 plan 이 이미 독립 lane 으로 나뉘고,
각 lane 의 files_scope 가 겹치지 않으며, lane 별 commit message 를 한 문장으로 말할 수 있을 때만
사용합니다. 그 문장을 못 쓰면 아직 나눌 준비가 안 된 것입니다.

그 commit message 는 사용자의 native 언어 또는 workspace 언어로 써야 합니다. 한국어 사용자의
작업이면 lane 이름과 커밋 메시지도 한국어로 읽혀야 하며, 영어 커밋은 repo 규칙이나 사용자의
native 언어가 영어일 때만 기본값입니다.

```text
fixed plan
→ commit-unit lanes
→ disjoint files_scope
→ lane verification
→ agent cross review
→ Gate 6 review
```

이 구조가 있으면 Codex, Claude, Gemini 를 동시에 써도 작업 속도와 품질 체크가 같이 올라갑니다.
구조가 없으면 병렬성은 충돌과 중복 review 만 늘립니다.

