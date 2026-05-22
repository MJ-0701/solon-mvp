---
doc_id: sfs-current-product-shape-en-13
title: "Design.md And Anti-AI-Slop Guardrails"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-05-22
parent: docs/en/current-product-shape.md
summary: "Design.md And Anti-AI-Slop Guardrails"
load_when: "Read when docs/en/current-product-shape.md routes to this section."
---
## Design.md And Anti-AI-Slop Guardrails

Design/frontend work treats `design.md` or
`docs/solon/design.md` as the AI-readable design-system contract. The file is a
small contract for colors, typography, spacing, radius, shadow, component
variants, icon style, forbidden values, and rationale.

The common AI failure mode is regression toward average-looking UI. If every
screen invents new colors, spacing, radius, icon weights, or generic SaaS
gradients, the feature can work while the product loses taste and identity.
Solon's design review treats that as AI-slop risk and checks token drift,
Korean typography fit, and desktop/mobile screenshot evidence.

Wanted Montage-style components, a coherent icon family such as Coolicons, and
a Korean-capable font such as Pretendard can be useful starter references for
Korean products. They are starting points, not vendor lock-in. If an existing
product design system exists, it wins.

