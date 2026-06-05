---
id: sfs-policy-external-orchestrator-entry
summary: Contract for an external standing orchestrator that invokes a Solon project headless; gates stay inviolable, first permission is read-only.
load_when:
  - orchestrator
  - hermes
  - headless
  - external agent entry
  - automation entry
---

# External Orchestrator Entry

A standing external agent (Hermes-class) may drive a Solon project without a
human at the keyboard. This is the entry contract it must honor. It is a thin
convention — no adapter code ships here; the orchestrator adapts to SFS, not the
reverse.

## Entry shape

- **Headless invocation.** The orchestrator calls the project's `sfs` runtime
  non-interactively. It passes a single self-contained brief, not a live
  conversation; see the §1.29 single-prompt handoff pattern.
- **File-bus reporting.** Results come back as artifacts — reports, ledgers,
  review output, capsules — written to the project's known paths. The
  orchestrator inspects files, not chat scrollback (Runtime Token Firewall).
- **Capsule-only handoff.** Forward goal, AC, files_scope, commands, expected
  output paths, and compact evidence — never a full transcript.

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
