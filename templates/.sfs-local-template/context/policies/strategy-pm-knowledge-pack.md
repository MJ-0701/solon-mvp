---
id: sfs-policy-strategy-pm-knowledge-pack
summary: Strategy/PM topic and proposition inventory for SFS lens activation.
load_when:
  - strategy-pm
  - product
  - roadmap
  - scope
  - stakeholder
  - SLA
  - business
  - rollout
status: filled-v1
content_policy: "compact operating guidance; apply only matching ids and keep strategy depth proportional to commitment risk"
---

# Strategy/PM Knowledge Pack Inventory

This file is a compact filled guidance pack for Strategy/PM work. Use it to
decide which product, scope, rollout, commitment, and stakeholder checks are
active for a sprint, plan, review, or release. Apply only the matching ids.

## Activation Rules

- Activate only the propositions that match the project size and decision risk.
- Do not turn every small feature into a roadmap or governance exercise.
- Product commitments, partner commitments, pricing, SLA, user promises, and
  launch communication increase Strategy/PM depth.
- When the work is SFS product development, all core divisions plus the
  cross-cutting taxonomy lens are eligible.

## PM-SCALE - Review Depth By Project Size

- PM-SCALE-001: A throwaway experiment needs a hypothesis and stop condition, not a full business case.
- PM-SCALE-002: A first MVP needs target user, problem, non-goals, success signal, and release boundary.
- PM-SCALE-003: First production exposure needs rollback, support, communication, and owner clarity.
- PM-SCALE-004: Partner-facing work needs responsibility matrix, SLA/SLO, escalation path, and change notice rules.
- PM-SCALE-005: Paid, regulated, or trust-sensitive work needs risk acceptance and audit-friendly decision records.
- PM-SCALE-006: Multi-team work needs dependency map, milestone ownership, and decision cadence.
- PM-SCALE-007: Platform/product-line work needs compatibility, migration, deprecation, and adoption strategy.

## PM-PROP - Proposition Inventory

- PM-PROP-001: Shared intent must state the user, problem, business reason, expected customer-behavior outcome, and winning theory.
- PM-PROP-002: Scope must include non-goals so AI workers do not expand the wrong surface.
- PM-PROP-003: Acceptance criteria must be measurable by an evaluator without reading the generator's mind.
- PM-PROP-004: Prioritization must name tradeoffs, opportunity cost, and what is deliberately deferred.
- PM-PROP-005: Stakeholder promises must be separated from internal implementation preferences.
- PM-PROP-006: Partner responsibilities must be explicit for ownership, timing, error handling, and support.
- PM-PROP-007: SLA/SLO, RTO/RPO, maintenance windows, and support hours are product commitments, not only infra details.
- PM-PROP-008: Rollout must define audience, gates, kill switch, fallback, and communication channel when users are affected.
- PM-PROP-009: Roadmap items must identify dependencies, sequencing, and decision points.
- PM-PROP-010: Cost, pricing, and unit economics become active when runtime or vendor spend changes materially.
- PM-PROP-011: Metrics must distinguish leading indicators, lagging outcomes, guardrails, and vanity numbers.
- PM-PROP-012: Risk register entries must include assumption, likelihood, impact, owner, and review date.
- PM-PROP-013: Product decisions need ADR or decision-log evidence when they affect future compatibility.
- PM-PROP-014: User feedback loops must say who reviews feedback and what action threshold changes the plan.
- PM-PROP-015: Release notes and stakeholder updates must match the actual user-visible change.
- PM-PROP-016: Deprecation needs notice period, replacement path, compatibility guarantee, and sunset evidence.
- PM-PROP-017: Support and CS readiness become active when users can be blocked or confused by the change.
- PM-PROP-018: Experiments need hypothesis, segment, measurement window, and failure interpretation.

## PM-FILL - Operating Guidance

### PM-FILL-INTENT - Shared Intent

- Write the user, problem, business reason, expected customer-behavior outcome, and winning theory in one compact
  paragraph before expanding scope. If one of those five parts is missing, the
  plan is still guessing.
- Separate user-visible promise from internal implementation preference. A
  user promise belongs in AC or release notes; implementation preference belongs
  in design or implementation notes.
- Name the non-goals. For AI-assisted work, non-goals prevent workers from
  "helpfully" expanding into adjacent product surfaces.

### PM-FILL-SCOPE - Scope And Tradeoff

- Every scope decision should name what is included, what is excluded, why now,
  and what signal would reopen the excluded work.
- If a task touches install, upgrade, release, public docs, pricing, support, or
  partner behavior, treat it as a product commitment even when the file change
  looks small.
- A deferral is valid only when it has an owner, trigger, or explicit "not in
  this product line" rationale.

### PM-FILL-AC - Acceptance Contract

- Acceptance criteria should be checkable by a reviewer who did not participate
  in the implementation.
- AC should state evidence form: command output, screenshot, generated file,
  release artifact, user flow, metric, or decision record.
- When the work is non-code, AC still exists: docs clarity, terminology
  consistency, package inclusion, support handoff, or user-facing copy can be
  verified.

### PM-FILL-ROLLOUT - Launch And Communication

- Release notes must match actual user-visible behavior. Do not put internal
  implementation details in the user note unless they change how the user acts.
- Rollout needs audience, entry point, fallback, support owner, and stop
  condition when users can be blocked or confused.
- For existing users, include migration path, compatibility expectation, and
  what the user can ignore safely.

### PM-FILL-METRICS - Feedback And Decision Cadence

- A useful metric states actor, action, time window, baseline, and decision it
  informs. A number without a decision is vanity.
