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
- State material assumptions, tradeoffs, explicit non-goals, and a simpler path
  when one exists. Do not hide unresolved decisions inside confident wording.
- Gate 3 must carry the same AI-era fundamentals forward:
  - shared design concept becomes measurable requirements and explicit
    non-goals.
  - ubiquitous language becomes the terms used in AC, code, docs, UI labels,
    tests, and review notes.
    If canonical terms, forbidden aliases, actors, states, or domain boundaries
    will matter beyond this sprint, point the plan at `docs/solon/domain-map.md`
    or add a small update to that file as an implementation artifact.
  - feedback loops become binary AC with `verify by ...` evidence.
  - deep-module boundaries become public interfaces, artifact boundaries, or
    ownership slices.
  - gray-box delegation marks what the user/CEO must decide and what the AI
    worker may fill internally.
- A plan is not ready just because it is long. It is ready when an evaluator can
  independently check pass/partial/fail without reading the generator's mind.
- Each implementation slice should carry a concrete checklist item and
  `verify by ...` evidence. In SFS, that checklist belongs in sprint
  workbench artifacts such as `plan.md` or `implement.md`, not as mandatory
  root-level `checklist.md` / `context-notes.md` files.
- For high-risk plans, large codebases, or unfamiliar domains, request a plan
  review before implementation. Use `sfs review --gate 3` with the appropriate
  lens and an independent executor when available; the plan author should not be
  the only evaluator.
- If a researcher pass produced findings, summarize only the durable result in
  the plan: sources checked, domain terms, contradictions, and remaining
  unknowns. Do not copy the full research transcript into the plan.
- Load `policies/knowledge-pack-router.md` first, or `policies/knowledge-pack-router.ko.md`
  for Korean preference. Proceed to matching division packs from its mapping.
- If backend/JVM/Spring/JPA/transaction/batch/integration/DevOps/AWS risk is in
  scope, record matching ids from `policies/backend-knowledge-pack.md` or
  `policies/backend-knowledge-pack.ko.md` only after router selection.
- If strategy-pm, QA, design/frontend, infra, management-admin, or taxonomy
  signals are in scope, record matching ids from the matching
  `policies/*-knowledge-pack.md` or `policies/*-knowledge-pack.ko.md` only after
  router selection. Apply only the compact guidance for matching ids; do not
  promote every pack into a blocker.
- Use the backend pack as a scale router: first MVP gets minimal guardrails;
  money, PII, partner state, batch, MQ, or production exposure increases depth.
- Do not run implementation automatically from Gate 3. If the contract is ready,
  final `Next` may point to review or the first explicit implementation slice.
