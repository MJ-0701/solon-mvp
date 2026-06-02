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
- If the request expands wiki/RAG/graph/ingest/docs memory, run the Solon
  Advancement Scorecard before `ready-for-plan`: classify it as `product-core`,
  `product-supporting`, `wiki-tooling-deferred`, or `out-of-scope`. It counts as
  Solon advancement only when it improves intent capture, plan contracts, review
  evidence, handoff, or repeated-context retrieval without replacing human
  product judgment or source truth.
- Apply `policies/ai-work-intake-routing.md` before drafting questions. Gate 2
  should expose goal, materials, ask-back rule, and output format, then classify
  one-off, repeated, or batch workspace scope so the user is not forced to
  restate context or endure unnecessary ceremony.
- If the raw input contains expert notes, craft vocabulary, repeated "we do it
  this way" guidance, or a request to make a skill/playbook, load
  `policies/domain-knowledge-assets.md`. Gate 2 should identify the smallest
  reusable domain asset candidate and the source/owner/gap before planning.
- Apply AI-era fundamentals before setting `status: ready-for-plan`:
  - shared design concept: problem owner, current pain, success state, in/out
    scope, and at least two options are explicit.
  - ubiquitous language: key domain nouns, actors, states, and overloaded terms
    are named in the same words the product/code/docs should use.
    If those terms will outlive the sprint, seed or update
    `docs/solon/domain-map.md`; otherwise keep the glossary in `brainstorm.md`.
  - feedback loop seed: the likely test, smoke, review, preview, or manual
    inspection signal is named before planning work.
  - deep-module seed: important boundaries or public interfaces are sketched, or
    the non-code artifact boundary is named.
  - gray-box delegation: human-owned strategy/interface decisions are separated
    from AI-fillable internals.
- Run the Division Sub-agent Council before `ready-for-plan`: strategy-pm,
  dev, QA, design, infra, and taxonomy each records a one-line
  `division_subagent_ledger` finding, evidence/waiver, or `not-applicable`.
- For unfamiliar domains or large existing codebases, a read-only researcher
  pass may happen before plan. The researcher maps sources, domain terms,
  contradictions, and unknowns; it does not implement or approve quality.
- Non-developer initial setup proposal:
  - Do not require the user to know framework names such as Next.js, Spring,
    FastAPI, NestJS, React, Vue, or Nuxt.
  - Treat the user's plain-language goal as enough. They may never type a
    bootstrap command or know what stack they need.
  - If the brainstorm reveals that a new app/project skeleton would materially
    reduce friction, ask one plain-language consent question before plan:
    "초기 프로젝트 구성해드릴까요?"
  - If the user agrees, infer the smallest useful setup size from the goal
    (prototype/static page, small frontend app, app+API+persistence, or larger
    only after scope discussion). Use `sfs bootstrap "<plain-language goal>"`
    only as an agent-facing native-scaffolding handoff if it helps execution.
    The AI chooses the stack/tooling; Solon records only the useful operating
    context.
  - This proposal is optional. Do not block `ready-for-plan` only because a
    scaffold could exist; surface it when it would reduce user effort now.
- In `simple`, ask at most 2 blocking questions. In `normal`, ask 2-5. In
  `hard`, ask a compact but demanding round (usually 4-7) and record unresolved
  owner decisions instead of guessing. Keep `status: draft`; final `Next` is
  "answer questions, then brainstorm again".
- Deep-interview convergence: for ambiguous app/product asks, target
  `ambiguity <= 20%` before plan. A one-word "ㄱㄱ" is momentum, not readiness.
  Ask the compact battery that changes output: purpose (business/prototype/demo),
  domain/product, stack choice or AI recommends, must-have vs not-now features,
  done bar (core E2E/responsive/README), and desired detail depth. Persist the
  confirmed Q&A as the plan seed.
- For Gate 2 blocking choices, do not expose compact option bundles such as
  `A/A/A/C/C 확정`. If the user asks "권장안 다시 보여줘", restate the
  recommended path in plain language, include what would change under the
  alternatives, and use a natural confirmation phrase such as `권장안 그대로
  확정`.
- Only set `status: ready-for-plan` when `§6 Plan Seed` can drive measurable
  requirements, AC, risks, generator deliverables, and evaluator criteria.
- Never run `sfs plan` automatically from Gate 2. The user or next explicit command
  opens Gate 3 after the questions are answered.
