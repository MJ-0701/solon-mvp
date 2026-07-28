---
id: sfs-policy-harness-autonomy
summary: Convert Harness Engineering from principle into project-operating evidence.
load_when: ["harness", "autonomy", "parallel agents", "long-running", "quality", "team roster", "agent roles tools", "who owns what", "spec drift", "translation layer", "state machine", "implicit control flow"]
---

# Project Harness Autonomy

Harness Engineering means the model is only one component. The product quality
comes from the environment around it: agent roles, skills, tools, routed
context, orchestrator rails, artifacts, memory, tests, review, and release
checks.

SFS applies this as a project-operating contract:

- Diagnose before long autonomy: `sfs harness doctor` checks whether a project
  has thin entry docs, routed context, active divisions, memory, tests, and
  release/check rails.
- Audit before extending a generated harness: compare declared agents, skills,
  orchestrator pointers, and change history with the filesystem. Classify the
  slice as new build, extension, architecture change, or maintenance before
  adding another worker.
- Map before parallelization: `sfs harness map --write` records roles, inputs,
  outputs, quality gates, and human-owned boundaries before optional worker
  lanes are split.
- Sanity before cartography: the readiness audit (doctor's AI Readiness
  section) or an explicit `.sfs-local/readiness-waiver` is recommended before
  `map --write` — a map over an unhealthy codebase is false information.
  Rubric, waiver, and order discipline: `harness-readiness.md` (signal-only).
- Locate the maturity level before expanding autonomy: doctor's AI Maturity
  section scores a 5-level impact ladder (delegation, review loop, parallel
  capsules, unattended outputs) from workbench artifacts — climbing one level
  at a time beats tool-count growth. Rubric: `harness-maturity.md`
  (signal-only).
- Name the team architecture only when multi-agent work is actually selected:
  pipeline, fan-out/fan-in, expert pool, producer-reviewer, supervisor, or
  hierarchical delegation. The pattern is evidence for routing and handoff, not
  a reason to override SFS's single-agent default.
- Team roster is an explicit artifact, not tribal knowledge. Each human and
  agent on a selected team declares its **owns/scope/tools** on a durable
  surface — a skill/persona file or routed-context line, the same place
  `model-profiles.yaml` already binds `role -> runtime`. The roster makes
  "which agent does what, with which tools" inspectable instead of implied.
  Motive (external validation, by-reference): when roles are left unspecified,
  operators spin up side personal AI assistants and context fragments across
  unshared workspaces — the roster is the antidote. This is the team-layer
  twin of the advisor-Code file bus below: declare the players, then route work
  to them by artifact.
- Lock the change basis before long implementation: write a compact docs/ADR/
  spec diff or equivalent run brief so workers read the changed intent first,
  not the whole conversation or a stale plan.
- SPEC_IS_THE_ARTIFACT: the artifact that is **verified** must be the artifact
  that is **executed or consumed** — a translation layer between them is a
  drift source by construction, because the check ages against a copy. SFS's
  instances are by-reference: capsule `acceptance_criteria` are checked on the
  capsule the worker runs (`sub-agent-capsule-contract.md`), and plan AC on the
  plan the implement rail consumes. A new surface names which artifact is
  authoritative and deletes the copy, never syncs two. External validation
  (by-reference): a Claude blog deterministic-kernel writeup (2026-07-21);
  vendor and product names held out.
- CONTROL_LOGIC_AS_DATA: routines, transitions, and gates belong on a data
  surface the agent can read, edit, and verify — not an implicit state machine
  spread through prose or code branches. Instances by-reference: routed context
  plus `_INDEX.md` routes, `model-profiles.yaml` bindings, and the team-topology
  OCP rule that a binding is data, not code. A new mechanism earns its place
  only when its control flow is declared somewhere inspectable; implicit control
  flow is a design finding, not a style preference (same source as above).
- PRE_WORK_INVARIANT_DECLARATION: before a risky WU (migration-grade — data
  moves, destructive rewrites, broad refactors, long unattended runs), the
  agent declares the invariants it will preserve as a workbench artifact and
  executes against them. The declaration is a verification target — the
  self-generated counterpart of acceptance criteria that reviewers and
  verifiers check the result against — and a declared-invariant breach is a
  finding even when every AC passes. External validation (by-reference): a
  frontier-lab case (Claude blog, 2026-07-10) — overnight autonomous
  migration work earned trust because the agent declared the invariants it
  would hold before starting; vendor and model specifics held out.
- Measure agent productivity as time-to-validated artifact, not human busywork
  avoided. Improve context routing, memory indexing, tool boundaries, slice
  size, and automated feedback before adding more agents.
- Long-running harnesses need a phase/run ledger: current phase, resume point,
  remaining work, expected outputs, recovery path, and stop condition must be
  artifact-backed before automation continues unattended.
- Autonomy modes are explicit: dialogue/planning, autopilot, and Ralph-grade
  loop. Ralph-grade ends only when every story AC is PASS, waived, or approved
  deferred; it records slice evidence, review result, and next stop condition.
  It still obeys token/session guardrails and mutex ownership.
- Within-loop discard escalation is quantitative and distinct from the
  Ralph-grade loop-end condition (the ladder governs progress per iteration; AC
  PASS/waived/deferred governs when the loop stops). Track consecutive discarded
  iterations and escalate: at 3 discards `refine` the approach, at 5 `pivot` to a
  different approach, at 8 `halt` and call a human. A kept iteration resets the
  counter to 0. Each iteration makes one atomic change (`--micro-steps-per-iter`
  default 1); a micro-improvement that only adds complexity is discarded, not
  kept — the kernel's minimum-useful-slice rule applies inside the loop too.
  `halt` routes to the human-owned product-judgment boundary, never an automatic
  override.
