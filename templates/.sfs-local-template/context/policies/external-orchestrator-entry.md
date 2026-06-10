---
id: sfs-policy-external-orchestrator-entry
summary: Contract for an external standing orchestrator that invokes a Solon project headless; gates stay inviolable, first permission is read-only.
load_when:
  - orchestrator
  - hermes
  - headless
  - external agent entry
  - automation entry
  - standalone guarantee
  - optional orchestrator
  - typed handoff
  - structured contract
---

# External Orchestrator Entry

A standing external agent (Hermes-class) may drive a Solon project without a
human at the keyboard. This is the entry contract it must honor. It is a thin
convention — no adapter code ships here; the orchestrator adapts to SFS, not the
reverse.

## Optional by design (standalone guarantee)

This is the policy's first frame, ahead of any entry mechanics: an external
orchestrator is an **optional extension point**, never a dependency.

- **Standalone guarantee.** No Solon command, gate, or release presupposes an
  orchestrator. Remove every external orchestrator and the full Solon feature
  set behaves identically. This policy is only "the contract *when* an
  orchestrator is present" — it does not mean Solon needs one.
- **Vendor-neutral.** "Hermes-class" names an example category, not a product
  dependency or recommended install. Product code, default configuration, and
  tests require no specific orchestrator — none is bundled, pinned, or assumed.
- **Open evolution path.** This same entry convention stays an open extension
  point for an operator who *wants* to evolve the product through an
  orchestrator. Optional does not mean closed.

Discriminating test: **Remove every external orchestrator — do all Solon
commands still work? Must be yes.**

## Entry shape

- **Headless invocation.** The orchestrator calls the project's `sfs` runtime
  non-interactively. It passes a single self-contained brief, not a live
  conversation; see the §1.29 single-prompt handoff pattern.
- **File-bus reporting.** Results come back as artifacts — reports, ledgers,
  review output, capsules — written to the project's known paths. The
  orchestrator inspects files, not chat scrollback (Runtime Token Firewall).
- **Capsule-only handoff.** Forward goal, AC, files_scope, commands, expected
  output paths, and compact evidence — never a full transcript.

## Typed handoff contract

A handoff between stages is a **typed/structured contract, not raw text**. The
artifact a stage emits must carry fixed, named fields a downstream stage can
validate before consuming — never free prose the next stage has to re-parse.
This applies to the advisor↔Code file bus and every capsule handoff above.

- **Tiered handoff.** A light/lead pass (classification, flowcheck, intake)
  emits the schema-fixed artifact; the heavy reasoning pass consumes only the
  validated input. The cheap pass owns shape, the expensive pass owns judgment —
  so the costly call never starts from unvalidated text. Generalized
  by-reference from a vendor tiered on-device→cloud handoff pattern; the
  vendor/SDK specifics are out of scope, cite by pointer and never copy
  (`policies/source-pointer-citation.md`).
- **Field schema SSoT.** The required handoff/capsule fields are the
  `sub-agent-capsule-contract.md` table (`goal` / `acceptance_criteria` /
  `files_scope` / `tools_allowed` / `output_paths` / `token_budget` / `timeout`
  / `pii_rules`). A handoff block missing a field is a finding, not prose to
  interpret. This policy does not re-list the fields — that table is the SSoT.
- **Same discipline on the event bus.** Structured flow/telemetry events
  (`sfs event` typed `key=value` fields, including the `tool_call` telemetry
  schema) apply the identical typed-contract rule to the file bus: machine-
  checkable fields, not narration (`policies/flow-conformance-postflight.md`).

## Inviolable gates

The orchestrator cannot bypass any human/quality gate. Specifically it may not,
on its own authority:

- cut or publish a release, push to a remote, or merge to a default branch;
- mark owner-approval-required work approved (Gate 3 user approval is
  natural-language human evidence only);
- override a critical flowcheck invariant or a stop-the-line failure;
- delete, move, or overwrite evidence without the recorded approval the gate
  requires.

A gate that needs human judgment stays human-owned; the orchestrator surfaces
and waits.

## First-permission read-only

An orchestrator's first authorized scope is read-only (inspect status, recall,
healthcheck, read artifacts). Mutation scope is granted explicitly and
incrementally — read → propose → bounded write → release-adjacent — never
assumed from a single broad grant. This mirrors the agent runbook Level 0 → 1
escalation.

## Cross-references

- Worker/handoff capsule: `policies/runtime-token-firewall.md`,
  `policies/sub-agent-capsule-contract.md`.
- Session continuation / single-prompt handoff:
  `policies/session-continuation-guard.md`.
- External knowledge citation: `policies/source-pointer-citation.md`.
