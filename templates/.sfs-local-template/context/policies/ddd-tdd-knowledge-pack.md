---
id: sfs-policy-ddd-tdd-knowledge-pack
summary: Product-level DDD/TDD baseline for scaffolds, plans, implementation, and review.
language: en
load_when:
  - DDD
  - TDD
  - domain model
  - test-first
  - aggregate
  - value object
  - product behavior
  - acceptance criteria
  - layered architecture
status: filled-v1
content_policy: "apply as a lightweight product-level floor, not as backend-only ceremony"
---

# DDD/TDD Knowledge Pack

This pack makes DDD-lite and TDD-lite operational at product level. It is active
when a task creates project structure, changes product behavior, introduces
domain terms, or touches acceptance criteria that should be proven by executable
evidence. Backend package layout is one application of this pack, not its scope.

## Activation Rules

- New product/app/backend scaffolds default to explicit product/domain behavior
  boundaries.
- Product behavior changes activate TDD-lite before implementation, whether the
  artifact is backend, frontend, CLI, data, docs, workflow, or integration.
- Domain states, events, aggregates, roles, money, PII, partner state, or
  persisted data activate stronger DDD/TDD checks.
- Brainstorm and plan work must name the product behavior, domain language, and
  first evidence candidate before worker handoff.
- For throwaway spikes, record the waiver and the smallest smoke evidence
  instead of pretending full TDD was done.

## DDD Floor

- Use the user's/product's canonical domain language in plan, code, tests, UI,
  logs, docs, and review evidence.
- Treat DDD as product-modeling discipline first: name actors, behaviors,
  states, rules, invariants, and ownership before choosing backend folders.
- Default backend/app layout is clean layered monolith:
  `domain`, `application`, `interfaces`, `infrastructure`.
- `domain` owns business concepts, invariants, aggregate/entity/value-object
  names, state transitions, and domain events. It should not depend on
  framework, HTTP, DB, queue, or vendor adapters.
- `application` owns use cases and orchestration. It coordinates transactions
  and ports, but does not hide domain invariants in generic service names.
- `interfaces` owns controllers, DTOs, CLI/UI adapters, request validation, and
  presentation mapping.
- `infrastructure` owns persistence, external clients, queues, clocks, files,
  and framework-specific adapters.
- Every product-bearing layer uses the same discipline. UI domain/use-case/
  state models, backend domain/application services, CLI use cases, migration or
  backfill policies, and document/workflow policy owners must be named when they
  carry product behavior. Broad entrypoints such as UI bootstraps, routers, root
  components, hooks/stores/effects, controllers, jobs, repositories, DTO
  mappers, CLI flags, scripts, migrations, docs wording, observability glue, and
  external adapters must not become the quiet home for policy unless a
  small-scope waiver says why.
- Natural-language SFS/DDD/TDD requests activate the same floor. Reconcile the
  user wording, latest handoff/docs, active sprint, and wiki/DDD maps; stale
  approved sprint state does not override the evidence-backed session intent.
- Broad-entrypoint growth that adds product behavior during DDD/TDD work is a
  review finding unless boundary extraction or approved deferral is recorded.
- Controllers, jobs, repositories, and external adapters must not become the
  place where core business rules live.
- Product rules must also not disappear into UI labels, docs wording, CLI flags,
  migrations, seed scripts, or workflow glue without an explicit domain term and
  verification path.
- If a bounded context, aggregate boundary, or canonical term will live beyond
  the sprint, update or point to `docs/solon/domain-map.md`.

## TDD Floor

- Before implementation, prefer a failing acceptance, regression, or
  characterization test that names the domain behavior.
- If test-first is impractical, record the reason, the smallest alternate smoke
  evidence, and the missing guard as debt or follow-up.
- Unit tests should prove domain invariants and value behavior; integration or
  contract tests should prove adapter, transaction, persistence, API, or event
  semantics.
- Product-level evidence may be a domain unit test, API/contract test, UI flow
  smoke, CLI golden output, migration dry-run, docs assertion, release verifier,
  or manual walkthrough when that is the smallest honest signal.
- Tests should reinforce domain language, not only implementation branch names.
- Completion evidence must map each AC to a test, smoke, manual walkthrough, or
  explicit waiver.

## Review Questions

- Does the work preserve product-level DDD/TDD: domain language, behavior
  boundary, evidence-first planning, and implementation boundaries?
- Are domain invariants in `domain`/use-case logic instead of controllers,
  repositories, DTO mappers, jobs, or external adapters?
- If the artifact is not backend code, where is the product rule named and how
  is it verified?
- If broad entrypoints changed, is product behavior in a named domain/use-case/
  state boundary rather than hidden in UI bootstraps/router/root components/
  hooks/stores/effects, controllers, jobs, repositories, DTO mappers, CLI flags,
  scripts, migrations, docs wording, observability glue, or external adapters?
- Did the agent detect handoff/user-intent versus active-sprint conflicts
  before continuing implementation?
- Are canonical terms, aggregate/entity/value-object/event names consistent?
- Was a failing or characterization test written before or with the code?
- If TDD was waived, is the reason explicit and is there alternate evidence?
- Does every AC have fresh evidence tied to the changed artifact?

## Findings

- Return partial when a new product/code scaffold lacks explicit domain or
  behavior boundaries and no waiver explains why.
- Return partial when product behavior changes have no test-first,
  characterization, smoke, or explicit alternate verification evidence.
- Return partial when product rules are buried in broad entrypoints without a
  named domain/use-case/state boundary and evidence.
- Return partial when natural-language SFS was only decorative or when a
  handoff/user-intent conflict was escalated to the user despite available
  evidence.
- Return fail when business invariants are buried in adapters and that creates
  data-loss, money, PII, or partner-state risk.

## DT-AIERA - AI-Era Design/Ownership Lens

Review-lens prompts distilled from 2026-05/06 practitioner talks. Discussion
checks for AI-assisted design ownership, not hard rules; cited claims are
speaker-time assertions.

- DT-AIERA-001: AI-generated code still needs a human owner. Business-critical
  code should not be blindly delegated to AI; ask whether the owner can explain
  and defend even generated code before it passes review. Unexplained generated
  code is a design-debt finding, not a completed change.
- DT-AIERA-002: Spec/test = human, implementation = AI is the closed-loop framing
  already recorded in enterprise-evidence (§AI-Era Closed-Loop Evidence). The
  DDD/TDD floor is that human-owned spec/behavior surface; reference that lens
  rather than restating it here.
- DT-AIERA-003: Development is wider than coding. For AI-assisted work, verify
  the requirements, screen or sequence evidence, tests, QA, release, and
  monitoring loop as part of the product behavior contract; code-only completion
  is a partial signal.
