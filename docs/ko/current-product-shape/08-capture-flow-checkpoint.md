---
doc_id: sfs-current-product-shape-ko-8
title: "Capture 는 자연어 flow checkpoint"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-05-22
parent: docs/ko/current-product-shape.md
summary: "Capture 는 자연어 flow checkpoint"
load_when: "Read when docs/ko/current-product-shape.md routes to this section."
---
## Capture 는 자연어 flow checkpoint

SFS 작업 중 구현 방향, 리뷰 순서, 예외/waiver, blocker, evidence 는 자연어 대화로 바뀔 수 있습니다.
그런 말은 다음 명령 전에 `sfs capture` 로 현재 sprint `log.md` 와 `events.jsonl` 에 남깁니다.

```sh
sfs capture --kind review-order --gate 6 "Codex self-CPO first, then Gemini, then Claude."
sfs note "GitHub @codex review passed, but it is external evidence only."
```

`capture` 는 전체 대화 녹화기가 아닙니다. 나중에 review/retro 가 잃으면 안 되는 가장 작은
flow checkpoint 만 남깁니다. 긴 prompt, 전체 대화, bridge/review scratch, command log 는
temporary artifact 나 cold archive 에 두고, core product context 에는 결론과 evidence path 만
남깁니다.

