---
doc_id: sfs-current-product-shape-en-24
title: "Top-down learning guide — for a one-person operator"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-06-06
parent: docs/en/current-product-shape.md
summary: "A problem-first entry + AI question battery + understanding-verification protocol for an operator to learn a new domain fast."
load_when: "Read when an operator needs to learn a new domain/codebase fast to drive Solon work."
---
## Top-down learning guide — for a one-person operator

A one-person operator constantly meets new domains (a codebase, tax, marketing,
infra). Building bottom-up from fundamentals burns out before you reach the real
work. In the AI era, **problem → needed-knowledge (top-down)** is faster — but
top-down is not *skipping* understanding, it is *reversing the order* of it.
Reject vibe-coding: you must read the output, understand it, and hold a clear
opinion. (Source: lecture note 20 — figures/cases are talk-time claims,
by-reference.)

### The four-step protocol

1. **Problem-first entry.** Ask the AI for a full working example (code, report,
   workflow), then run and observe it first. Run it and break it even before you
   understand it.
2. **AI question battery.** Drill into the role of each part:
   - "What breaks if this part is removed?"
   - "What is different from the prior approach?" (for a paper/doc, start from
     this difference list — do not read cover-to-cover first)
   - "Why this way, and what were the alternatives?"
   - "Explain it like I'm 12" to get an intuition-anchoring analogy.
3. **Verify understanding.** **Explain your understanding back** to the AI and
   let it correct you. If you cannot explain it, you do not understand it yet.
4. **Form an opinion.** The closer to the frontier, the more fully you must
   understand and judge. Understanding and ownership stay human; the AI is an
   accelerator.

### Where it meets the Solon workflow

- Running this protocol **before brainstorm / plan** raises the question quality
  at Gates 2-3.
- Record the operator's learning style (explanation depth / technical depth) in
  `operator-context.md` (the user layer) so the agent explains at that level.
- Restate-and-clarify before starting
  (`policies/work-delegation-and-startup.md`) is the same idea as step 2 — when
  it is ambiguous, ask first.
</content>
