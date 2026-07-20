---
doc_id: sfs-current-product-shape-en-30
title: "The Unknowns Loop — working the map-vs-territory gap"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-07-20
parent: docs/en/current-product-shape.md
summary: "The sprint-wide loop for the gap between the plan (map) and the codebase (territory): recon, prototype fork, interview gate, blind_spots, references, deviation ledger, comprehension quiz, plus healthcheck/doctor runtime signals."
load_when: "Read when plans keep missing, specs stay vague, implementation diverges from plan, or you must decide whether to trust a completion report."
---
## The Unknowns Loop — working the map-vs-territory gap

A prompt/plan/context bundle is a **map**; the actual codebase, data, and
domain are the **territory**. Work quality is bottlenecked not by model
capability but by **how fast the gap — the operator's unknowns — is found**.
Solon places touchpoints across the whole sprint. The contract SSoT is routed
context `policies/unknowns-and-deviations.md`; this page is the operator
guide.

### At a glance (sprint-timeline order)

| When | Technique | What it does |
|---|---|---|
| Direction cannot be verbalized | **PROTOTYPE_FORK** | 2–4 cheap variants + comparison table → pick; rejection reasons recorded |
| Before a high-uncertainty slice | **RECON_RUN_BEFORE_COMMIT** | read-only recon (`sfs dig`, targeted reads) collects facts into the plan |
| Kickoff | **blind_spots list** | "decisions you never mentioned" listed with answered/delegated/open states |
| Before the spec freezes | **SPEC_INTERVIEW_GATE** | impact-ordered questions (design-overturning first), answers merged into the spec; skips recorded explicitly |
| Writing the spec | **REFERENCES_FIELD** | pointers to code that already does the behavior (path/commit + one-line intent), read before implementing |
| During implementation | **DEVIATIONS_LOG** | plan≠territory → conservative choice + `## Deviations` record + continue |
| Claiming done | **ledger stated** | entries or `none observed` — an unstated ledger means unverified |
| Stuck mid-work | **SOLVED_ELSEWHERE_FIRST** | first hypothesis: this is already solved somewhere in the repo |
| Discovered mid-work | **EVAL_SURFACE_BLIND_SPOT** | an axis the AC cannot see (cost, cache) surfaces as a finding |
| Around merge | **COMPREHENSION_GATE** | 3–5 questions drawn only from the change — operator understanding; misses link to the explainer |

Everything is **signal-only** — nothing blocks a command. Gates move artifact
readiness states (draft ↔ ready) and review findings only.

### Why this order

- **Fork and recon are siblings**: fork when *direction* is unknown; recon
  when direction is known but the *territory* is not.
- **The interview empties into the spec**: an answer that only lives in chat
  is not spec. An open question keeps the plan `status: draft`; skipping
  requires an explicit `skip: <reason>`.
- **The deviation ledger is the next sprint's map**: today's deviations are
  tomorrow's plan-preflight input (lessons SIGNAL → `L-NNN`).
- **The quiz verifies the operator, not the work**: the counterpart of Gate 6
  review — adopt the result when you can answer what it does and what it
  traded away.

### Runtime signals (automatic advisories)

| Signal | Surface | Condition |
|---|---|---|
| `deviation-ledger` WARN | `sfs healthcheck` | review/report exists (completion claimed) but the `## Deviations` ledger is unstated |
| `plan-readiness` WARN | `sfs healthcheck` | implementation started with interview/blind_spots/references readiness items unchecked |
| "Held-Out Evals" section | `sfs harness doctor` | counts held-out eval case files (never reads their bodies) |

All say_warn/info — exit codes never change.

### The eval twin (evals scaffold)

`.sfs-local/evals/README.md` is the entry to the held-out scoring set. The
case axes include **wrong-premise fixtures** (underspecified prompt + a
deliberately wrong premise — judged on refutation, not the answer), and the
judge itself is validated in the fail direction with a deliberately-broken
fixture first (`policies/harness-autonomy.md` JUDGE_NEGATIVE_CONTROL).

### Related

- The sprint rails overall: [Feature Overview](./29-feature-overview.md)
- Where capsule workers record deviations: [delegation repertoire](./26-delegation-repertoire.md)
- Contract SSoT: `sfs context cat policies/unknowns-and-deviations`
