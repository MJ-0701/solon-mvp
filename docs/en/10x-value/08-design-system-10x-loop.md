---
doc_id: sfs-10x-value-en-8
title: "Design System 10x Loop"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-05-22
parent: docs/en/10x-value.md
summary: "Design System 10x Loop"
load_when: "Read when docs/en/10x-value.md routes to this section."
---
## Design System 10x Loop

In the AI coding era, code generation is no longer the moat. The user's first
impression comes from the visible surface: rhythm, spacing, typography, icon
style, and consistency. The design division's 10x value is not drawing more
pixels. It is building the system that AI must follow and reviewing when AI
regresses toward generic average output.

For visible UI work, Solon treats `design.md` or `docs/solon/design.md` as the
design contract. It should define colors, fonts, type scale, spacing, radius,
shadow, component variants, icon style, forbidden values, and rationale. During
implementation, AI reads that contract first. During review, the evaluator looks
for token drift outside that contract.

| Design practice | Solon meaning | Why it matters for AI |
|---|---|---|
| `design.md` | AI-readable design-system contract | Screens stop reinventing colors, spacing, and radius |
| Token drift check | Inspect arbitrary hex values, font sizes, spacing, and icon styles | AI-slop signals become review findings |
| Korean typography | Check Korean-capable fonts, line-height, and long-label fit | Korean UI is not squeezed into English defaults |
| Coherent icon family | Use one icon system or the existing product icon system | The surface keeps one visual voice |
| Screenshot evidence | Verify desktop/mobile fit visually | Review judges user experience, not plausibility |

Wanted Montage-style components, a coherent icon family such as Coolicons, and
a Korean-capable font such as Pretendard can be useful starter references for
Korean products. The point is not vendor lock-in. The point is that the design
system is the asset. If an existing product design system exists, it wins. If
not, start with a small `design.md` seed.

