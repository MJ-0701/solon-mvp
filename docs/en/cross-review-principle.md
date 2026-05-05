# What Cross-Review Is Really About

**Language**: English / [한국어](../ko/cross-review-principle.md)

> Solon's sprint flow defaults to a CTO Generator ↔ CPO Evaluator
> cross-review structure. This document explains *why* — grounded in the
> actual discovery path of the 0.6.1 → 0.6.2 hotfix, not in abstractions.

## One-line summary

Cross-review's value isn't **"multiple models giving opinions"** — it's
**"diversity of evaluation surfaces."** When the surface is single, three
models will share the same blind spot.

## Case study — `sfs upgrade` crash in 0.6.1

### Facts

- 0.6.1 release pre-verification passed: `tests/run-all.sh` **30/30**,
  `sfs doctor` **7/0/0**, placeholder scan / mirror check / `git diff --check`
  all clean.
- Codex / Claude / Gemini each touched the build/review pipeline at least
  once and all three passed the release artifact.
- The first real user ran `brew install MJ-0701/solon-product/sfs` followed
  by `sfs upgrade` (no flags) and the command died immediately with:

  ```
  /opt/homebrew/Cellar/sfs/0.6.1/libexec/bin/sfs: line 848:
  dep_args[@]: unbound variable
  ```

- Codex review identified the root cause within 30 seconds: macOS bash 3.2 +
  `set -u` raises an unbound-variable error when `"${dep_args[@]}"` is
  expanded against an empty array. This was fixed in bash 4.4+, so Linux CI
  bash 5.x cannot reproduce it.

Hotfix details: see [CHANGELOG.md `[0.6.2]`](../../CHANGELOG.md).

### What let all three through

Every LLM-based step in build/review ran on the **same surface**:

- Same CI host (Linux)
- Same major bash version (5.x)
- Same test matrix (`tests/run-all.sh`)

The bash 3.2 nounset+empty-array idiom *is* something a static review can
catch in principle, but nothing in the review prompts triggered "this dies
on macOS bash 3.2," and no test ever stepped on that environment. All three
models shared the same blind spot.

### What did catch it

**The first real user's macOS shell.** Codex's role was to convert that one
stderr line into a diagnosis — diagnostic review, not artifact review.

That last axis is what this principle is built on.

## The real axes of cross-review

| Axis | Meaning | Was 0.6.1 monocultural here? |
|---|---|---|
| **Model** | Codex / Claude / Gemini — different priors, different blind spots | Diverse ✓ |
| **Runtime / environment** | macOS bash 3.2 vs Linux bash 5.x, glibc vs musl, encoding, etc. | **Single ✗** |
| **Role** | build / review / use / diagnose — different lenses | Conflated review with use ✗ |
| **Test matrix** | unit / integration / smoke / dogfood / production canary | Dogfood stage missing ✗ |
| **Time** | pre-release review vs first-install runtime | Same point in time ✗ |

The 0.6.1 artifact passed all three models because model diversity was real.
It still died because every other axis was single.

## How Solon's sprint flow handles this

Solon's **CTO Generator ↔ CPO Evaluator** is not just "two different
models." Splitting `generator` and `evaluator` roles still helps even with
the same underlying model, because the same model stands on **different
prompt context and a different evaluation surface** in each role.

The 0.6.2 hotfix gives concrete grounding for two more axes worth being
explicit about:

1. **The first real user is the last step of cross-review.**
   No matter how clean build/review look, `brew install` + first run isn't
   process noise — it's a designed step. Solon's release flow treats it as
   the **last evidence line of Gate 6 review**, not as "whatever happens
   after tests pass."
2. **Diagnostic review is most valuable when the diagnosing agent is not
   the building agent.** If the agent that wrote the `dep_args` idiom had
   also reviewed it, the bash 3.2 compatibility check sits squarely in the
   self-validation risk zone. Solon's `/sfs review` defaulting to
   `--executor codex` is the direct implementation of this — and
   `sfs-review.sh` warns when generator equals evaluator for the same
   reason.

## What this means for users

- **Most people use a single agent.** That's true and not a failure.
  Solon wants to deliver cross-review value to those users too — not as
  "more models," but as **"more surfaces."**
- Axes still alive even within a single agent:
  - `generator` vs `evaluator` role split (the sprint contract enforces it).
  - 1-person dogfood as the "real environment I actually use" axis (Solon's
    retro always asks this).
  - Diversifying the real CI / runtime matrix (see Process learning in
    CHANGELOG `[0.6.2]`).
- **One agent on multiple surfaces beats several agents on a single
  surface.** This case is the proof: three models passing on one surface
  was weaker than one user dogfooding on macOS bash 3.2.

## Receipts (observed cascade — 0.6.1 → 0.6.4 in under 24h)

The principle was validated three times, not once — on the **same source
line of the same release flow**. Each layer of the same blind-spot class
(monocultural test surface against an external CLI / runtime dimension)
peeled off, and the first real user's macOS shell caught the next layer.

| Receipt | release | source | What broke | Which surface caught it |
|---|---|---|---|---|
| #1 | 0.6.1 → 0.6.2 | `bin/sfs:848` `dep_args[@]` | macOS bash 3.2 + `set -u` empty-array expansion | macOS Homebrew bash 3.2 (different nounset behavior from Linux CI bash 5.x) |
| #2 | 0.6.2 → 0.6.3 | `scripts/sfs-release-sequence.sh:124` `brew audit --new-formula` | Homebrew removed the `--new-formula` flag | First real user's current Homebrew install (CI surface had no `brew`) |
| #3 | 0.6.3 → 0.6.4 | same line — `brew audit "${formula}"` | Homebrew disabled path-form `brew audit` | Same macOS Homebrew, next layer |
| #4 | 0.6.4 → 0.6.5 | same audit phase, this time `brew style` | `brew style` flagged (a) cut-release sha256 placeholder as 3 lint errors, plus (b) 6 real template style issues (sigils, frozen literal, class doc, components order, livecheck regex) | Same maintainer macOS Homebrew |

What the cascade reveals:

- **The default-surface trap of monocultural CI is self-reinforcing.**
  Fixing `--new-formula` immediately exposed the path-form removal in the
  very next attempt — proof that "external CLI change" is a **continuous
  surface**, not a one-off. Without a maintainer-macOS-shell evidence
  trail in the release flow, every build/review pass hides another layer.
- **Model diversity does not solve this.** None of the three receipts was
  pre-empted by Codex / Claude / Gemini review alone. The structural fix
  is to put a real macOS Homebrew step into the CI/release matrix
  (= surface diversity).
- **Round-trip time as a process signal.** The fact that receipts #1 → #2
  → #3 fell within 24h shows the user-dogfood stage was already designed
  into the release flow — cross-review isn't a process accident here, it's
  an intended step.

## In one sentence

> **Cross-review's value comes from surface diversity, not model count.
> Receipts #1–#4 across 0.6.1 → 0.6.5 are the evidence for that claim.**

## See also

- [CHANGELOG `[0.6.2]`](../../CHANGELOG.md) — release record for this case
- [Current product shape](./current-product-shape.md) — sprint flow's
  default cross-review structure
- [Solon's 10x value](./10x-value.md) — design philosophy that keeps the
  user in the product-owner seat