- Feedback loops need owner and threshold. "Collect feedback" is not a loop
  until someone knows when to change the plan.
- For experiments, record hypothesis, segment, measurement window, success
  threshold, and what a negative result means.

## PM-REVIEW - Review Questions

- Can a reviewer explain the user value without reading implementation notes?
- Are non-goals explicit enough to stop adjacent-scope expansion?
- Does each AC have concrete evidence and an owner?
- Does the release/user-facing message match what actually changed?
- Are deferred items intentionally parked, not merely forgotten?

## PM-EVIDENCE - Suggested Evidence

- One-paragraph shared-intent statement.
- AC table with evidence command/path/result.
- Scope ledger: included, excluded, deferred, reason.
- Release note or stakeholder update draft when users are affected.
- Decision log for compatibility, pricing, SLA, partner, or migration choices.

## PM-GAP - Deepening Slots

- PM-GAP-001: Pricing and packaging decision framework.
- PM-GAP-002: Partner negotiation and responsibility matrix templates.
- PM-GAP-003: Roadmap sequencing and dependency scoring.
- PM-GAP-004: Launch communication and release-note quality rubric.
- PM-GAP-005: User research synthesis and feedback triage.
- PM-GAP-006: Product risk register examples.
- PM-GAP-007: Adoption and migration playbook for existing users.
- PM-GAP-008: Decision log templates for AI-assisted product work.

## PM-AIERA - AI-Era Planning Lens

Review-lens prompts distilled from 2026-05 practitioner talks. These are
discussion checks for plan/scope/decision work, not hard rules. Treat any
cited multiplier, vendor, or model claim as a speaker-time assertion and
verify before acting.

- PM-AIERA-001: Separate "code-generation speed" from "engineering throughput".
  Faster code output does not mean faster integration, review, test, or
  release. When planning an AI-accelerated effort, ask: if output grows 10x,
  what breaks first — review capacity, test runtime, infra, or token budget?
- PM-AIERA-002: Use a two-question systems lens on each plan — "Why?" (current
  understanding) and "What if?" (future/second-order effects) — before
  committing scope.
- PM-AIERA-003: Frame AI adoption as "maximize collaborative productivity",
  not "replacement ROI". Treat "how many people does it cut?" as an
  anti-pattern; prefer staged internal-first rollout and growing the reviewers
  who keep humans in the loop.
- PM-AIERA-004: Clarify requirements before building. "Two questions up front
  beat five fixes later" — ambiguous work gets a question or spec lock before
  start, not silent assumptions.
- PM-AIERA-005: Make the "good opportunity" axes explicit when weighing a
  direction (work, money, time, growth; future upside over present comfort) —
  useful for solo-operator career and business-direction brainstorming.
- PM-AIERA-006: Run a bias checklist before trusting an analysis or backtest —
  survivorship, look-ahead, data-snooping, and overfitting — so a confident
  number is not mistaken for a sound decision.
- PM-AIERA-007: Check that a request carries a four-element shape — goal,
  acceptance criteria, forbidden moves, verification method. This is the concrete
  structure behind PM-AIERA-004's spec lock; ask whether the verification
  criterion is embedded so the agent can self-check (flowcheck/self-CPO) instead
  of waiting for review.
- PM-AIERA-008: Probe problem depth before scoping. Do not stop at "it is hard";
  ask why it is hard down to the root cause. A brainstorm/plan entry should
  carry a one-line root-cause statement, paired with ask-first.
- PM-AIERA-009: Ask whether the option set is curated rather than infinite. When
  options explode, three or four well-chosen ones carry more value — mirror this
  in AskUserQuestion by capping options and leading with a recommendation.
- PM-AIERA-010: Ask where the automation boundary sits. Roughly 70-80% can be
  automated, but the last ~20% needs human judgment; an operator's leverage is
  that judgment, not the volume of generated output. Name where human-in-the-loop
  sits for the task.
- PM-AIERA-011: For trust-sensitive domains, deployment and data location are
  part of the product promise. Ask whether local-first, cloud, sync, backup, and
  migration choices match the user's fear model, not only the technical security
  model.
- PM-AIERA-012: Separate early-adopter feature requests from broader-market
  anxiety. PMF evidence should weigh interviews, payment behavior, support
  patterns, and repeated objections before preserving advanced features.
- PM-AIERA-013: Treat support and community as adoption loops, not after-sales
  chores. Fast response, visible fixes, mentor networks, and exclusive field
  material can become a moat when they create earned trust.
- PM-AIERA-014: Do not lead with the technology label when the domain distrusts
  it. If "AI" or another implementation term raises adoption friction, state the
  user outcome, control boundary, and manual override first.
- PM-AIERA-015: Treat vibe-coding or agent skill as leverage, not a monetization strategy; before planning paid work, ask what root product/domain knowledge explains what to build and why.
- PM-AIERA-016: For freelance/service work, sell the problem diagnosis and roadmap, not just implementation. Match the artifact to the buyer role: vision for decision-makers, internal-report material for practitioners, and trust-building cadence for enterprise accounts.
- PM-AIERA-017: Product work needs demand evidence before build: preorder, landing/fake-door, recruiting signal, or equivalent. For B2B/B2G without domain expertise, prefer a domain partner or a stop condition over blind build.
- PM-AIERA-018: AX is process redesign for measurable time/cost reduction, not tool-use training. Name the top-down sponsor, lead-workflow automation target, measurement method, and incentive/change-resistance plan.
- PM-AIERA-019: Reject activity-list strategy. A plan names controllable work; a strategy names the uncontrollable customer behavior change, the winning theory, the assumptions that must be true, and the evidence cadence that will adjust the bet.
