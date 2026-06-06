---
id: sfs-context-conflict-gate
summary: Detect contradictory directives across loaded context via opt-in conflict-key markers; conflict, not volume, is the real context failure.
load_when: ["context conflict", "contradictory policy", "conflicting directive", "conflict-key", "policy contradiction", "two policies disagree", "context lint"]
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
</content>
</invoke>
