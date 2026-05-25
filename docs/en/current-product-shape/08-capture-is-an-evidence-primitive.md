---
doc_id: sfs-current-product-shape-en-8
title: "Capture Is An Evidence Primitive"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-05-25
parent: docs/en/current-product-shape.md
summary: "Capture is not an SFS lifecycle step; it is the smallest durable record for approval, waiver, decision, blocker, or evidence facts."
load_when: "Read when docs/en/current-product-shape.md routes to this section."
---
## Capture Is An Evidence Primitive

`sfs capture` is not an SFS lifecycle phase, gate, or default ritual between
commands. It is a low-level evidence primitive for the smallest durable fact a
later gate must remember: explicit user approval, waiver, decision,
review-order override, blocker classification, scope change, or accepted
external evidence.

Normal artifacts keep their own content: `brainstorm.md`, `plan.md`,
`implement.md`, `review.md`, `retro.md`, wiki checklists, and reports. Capture
does not duplicate content that already belongs in those artifacts.

```sh
sfs capture --kind review-order --gate 6 "Codex self-CPO first, then Gemini, then Claude."
sfs note "GitHub @codex review passed, but it is external evidence only."
```

`capture` is not a full transcript recorder. Store only the smallest approval
or evidence fact that review or retro would lose if it stayed in chat memory.
Prompt bodies,
raw transcripts, bridge/review scratch, and long command logs stay in temporary
artifacts or cold archives; core product context keeps conclusions and evidence
paths only.
