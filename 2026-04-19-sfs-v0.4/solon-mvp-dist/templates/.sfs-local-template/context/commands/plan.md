---
id: sfs-command-plan
summary: Convert Gate 2 into a measurable contract; do not repair missing brainstorm by guessing.
load_when: ["plan", "계획", "Gate 3", "contract", "AC"]
---

# Plan

- Adapter-first: run `sfs plan`, then read the same sprint's `brainstorm.md`.
  Treat Gate 2 `§1-§8` as source material, not decoration.
- If `brainstorm.md` is still draft or has unresolved blocking questions, do
  not smooth over them with assumptions. Ask 1-3 questions and keep the plan
  draft until shared intent is clear.
- Gate 3 must carry the same AI-era fundamentals forward:
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
- Load `policies/knowledge-pack-router.md` first, or `policies/knowledge-pack-router.ko.md`
  for Korean preference. Proceed to matching division packs from its mapping.
- If backend/JVM/Spring/JPA/transaction/batch/integration/DevOps/AWS risk is in
  scope, record matching ids from `policies/backend-knowledge-pack.md` or
  `policies/backend-knowledge-pack.ko.md` only after router selection.
- If strategy-pm, QA, design/frontend, infra, or taxonomy signals are in scope,
  record matching ids from the matching `policies/*-knowledge-pack.md` or
  `policies/*-knowledge-pack.ko.md` only after router selection. These packs are
  activation routers, not full guidance.
- Use the backend pack as a scale router: first MVP gets minimal guardrails;
  money, PII, partner state, batch, MQ, or production exposure increases depth.
- Do not run implementation automatically from Gate 3. If the contract is ready,
  final `Next` may point to review or the first explicit implementation slice.
