---
id: sfs-policy-division-subagent-council
summary: Six core divisions participate as conceptual sub-agents across SFS phases.
load_when: ["division", "sub-agent", "6본부", "Gate 2", "Gate 3", "Gate 6"]
---

# Division Sub-Agent Council

- The six core divisions are always-on conceptual sub-agents: strategy-pm,
  dev, QA, design, infra, and taxonomy. This applies to brainstorm, plan,
  implement, review, report, and retro.
- `.sfs-local/divisions.yaml` remains a compatibility/depth surface.
  `active` means deeper pack/read responsibility; `abstract` means lightweight
  lens. It does not mean the division is absent; activation controls depth/escalation, not participation.
- Each non-trivial SFS artifact should record a `division_subagent_ledger` or
  equivalent table with: phase, division, status (`involved`,
  `not-applicable`, `blocked`, `waived`), finding/question, evidence path, and
  next action.
- Brainstorm: strategy-pm checks product intent/scope, taxonomy checks terms,
  design checks user workflow, dev checks boundary feasibility, QA checks first
  feedback signal, and infra checks deploy/data/runtime risk.
- Plan: every relevant division maps AC/files/artifacts/evidence or records a
  waiver. Missing division evidence is plan partial when the division clearly
  affects acceptance.
- Enterprise plan council: for non-trivial product-bearing work, plan is a
  design phase. Load `enterprise-plan-council-pack.md` and record risk flags,
  selected child packs, and AC/files/evidence mapping before Gate 3 review.
  Do not produce empty six-division ceremony; each row needs a finding, evidence,
  waiver, or concrete not-applicable reason.
- Implement: actual parallel worker lanes remain optional. Division council
  review is not optional; the lead may record the six lenses directly, or route
  read-only/fixed-scope capsules when the bridge supports sub-agents.
- Review: Gate 6 checks the division ledger along with the implementation
  acceptance ledger. Load `enterprise-evidence-pack.md` when QA/QC or project
  applied evidence is in scope, and `enterprise-performance-review-pack.md`
  when hot-path or algorithm/runtime cost changes. A deterministic division
  finding routes to autopilot patch+verify+review; escalate only for genuinely
  new product judgment or new approval-required risk.
