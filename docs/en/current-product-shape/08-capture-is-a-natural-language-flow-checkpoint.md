---
doc_id: sfs-current-product-shape-en-8
title: "Capture Is A Natural-Language Flow Checkpoint"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-05-22
parent: docs/en/current-product-shape.md
summary: "Capture Is A Natural-Language Flow Checkpoint"
load_when: "Read when docs/en/current-product-shape.md routes to this section."
---
## Capture Is A Natural-Language Flow Checkpoint

During SFS work, implementation direction, review order, exceptions/waivers,
blockers, and evidence can change in natural conversation. Before the next
command, record those turns with `sfs capture` so the current sprint `log.md`
and `events.jsonl` keep the flow state.

```sh
sfs capture --kind review-order --gate 6 "Codex self-CPO first, then Gemini, then Claude."
sfs note "GitHub @codex review passed, but it is external evidence only."
```

`capture` is not a full transcript recorder. Store only the smallest checkpoint
that review or retro would lose if it stayed in chat memory. Prompt bodies,
raw transcripts, bridge/review scratch, and long command logs stay in temporary
artifacts or cold archives; core product context keeps conclusions and evidence
paths only.

