---
id: sfs-policy-division-subagent-council
summary: Five organization divisions and the cross-cutting taxonomy lens participate as six required council roles across SFS phases.
load_when: ["division", "council role", "taxonomy lens", "sub-agent", "6본부", "Gate 2", "Gate 3", "Gate 6"]
---

# Council Participation Contract

- The six required council participation roles are always on: five organization
  divisions (strategy-pm, dev, QA, design, and infra) plus taxonomy, a
  foundational cross-cutting product function and domain-language/classification
  review lens. Taxonomy is not an organization division. This applies to
  brainstorm, plan, implement, review, report, and retro.
- `.sfs-local/divisions.yaml` remains a legacy compatibility/depth surface. Its
  taxonomy activation slot does not classify taxonomy as a division. `active`
  means deeper pack/read responsibility; `abstract` means lightweight lens.
  Activation controls depth/escalation, not participation.
- Each non-trivial SFS artifact should record a `division_subagent_ledger` or
  equivalent council participation table. The legacy key is retained for
  consumer compatibility; each row identifies a council role, with: phase,
  role, status (`involved`,
  `not-applicable`, `blocked`, `waived`), finding/question, evidence path, and
  next action. When domain know-how is in scope, also record `asset_candidate`
  as existing asset reused, new asset to create, or concrete gap/waiver.
- Brainstorm: strategy-pm checks product intent/scope, taxonomy checks terms,
  design checks user workflow, dev checks boundary feasibility, QA checks first
  feedback signal, and infra checks deploy/data/runtime risk.
- Plan: every relevant council role maps AC/files/artifacts/evidence or records
  a waiver. Missing role evidence is plan partial when the role clearly affects
  acceptance.
- Enterprise plan council: for non-trivial product-bearing work, plan is a
  design phase. Load `enterprise-plan-council-pack.md` and record risk flags,
  selected child packs, and AC/files/evidence mapping before Gate 3 review.
  Do not produce empty six-role council ceremony; each row needs a finding, evidence,
  asset candidate, waiver, or concrete not-applicable reason.
- Implement: actual parallel worker lanes remain optional. Council review is
  not optional; the lead may record the six roles directly, or route
  read-only/fixed-scope capsules when the bridge supports sub-agents. The
  QA/review verification lane must be a different agent/context from the
  implementing lane. This verifier != implementer / verifier ≠ author rule is
  a critical close invariant; model diversity is Gate 6 cross-CPO's responsibility.
- Review: Gate 6 checks the council participation ledger along with the implementation
  acceptance ledger. Load `enterprise-evidence-pack.md` when QA/QC or project
  applied evidence is in scope, and `enterprise-performance-review-pack.md`
  when hot-path or algorithm/runtime cost changes. A deterministic council-role
  finding routes to autopilot patch+verify+review; escalate only for genuinely
  new product judgment or new approval-required risk.
