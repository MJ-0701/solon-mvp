---
doc_id: sfs-current-product-shape-en-13
title: "Design.md And Anti-AI-Slop Guardrails"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-08-29
parent: docs/en/current-product-shape.md
summary: "Design.md And Anti-AI-Slop Guardrails"
load_when: "Read when docs/en/current-product-shape.md routes to this section."
---
## Design.md And Anti-AI-Slop Guardrails

Design/frontend work treats `design.md` or
`docs/solon/design.md` as the AI-readable design-system contract. The file is a
small contract for colors, typography, spacing, radius, shadow, component
variants, icon style, forbidden values, and rationale.

## Beginner Design Intake

Load the beginner route with `sfs context cat policies/design-intake-flow`. Use
its six-question brief only for a design-inexperienced/help-requested brief or
broad new screen, workflow, or redesign without a confirmed seed. A confirmed
seed goes straight to implementation; a minor edit to existing visible UI keeps
the established pattern and records a narrow `UNVERIFIED` gap only when needed.

Use Figma when available, then a screenshot or reference page. When none exists,
propose a safe starter direction: existing system first, otherwise a calm
task-first layout with readable type, one icon family, restrained accent, regular
spacing, modest radius, and no copied treatment or generic gradient. The seed
records tokens, component and icon rules, prohibited values, and reference
rationale. Ask once for confirmation when a person is available. If nobody
confirms, or work is noninteractive/CI, record the proposed seed or gap as
`UNVERIFIED`, never `Ready`; that evidence state does not create a new hard gate.
Implement from listed or established values and collect desktop and mobile
evidence.

The common AI failure mode is regression toward average-looking UI. If every
screen invents new colors, spacing, radius, icon weights, or generic SaaS
gradients, the feature can work while the product loses taste and identity.
Solon's design review treats that as AI-slop risk and checks token drift,
Korean typography fit, and desktop/mobile screenshot evidence.

Wanted Montage-style components, a coherent icon family such as Coolicons, and
a Korean-capable font such as Pretendard can be useful starter references for
Korean products. They are starting points, not vendor lock-in. If an existing
product design system exists, it wins.
