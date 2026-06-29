---
doc_id: sfs-current-product-shape-en-28
title: "Agent identity and compartments"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-06-28
parent: docs/en/current-product-shape.md
summary: "The access model for autonomous agents: the agent acts as itself (a service account) with access revocable by identity, permissions scoped to the compartment (work boundary) not the user, and grants widened by audit not guess."
load_when: "Read when an agent needs credentials or access, when separating a personal/learning boundary from a company project, or when deciding how to widen an agent's permissions."
---
## Agent identity and compartments

As an agent gains autonomy, the old "act as the user" shortcut — let the agent
borrow your credentials and permissions — stops being safe: its actions become
indistinguishable from yours, and there is no clean way to revoke just the
agent. The durable model has three parts (source: a Claude blog post on the
agent identity access model, 2026-06-24, by-reference — generalized; vendor
channel UI, Enterprise RBAC, and the JIT-credential roadmap held out).

### 1. The agent acts as itself

An agent carries **its own identity** (a dedicated service account), distinct
from any operator. Access is granted to that identity and audited under it, so
**revoking the identity ends every access it held at once** — a single, clean
kill switch a borrowed-user credential can never offer. This is the
access-control twin of the credential boundary rule: keys in one store, attached
at the boundary, scoped per consumer — where the consumer is now the agent's own
identity (`policies/credential-hygiene.md` AGENT_IDENTITY; same per-consumer
isolation as `policies/runtime-token-firewall.md`).

### 2. Permissions belong to the compartment, not the user

Scope access and memory to the **compartment** — the work boundary (a project,
repo, or channel) — rather than to whoever is present. A workspace baseline
applies everywhere; a compartment narrows or overrides it for its own scope, and
**what an agent learns inside one compartment does not leak into another**
(`policies/user-context-separation.md` COMPARTMENT_SCOPING).

For a one-person operator this is not multi-tenant overhead — the live
boundaries are your own: a personal/learning docset versus a company project.
The rule keeps private-docset learning from bleeding into company-project output
(the same product-leak boundary the distribution already guards in test).

### 3. Widen grants by audit, not by guess

Permissions grow through a lifecycle, never a single broad grant:

1. **Start from a baseline profile** scoped to the smallest set that lets the
   work begin.
2. **Read the audit trail** of what the identity actually touched — Solon's
   `events.jsonl` and `tool_call` telemetry are that source.
3. **Pare to one justified grant at a time.** Where you must start broad to
   unblock, treat broad-then-narrow as the obligation: each later grant is
   justified by the trail; unused scope is removed
   (`policies/credential-hygiene.md` GRANT_LIFECYCLE).

This mirrors the orchestrator's read → propose → bounded-write escalation
(`policies/external-orchestrator-entry.md`).

### Where it meets the Solon workflow

- Real keys never appear on an agent-visible surface — only placeholders and
  env-var names (`policies/credential-hygiene.md` PLACEHOLDER_ONLY_SURFACES).
- The audit source for grant decisions is the same event ledger flowcheck reads
  (`policies/flow-conformance-postflight.md`).
- The agents whose access you are scoping are the ones on the team roster
  (`current-product-shape/27-human-agent-teams.md`).
