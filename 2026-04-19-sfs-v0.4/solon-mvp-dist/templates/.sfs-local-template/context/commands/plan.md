---
id: sfs-command-plan
summary: Convert G0 into a measurable contract; do not repair missing brainstorm by guessing.
load_when: ["plan", "계획", "G1", "contract", "AC"]
---

# Plan

- Adapter-first: run `sfs plan`, then read the same sprint's `brainstorm.md`.
  Treat G0 `§1-§8` as source material, not decoration.
- If `brainstorm.md` is still draft or has unresolved blocking questions, do
  not smooth over them with assumptions. Ask 1-3 questions and keep the plan
  draft until shared intent is clear.
- G1 must carry the same AI-era fundamentals forward:
  - shared design concept becomes measurable requirements and explicit
    non-goals.
  - ubiquitous language becomes the terms used in AC, code, docs, UI labels,
    tests, and review notes.
  - feedback loops become binary AC with `verify by ...` evidence.
  - deep-module boundaries become public interfaces, artifact boundaries, or
    ownership slices.
  - gray-box delegation marks what the user/CEO must decide and what the AI
    worker may fill internally.
- A plan is not ready just because it is long. It is ready when an evaluator can
  independently check pass/partial/fail without reading the generator's mind.
- Do not run implementation automatically from G1. If the contract is ready,
  final `Next` may point to review or the first explicit implementation slice.
