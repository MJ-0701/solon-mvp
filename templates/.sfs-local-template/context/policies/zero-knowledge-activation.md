---
id: sfs-policy-zero-knowledge-activation
summary: Any state SFS can detect and safely apply MUST be reachable via detect -> guide -> consent(once) -> apply. If turning it on requires the user to know a command, flag, or hand-edit a config, that is a design bug. solo default / consent / standalone lock are invariant.
load_when: ["activation", "activatable", "enable feature", "turn on", "auto-offer", "zero-knowledge", "detect and apply", "manual config edit", "model-profiles edit", "team use", "team refresh", "preset", "opt-in", "discoverability"]
---

# Zero-Knowledge Activation

A capability the harness can both **detect** and **safely apply** must never
require the user to know how to turn it on. If the only path to a beneficial,
already-safe state is "edit `model-profiles.yaml` by hand" or "know that the
flag `--team` / the command `sfs team use` exists", the activation surface is a
**design bug** — not a documentation gap.

This is the product-level rule the 0.8.49/0.8.50 team-activation work and the
0.8.52 deprecated-fallback promotion both instantiate. It generalizes them so
the next activatable state inherits the same contract instead of re-deriving it.

## The contract: detect -> guide -> consent -> apply

For any activatable state, SFS owns all four steps:

1. **detect** — capability/state is evaluated from the environment as data
   (runtime present + auth-ready, profile schema, preset gap), not assumed.
2. **guide** — when the safe-and-beneficial transition is available, SFS
   surfaces a single one-line offer in plain language. The user does not need
   to have read any doc or know any command name to see it.
3. **consent** — the change applies only on an explicit one-time yes (interactive
   `[Y/n]`, or an explicit `--yes`/force flag the user already typed). Decline is
   remembered so the offer does not nag; it re-surfaces only when capability
   changes.
4. **apply** — SFS performs the minimal write itself. The user never hand-edits
   config to reach a state SFS could have applied.

The reference implementation is the R5 auto-offer
(`upgrade_team_offer_surface` in `upgrade.sh`, locked by
`tests/test-team-auto-offer.sh`) and the fallback promotion
(`team_promote_fallbacks` in `sfs-team-apply.sh`), which detects a fallback by
two signals — a `# sfs-fallback:` provenance marker (locked by
`tests/test-team-fallback-promotion.sh`) and, for pre-marker bindings,
deprecation-inference (locked by
`tests/test-team-legacy-fallback-promotion.sh`).

## Invariants (never traded for convenience)

- **solo / default-off is the resting state.** Activation is additive. A fresh
  or untouched project behaves exactly as if the feature did not exist.
- **No apply without consent.** Non-interactive / no-`--yes` / undecided =
  byte-for-byte no change. Forcing an apply because it "would help" is a bug.
- **User intent is never clobbered.** A value SFS picked as a fallback is
  distinguished from one the user chose deliberately, and only a fallback is
  auto-promoted. The fallback is identified by **either** a provenance marker
  (`# sfs-fallback:`, written at materialize time) **or** deprecation-inference
  (an unmarked binding to a `deprecated` runtime whose preset canonical differs
  and is capable — for bindings that hardened before markers existed). Intent is
  the inverse signal: a non-deprecated choice, or an explicit `# sfs-pinned:`
  recorded when the user declines a promotion offer (asked once, then preserved).
  See [user-override-precedence](user-override-precedence.md).
- **standalone lock.** Removing the feature's config degrades cleanly back to
  the default; the standalone path keeps working with zero feature knowledge.
- **manual-knowledge requirement = FAIL.** If a reviewer can only reach the
  state by typing a command or editing YAML they had to know about, the
  activation path is incomplete.

## Where this binds the 7-step flow

- **Gate 6 (Review).** A change that adds or moves an activatable/config state
  is reviewed against the activation review check (see
  [agent-build-review-lens](agent-build-review-lens.md) §2): is there a
  detect -> offer path, or does the user need manual knowledge? Manual-knowledge
  requirement is a FAIL finding, not a nit.
- **Meta-enforcement.** Activatable states are enumerated as data in
  `tests/activatable-states.registry`; the meta-test
  `tests/test-activatable-states-registry.sh` fails `run-all` if any registered
  state lacks an offer-path test. A new activatable state without an offer path
  cannot pass.

## Scope — what counts as an "activatable state"

A state qualifies when BOTH hold:

- SFS can **detect** whether the transition is available from the environment
  (no human judgement call required to know it is safe).
- SFS can **apply** the transition with a bounded, reversible write it owns.

States that need genuine human judgement (which architecture, which provider,
irreversible/outward-facing actions) are NOT in scope — those stay explicit
user choices and must still ask. The rule targets the case where SFS *could*
have done it safely and instead made the user learn how.

## Cross-Ref

- `policies/user-override-precedence.md` — user-chosen value beats SFS default;
  provenance separates intent from fallback.
- `policies/agent-build-review-lens.md` — Gate 6 activation review check (§2).
- `policies/deprecation-and-migration.md` — deprecated runtime sunset feeds the
  fallback-promotion state.
- `policies/critical-rule-hook-promotion.md` — why "must always offer" is
  promoted from prose to a meta-test rather than left as a guideline.
- `docs/maintenance/methodology-7-step.md` — Gate label convention.
