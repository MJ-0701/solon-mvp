---
doc_id: sfs-current-product-shape-ko-8
title: "Capture 는 evidence primitive"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-05-25
parent: docs/ko/current-product-shape.md
summary: "Capture 는 SFS lifecycle 단계가 아니라 승인/waiver/결정/evidence 를 잃지 않기 위한 최소 기록 API"
load_when: "Read when docs/ko/current-product-shape.md routes to this section."
---
## Capture 는 evidence primitive

`sfs capture` 는 SFS lifecycle 단계가 아닙니다. 기본 흐름에 끼워 넣는 의식도 아닙니다.
승인, waiver, 결정, 리뷰 순서 override, blocker 분류, 외부 evidence 처럼 나중 gate 가 잃으면 안 되는
최소 사실만 현재 sprint `log.md` 와 `events.jsonl` 에 남기는 저수준 evidence primitive 입니다.

평소에는 `brainstorm.md`, `plan.md`, `implement.md`, `review.md`, `retro.md`, wiki checklist, report 가
각자 자기 내용을 소유합니다. `capture` 는 그 artifact 들에 이미 들어갈 수 있는 내용을 복제하지 않습니다.

```sh
sfs capture --kind review-order --gate 6 "Codex self-CPO first, then Gemini, then Claude."
sfs note "GitHub @codex review passed, but it is external evidence only."
```

`capture` 는 전체 대화 녹화기가 아닙니다. 나중에 review/retro 가 잃으면 안 되는 가장 작은
approval/evidence fact 만 남깁니다. 긴 prompt, 전체 대화, bridge/review scratch, command log 는
temporary artifact 나 cold archive 에 두고, core product context 에는 결론과 evidence path 만
남깁니다.
