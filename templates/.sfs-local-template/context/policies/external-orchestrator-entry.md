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
  - advisor strategy
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
This applies to the advisor↔Code file bus and every capsule handoff above. A
bus role may be an **adversarial verifier capsule** (prompted to refute, not
confirm) as well as author/reviewer — see the verifier capsule patterns in
`sub-agent-capsule-contract.md`.

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

## ADVISOR_STRATEGY_BINDING

The advisor↔Code file bus is not only a review channel; it is a **cost/quality
routing strategy**, stated here so it is configured rather than improvised. A
fast worker runtime does the work and a stronger advisor runtime is invoked
**selectively** — to check a plan before it executes, or to judge a result —
not on every step. The measured claim adopted as a binding: worker-plus-
selective-advisor lands close to advisor-only quality at much lower cost per
task, so "route everything to the strongest runtime" is not the default. Cost
is compared **per task**, not per token.

Per OCP (`docs/maintenance/2026-06-23-multi-agent-team-topology.design.md` §3 —
a binding is data, not code), the **call conditions are a data surface** beside
`agent_runtime_bindings`:

- the worker is **stuck** (discard ladder refine/pivot, `harness-autonomy.md`);
- a **verification gate** is being crossed (Gate 3 / Gate 6, self-CPO);
- the slice is declared **low-confidence** (`unknowns-and-deviations.md`).

Anything outside those conditions runs worker-only. By-reference, not restated:
the tier ladder and the completion-ratio × cost-per-task routing evidence are
owned by `token-harness.md` KNOB_DIAGNOSTIC_LADDER, swap decisions are measured
head-to-head (`model-workaround-sunset.md`), and the capsule-side default is
`sub-agent-capsule-contract.md` SUBAGENT_TIER_DEFAULT. External validation
(by-reference): a Claude blog model-selection guide and an overnight-agent
operator interview (2026-07-20/24); class names, benchmarks, figures held out.

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

These gate-bypass actions are boundary actions in the
`critical-rule-hook-promotion.md` DECLARATIVE_BOUNDARY_SURFACE sense: where
the host supports it, enforce them as Tier B/C typed surfaces (permission
deny, pre-tool hook, gate check) rather than relying on this prose alone — a
headless orchestrator is exactly where prose can only be hoped about.

## First-permission read-only

An orchestrator's first authorized scope is read-only (inspect status, recall,
healthcheck, read artifacts). Mutation scope is granted explicitly and
incrementally — read → propose → bounded write → release-adjacent — never
assumed from a single broad grant. This mirrors the agent runbook Level 0 → 1
escalation, and is the orchestrator-layer twin of the credential
`GRANT_LIFECYCLE` (audit-driven, one grant at a time) and per-compartment
scoping (`credential-hygiene.md`, `user-context-separation.md` COMPARTMENT_SCOPING):
an orchestrator's grants are scoped to the compartment it drives, never inherited
across boundaries.

## Self-improvement seam

An external orchestrator may plug into the self-improvement loop
(`policies/self-improvement-loop.md`) at two by-reference seams. The seam is an
**opt-in extension point, default off.** The `external_orchestrator` block in
`model-profiles.yaml` ships `enabled: false`, and a read-only resolver
(`scripts/sfs-orchestrator.sh`, surfaced as `sfs orchestrator`) exposes that
schema as data. The resolve-* surface is read-only; the write verbs
(`ingest` / `export` / `import-review`) touch only the orchestrator's own
artifacts — the signal queue, the outbox export, the review log — never the
loop's authoritative state (suggest-only), and each refuses when the seam is
disabled. So `scope: read-only` in the schema is about loop state: the seam's own
staging files are bounded write. The orchestrator's transport (REST / webhook /
CLI / file-drop) is abstracted to a single `transport_kind` scalar, so swapping
orchestrators is a config edit, not a loop-code change (OCP — the
orchestrator-layer mirror of the worker-layer `runtime_registry`).

- **External SIGNAL source** (wired, Seam A). Cross-system completed-work,
  detection, and hotspot signals feed the loop's SIGNAL/CURATE/PROPOSE input,
  alongside `sfs harness doctor` and the curation pass. A signal is dropped as a
  typed capsule (design §4 fields: `source`, `kind`, `evidence_pointer`,
  `confidence`, `ts` — the typed-handoff discipline above, never raw narration);
  `sfs orchestrator ingest` validates it and appends one typed entry to
  `.sfs-local/orchestrator/signal-queue.md`, which the curation pass reads
  read-only. `evidence_pointer` carries a pointer, not the inlined original.
- **External proposal-review surface** (wired, Seam B). Curation and promotion
  candidates are reviewed by a human across systems on the orchestrator's surface.
  `sfs orchestrator export` emits a **pointer-only** typed proposal to the
  `review_outbox` (file-drop transport — id + `evidence_pointer` + metadata, never
  a raw body), and `sfs orchestrator import-review` validates and sanitizes a
  typed review (`candidate_id` / `decision` ∈ approve|defer|reject / `comment` /
  `reviewer` / `ts`) into an advisory review log. The review changes nothing about
  the loop's authority: candidates stay **suggest-only**, the inviolable gates
  above still hold, and import-review cannot trigger an apply or any boundary
  action — APPLY stays the `tidy` rail + human gate. First authorized scope stays
  read-only.

Wiring lands incrementally on top of this default-off schema, each step keeping
the invariants below: the read-only schema surface, the typed SIGNAL ingest, then
the proposal export + review import above with a real (file-drop) transport. The
actual
seam mechanics are owned by the design SSoT, not re-described here.

**Standalone guarantee (seam form).** Remove every external orchestrator — or
simply leave `external_orchestrator.enabled: false` — and the loop still turns on
`doctor + curation + tidy` alone; the resolver degrades to disabled with no crash.
The default-off schema is exactly what keeps this guarantee intact *while* the
seam is wired: nothing in the loop presupposes an orchestrator, and no
orchestrator signal can auto-write a ledger/skill or trip an inviolable gate
(those invariants are declared once in `policies/self-improvement-loop.md`).

## Cross-references

- Self-improvement loop map (the seam's host): `policies/self-improvement-loop.md`.
- Worker/handoff capsule: `policies/runtime-token-firewall.md`,
  `policies/sub-agent-capsule-contract.md`.
- Session continuation / single-prompt handoff:
  `policies/session-continuation-guard.md`.
- External knowledge citation: `policies/source-pointer-citation.md`.
