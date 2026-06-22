---
id: sfs-critical-rule-hook-promotion
summary: Classify which documented rules must promote from prose to a hard gate/hook; doc rules are expectation, hooks are the only 100%-enforcement layer.
load_when: ["hook promotion", "critical rule", "secret leak", "destructive command", "enforce rule", "hard gate", "promote to hook", "guardrail promotion", "rm -rf", "force push"]
---

# Critical Rule Hook Promotion

Documented rules in `kernel.md`, routed policies, memory, and skills are an
**expectation layer** — the agent is asked to follow them, but nothing forces it.
Hooks (session-start / pre-tool-use / stop) are the **only layer that enforces
with 100% certainty**, because they are code, not prose. Source: note 25 (Codex
harness engineering — of the six harness elements, only hooks enforce as
program logic, e.g. blocking `.env` access) and note 06 (security must be a
guard the workflow makes unskippable). This policy is the classification rule for
deciding *which* prose rules earn promotion to a hard gate or hook.

## ENFORCEMENT_TIERS

- **Tier A — doc rule (expectation).** Prose in kernel/policy/skill. The agent is
  expected to comply. No mechanical block. Default tier; most rules stay here.
- **Tier B — gate/lint (review-enforced).** A contract test, review lens, or
  `sfs harness doctor` detector flags the violation before it ships (e.g.
  `test-agent-entry-doc-hygiene.sh`, the WU-1 `context-conflict-gate`). Caught,
  but after the fact.
- **Tier C — hook (code-enforced, 100%).** A session-scoped or install-time hook
  blocks the action as it is attempted. The only tier that cannot be ignored.

**Authority ceiling (by-reference).** A host with admin-deployed *managed
settings* can place a rule in a tier even the operator cannot override — the
strongest possible enforcement surface (external validation: a Claude blog post
on steering coding agents, 2026-06-18, notes "Never do this" rules belong in
deterministic enforcement, and managed settings are not user-overridable).
Solon's bash distribution ships **no** such surface: the operator owns all
config and overrides every default (`user-override-precedence.md`). So Tier C
here is operator-installed and operator-removable; the override-impossible tier
is named only to locate solon's ceiling, not implemented by it. Surface-choice
decision frame: `steering-surface-taxonomy.md`.

## PROMOTION_CRITERIA

Promote a Tier-A rule upward when **both** of the first two hold; jump to Tier C
when the third also holds:

1. **Severity** — a single violation is catastrophic and hard or impossible to
   reverse: secret/credential leak, destructive command (`rm -rf`,
   `git push --force`, history rewrite), data loss, or a broken public contract.
2. **Mechanical detectability** — a script/hook can decide the violation
   deterministically from the action, with a low false-positive rate. A rule that
   needs human judgement stays Tier A/B.
3. **Pre-action interception needed** — catching it at review (Tier B) is too
   late because the damage is already done; it must be blocked *before* the tool
   runs → Tier C hook.

Recurrence is an independent escalator: a rule violated **two or more times**
despite Tier A/B (the feedback flywheel of `lessons-accumulation.md`) earns
promotion to the next tier even at moderate severity — repeated cost outweighs
the wiring effort.

## CLASSIFICATION_EXAMPLES

| Rule | Severity | Detectable | Tier |
|:--|:--|:--|:--|
| Block secret / `.env` read | catastrophic | yes | C (pre-tool hook) |
| `rm -rf`, force-push, history rewrite | catastrophic | yes | C (`/careful` on-demand) |
| Edit outside debugging scope | moderate | yes | C candidate (`/freeze <dir>`) |
| Thin agent-entry, no policy dump | high | yes | B (contract test) |
| Contradictory directives in context | high | partial | B (WU-1 detector) |
| Writing discipline (no preamble/hedging) | low | partial | A/B (review lens) |

## DECLARATIVE_BOUNDARY_SURFACE

A boundary action — irreversible, security-sensitive, or anything needing
confirmation or audit — deserves a **typed declarative surface** (a dedicated
tool/hook/command with typed arguments), not a prose instruction. Typed
surfaces can be intercepted, gated, rendered, and audited; prose can only be
hoped about. This is the same discipline as the typed event bus and capsule
field contract (`sub-agent-capsule-contract.md`), applied to the enforcement
layer — and the external validation of Tier C: promote the action itself to a
surface the harness can see ("Harnessing Claude's intelligence", 2026-04-02,
by-reference). Two corollaries from the same source: a secondary automated
validator sitting behind one boundary surface beats proliferating bespoke
gate tools; and prefer general tools the model already masters over bespoke
interfaces (the kernel's narrow-tool-surface rule, externally validated).

## WIRING_HOME

Tier-C promotions land on the hook surface SFS already owns: `install.sh`
registers `.claude/settings.json` hooks (the Stop-hook registration added in
0.8.23). On-demand session-scoped candidates `/careful` (block irreversible
shell) and `/freeze <dir>` (scope-lock edits) are tracked in
`skill-catalog-discipline.md` (`ON_DEMAND_GUARDRAIL_CANDIDATES`) — this policy is
the *criteria* for promoting into them; do not re-document the candidates here.
Wire a Tier-C hook only with owner sign-off; until then record the promotion
decision and the target hook so it is a tracked proposal, not an orphaned idea.

## CROSS_REFERENCES

- End-to-end loop map (hook/gate promotion is part of the APPLY stage;
  invariants declared once there): `self-improvement-loop.md`.
- Typed-surface vein (capsule field contract): `sub-agent-capsule-contract.md`.
- On-demand guardrail candidates + nine-category lens: `skill-catalog-discipline.md`.
- Recurrence → guardrail feedback loop: `lessons-accumulation.md`.
- Security/destructive-action review evidence: `agentic-security-logging-pack.md`.
- Mainline protection the hooks reinforce: `mainline-focus-guard.md`.
</content>
