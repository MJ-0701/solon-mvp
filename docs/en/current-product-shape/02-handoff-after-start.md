---
doc_id: sfs-current-product-shape-en-2
title: "Handoff After Start"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-05-22
parent: docs/en/current-product-shape.md
summary: "Handoff After Start"
load_when: "Read when docs/en/current-product-shape.md routes to this section."
---
## Handoff After Start

`sfs start "<goal>"` creates the sprint workspace. For new product exploration,
brainstorm is usually the next useful step, so the successful start output shows
the depth options even if the user has not read the guide.

```text
next: sfs brainstorm --simple "..."  # quick cleanup
      sfs brainstorm "..."           # default normal thinking scaffold
      sfs brainstorm --hard "..."    # product-owner hard training
```

The user still types `sfs brainstorm`. Solon simply exposes the available
depth options for the shape of the work.