- Treat artifacts as coordination, not chat: workers write files, reports,
  ledgers, test output, or release evidence; leads inspect artifacts instead of
  relying on conversational memory.
- Use an advisor-Code file bus for split verification: each reviewer writes an
  artifact capsule with rule, evidence, finding, uncertainty, and requested
  action. For parallel review, hold a fan-out/synthesize barrier until all
  capsules exist; then the lead synthesizes against AC/source evidence instead
  of copying chat transcripts.
- ChatOps workrooms are coordination surfaces, not memory SSoT: use project
  channels for routing/status and task threads for bounded work capsules; close
  or archive threads with result/evidence and refresh summaries before
  reactivation.
- Standing AI workers need an onboarding contract before cron or unattended
  delivery: identity/persona boundary, routed operating manual or skill,
  bounded memory with review cadence, schedule/trigger plus delivery mode, and
  report channel with permission, attachment, redaction, and disable path.
- PRs and review threads are report artifacts: useful for later human audit,
  but they do not replace SFS Gate 3/6 review or acceptance evidence.
- Multi-agent review reduces human bottleneck only when the lead adjudicates
  reviewer findings against AC/source evidence; another agent's critique is
  evidence to evaluate, not automatic truth.
- FIX_THE_LOOP_NOT_THE_CODE: when review catches the **same mistake class
  across artifacts repeatedly**, the fix goes upstream — add one rule to the
  loop that produces them (rulebook, routed policy, skill, prompt) and
  **regenerate the affected batch**; artifacts are never hand-patched against
  the rule. Per-artifact hand-patching hides the loop defect and diverges the
  batch from its generator. The repeated-correction trigger
  (`skill-promotion-loop.md` DETECTION, floor 2) detects the repeat; this
  names the follow-through. External validation (by-reference): a Claude blog
  large-scale migration writeup (2026-07-16) — "fix the loop, not the code";
  vendor, language, and scale figures held out.
- JUDGE_NEGATIVE_CONTROL: before a judge (test, AC check, verifier, headline
  assert) is trusted to gate work, validate it in **both directions**: it
  passes on a known-good input *and* fails on a deliberately-broken fixture.
  A judge that cannot catch breakage is not a judge — it is a rubber stamp
  that will approve regressions silently. This is the precondition step of
  the verifier != implementer invariant below (same migration source,
  by-reference: judges were proven against intentionally-broken code before
  the fleet ran).
- BOUNDS_OUTLIVE_MODEL_LIMITS: design boundaries from **what the operator
  permits**, never from what today's model cannot do — prompt scaffolds and
  capability gaps are not control points, and they expire at the next model
  swap (`model-workaround-sunset.md` MODEL_UPGRADE_SETUP_AUDIT retires the
  coaching; the permission boundary stays). After an upgrade, new emergent
  behavior *inside* the boundary is expected — observability catches and
  reviews it; it is not a breach (external validation, by-reference: a Claude
  blog CISO guide, 2026-07-17; vendor and survey figures held out).
- Verifier != implementer is a critical harness invariant. The authoring
  worker cannot be the only reviewer for close; use a separate agent/context or
  record an explicit waiver for low-risk self-CPO fallback. The corollary that
  drives autonomy: **verification capability is the precondition for expanding
  autonomy** — a delegated task earns more autonomy only once it has a
  verification means (test, rubric, style guide, or a separate verifier) the
  human can trust before reviewing the work. No verifier yet → keep it
  supervised. Failures accumulate in the **verification gap**, not in
  generation — invest in the checking surface before raising throughput.
  Trust is built per task type over time, not granted up front
  (external validation, by-reference). The recurring "lessons and missteps"
  review that feeds this trust is the lessons curation pass
  (`lessons-accumulation.md` CURATION_PASS); north-star proactivity
  (`work-delegation-and-startup.md` NORTH_STAR) is gated on this same anchor.
- A separate verifier context should be rule-scoped and skeptical: give the
  verifier the rule, expected evidence, counterexamples, and false-positive
  risks, not the author's full reasoning trail. External validation
  (by-reference): a marketing-operations case (Claude blog, 2026-07-08) runs a
  dedicated **fresh-context audit agent** — a verifier that starts with no
  builder context — over every automated build before ship; the
  verifier != implementer invariant proven outside engineering, by
  non-technical operators.
- Capture harness evolution deltas: initial harness, shipped harness, what
  changed, why, and which defect/feedback proved the change. Repeated deltas
  become tests, routed policies, skills, or scaffold defaults.
- Use `.sfs-local/harness/evolution-ledger.md` as the concrete evolution
  surface: source, baseline, shipped delta, hypothesis, acceptance signal,
  promotion target, decision, evidence paths, and next check. `sfs harness map
  --write` creates the skeleton and preserves existing rows.
- Keep humans on product judgment: goals, domain meaning, tradeoffs, ethics,
  and public-contract changes stay human-owned.
- Convert repeated defects into harness assets: tests, wiki bug reports,
  routed policies, knowledge packs, fixtures, or review questions.
- This policy owns the CAPTURE-delta stage of the end-to-end loop map in
  `self-improvement-loop.md` (evolution-ledger feeds repeated deltas back as new
  SIGNAL); that map declares the loop's cross-cutting invariants once.

Multi-agent execution remains opt-in. The default upgrade from a single model
is not "more agents"; it is a better environment for whichever model is active.
