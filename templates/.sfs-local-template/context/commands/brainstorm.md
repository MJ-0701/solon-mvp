---
id: sfs-command-brainstorm
summary: Build shared understanding before plan; raw requirements are not a contract.
load_when: ["brainstorm", "브레인스토밍", "requirements", "요구사항", "Gate 2", "hard", "simple"]
---

# Brainstorm

- Adapter-first: run `sfs brainstorm ...`, preserve raw input in `§8 Append Log`,
  then refine `brainstorm.md` as Solon CEO.
- Honor the brainstorm depth from adapter stdout/frontmatter:
  - `simple`: quick requirement cleanup. Summarize raw requirements, call out light gaps, ask
    0-2 questions only when plan would otherwise be misleading. You may carry
    explicit assumptions into plan seed.
  - `normal`: default owner-thinking scaffold. Ask 2-5 focused questions about
    core decisions, contradictions, priority, success criteria, feedback loop,
    or scope. Keep momentum, but make the user think.
  - `hard`: product-owner hard training. Keep `status: draft` while important
    owner decisions are missing; interrogate intent, contradictions, priorities,
    tradeoffs, validation, boundaries, and terminology. Do not convert "ㄱㄱ" or
    vague agreement into plan readiness when decisions are unresolved.
- Gate 2 exists to prevent spec-to-code drift. Do not accept raw requirements as a
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
- In `simple`, ask at most 2 blocking questions. In `normal`, ask 2-5. In
  `hard`, ask a compact but demanding round (usually 4-7) and record unresolved
  owner decisions instead of guessing. Keep `status: draft`; final `Next` is
  "answer questions, then brainstorm again".
- Only set `status: ready-for-plan` when `§6 Plan Seed` can drive measurable
  requirements, AC, risks, generator deliverables, and evaluator criteria.
- Never run `sfs plan` automatically from Gate 2. The user or next explicit command
  opens Gate 3 after the questions are answered.
