---
id: sfs-policy-harness-autonomy
summary: Convert Harness Engineering from principle into project-operating evidence.
load_when: ["harness", "autonomy", "parallel agents", "long-running", "quality"]
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
- Name the team architecture only when multi-agent work is actually selected:
  pipeline, fan-out/fan-in, expert pool, producer-reviewer, supervisor, or
  hierarchical delegation. The pattern is evidence for routing and handoff, not
  a reason to override SFS's single-agent default.
- Lock the change basis before long implementation: write a compact docs/ADR/
  spec diff or equivalent run brief so workers read the changed intent first,
  not the whole conversation or a stale plan.
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
- Verifier != implementer is a critical harness invariant. The authoring
  worker cannot be the only reviewer for close; use a separate agent/context or
  record an explicit waiver for low-risk self-CPO fallback.
- A separate verifier context should be rule-scoped and skeptical: give the
  verifier the rule, expected evidence, counterexamples, and false-positive
  risks, not the author's full reasoning trail.
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

Multi-agent execution remains opt-in. The default upgrade from a single model
is not "more agents"; it is a better environment for whichever model is active.
