---
id: sfs-context-conflict-gate
summary: Detect contradictory directives across loaded context via opt-in conflict-key markers; conflict, not volume, is the real context failure.
load_when: ["context conflict", "contradictory policy", "conflicting directive", "conflict-key", "policy contradiction", "two policies disagree", "context lint", "too many rules", "overconstrained", "trim the prompt", "redundant guidance", "rightsize context"]
---

# Context Conflict Gate

The hardest context problem is not volume, it is **conflict** — two directives
that contradict each other leave the agent guessing which to obey. Source:
note 21 (OpenAI Codex context/verification flywheel) — "the biggest context
problem is not amount but contradiction (모순 지시); minimize volume and give a
clear starting point."

Semantic contradiction is not reliably machine-detectable, so this gate is an
**opt-in marker lint**: a directive that has a known opposite annotates itself,
and the harness flags any subject declared with both stances. Unannotated prose
is never compared, so the detector cannot false-positive on normal policy text.

## CONFLICT_KEY_MARKER

Annotate a directive that has a binary stance with a single-line HTML comment
(invisible in rendered Markdown), placed adjacent to the directive:

```
<!-- conflict-key: <slug> stance: allow|deny -->
```

- `<slug>` — a stable kebab-case subject id shared by every directive that takes
  a stance on the same thing (for example `force-push-main`, `delete-without-backup`).
- `stance` — `allow` (the directive permits / requires the action) or `deny`
  (the directive forbids it).
- One marker per line; `conflict-key:` comes before `stance:` on that line.
- Markers are optional. Only annotate where a real contradiction would be a
  silent failure — do not pepper every line.

## DETECTION

`sfs harness doctor` adds a **Context Conflict Gate** section that walks the
consumer project's local context overrides only (`.sfs-local/context/`), never
the shipped distribution — mirroring the other harness detectors. For every
`conflict-key` slug it collects the declared stances:

- a slug carrying **both** `allow` and `deny` → `warn` (the contradiction must be
  resolved before the agent relies on either directive);
- all slugs internally consistent → `ok`;
- no markers present → skipped (`info`).

The gate is a heuristic over declared markers, not a semantic theorem prover.
Absence of a warning means no annotated contradiction, not a proof of global
consistency. Promote a recurring real contradiction into a marked pair so the
gate catches its return.

## RIGHTSIZE_CONTEXT_PASS

The marker lint above catches a contradiction a directive **declared**. Newer
models change what the undeclared cases cost: guidance written to compensate for
a weaker model becomes, on a stronger one, a constraint that fights the judgment
it no longer needs — **overconstraint is itself a defect**, not merely wasted
tokens. Solon already forces progressive disclosure structurally (thin entry,
routed `load_when`, the 200-line budget), so the delta is the diagnostic lens,
not another disclosure mechanism.

`sfs harness doctor` runs the pass in this same section, read-only over the
consumer's agent-visible guidance surfaces (root adapter stubs,
`.sfs-local/context/`, installed skills), and reports two **info-only** signals
that never warn, never fail, and never move the exit code:

- **redundant guidance** — the same standing directive restated on 2+ surfaces.
  The reader cannot tell which copy is authoritative and the copies drift on the
  next edit; pick one home and point at it. Frontmatter is excluded (routing
  metadata, not guidance), as are fenced code blocks and headings.
- **narrative absolutes** — a count of prose `always` / `never` lines. Each is
  either inviolable, in which case prose is the wrong surface and it belongs on
  an enforcement one, or it is advisory, in which case it is a trim candidate.
  Which of the two is an operator judgment, so the pass counts and stops.

Trimming is never automatic: this pass surfaces candidates and the operator
decides. The classification rule it feeds is `steering-surface-taxonomy.md`
RULE_VS_GUARDRAIL; the dynamic twin of this static scan is the FCP policy-
authority/drift surface (`flow-conformance-postflight.md`). External validation
(by-reference): a Claude blog post on context engineering for newer-generation
models (2026-07-24) — most of a legacy system prompt can go without loss, and
conflicting or redundant guidance is the thing worth detecting; the vendor's
tooling names and removal figures are held out.

## RESOLUTION

When the gate fires, do not silence it by deleting a marker — resolve the
contradiction: keep one stance, scope the other (`user-override-precedence.md`
governs explicit-override precedence and scoped exceptions), or merge the two
directives into one. Record the resolution where the surviving directive lives.

## CROSS_REFERENCES

- Override precedence and scoped exceptions: `user-override-precedence.md`.
- Promotion of a violated-when-critical rule to a hard gate/hook:
  `critical-rule-hook-promotion.md`.
- Line budget for this file: `md-line-budget.md`.
