---
id: sfs-command-brainstorm
summary: Build shared understanding before plan; raw requirements are not a contract.
load_when: ["brainstorm", "브레인스토밍", "requirements", "요구사항", "G0"]
---

# Brainstorm

- Adapter-first: run `sfs brainstorm ...`, preserve raw input in `§8 Append Log`,
  then refine `brainstorm.md` as Solon CEO.
- G0 exists to prevent spec-to-code drift. Do not accept raw requirements as a
  finished plan; interrogate intent until the next gate has enough shape.
- Apply AI-era fundamentals before setting `status: ready-for-plan`:
  - shared design concept: problem owner, current pain, success state, in/out
    scope, and at least two options are explicit.
  - ubiquitous language: key domain nouns, actors, states, and overloaded terms
    are named in the same words the product/code/docs should use.
  - feedback loop seed: the likely test, smoke, review, preview, or manual
    inspection signal is named before planning work.
  - deep-module seed: important boundaries or public interfaces are sketched, or
    the non-code artifact boundary is named.
  - gray-box delegation: human-owned strategy/interface decisions are separated
    from AI-fillable internals.
- Ask 1-3 blocking questions when any of those are missing. Keep
  `status: draft`; final `Next` is "answer questions, then brainstorm again".
- Only set `status: ready-for-plan` when `§6 Plan Seed` can drive measurable
  requirements, AC, risks, generator deliverables, and evaluator criteria.
- Never run `sfs plan` automatically from G0. The user or next explicit command
  opens G1 after the questions are answered.
