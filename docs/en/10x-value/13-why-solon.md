---
doc_id: sfs-10x-value-en-13
title: "Why Solon — what survives is work structure"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-07-12
parent: docs/en/10x-value.md
summary: "Most AI advice decays fast. The surviving asset is work structure — context design / evaluation discipline / harness mindset — and Solon is exactly that bundle."
load_when: "Read for the 'why Solon' framing when positioning the product or onboarding a skeptic."
---
## Why Solon — what survives is work structure

Prompts, extensions, and "this week's strongest model" advice decay fast. When
the model changes the effect shifts, when a policy changes an extension dies, and
the rankings flip next week. Only the pace is new (multi-year cycles → months);
the pattern is a rerun of IT history. (Framing source: lecture note 24 —
specific citations such as Karpathy's "Software is changing again" are
by-reference.)

### The 10% that does not decay

The surviving asset is not a model name, it is **work structure**:

- **Context design** — what you tell it, what you make it remember, and the
  constraints you make it work under.
- **Evaluation discipline** — the criteria and pass conditions for verifying
  results. The real skill of the AI era.
- **Harness mindset** — which workbench you put the model on, and what inputs,
  tools, and verification loops you give it. Tool design, orchestrator /
  sub-agent patterns, and standard protocols (MCP) live here.

### Solon = that bundle

Solon implements those three as a product:

- Context design → **routed context** (kernel / commands / policies, loaded on
  demand).
- Evaluation discipline → the **Gate system** and flowcheck (per-unit self-check
  and pass conditions).
- Harness → **7-step / loop** + the six-division council + host-agnostic entry
  (including MCP).

So Solon is not "a pile of the latest tools" — it is *a workbench that makes the
non-decaying 10% the default*. Swap the model freely (the config-review cadence
assumes you will); the structure on top stays. Same direction as the advice to
run small things rather than hoard bookmarks — Solon formalizes that "run small"
as the 7-step.

### External evidence (by-reference)

A seller with no coding background started by picking his single most painful
recurring task and having the AI build the fix, then went on to redesign his
team's workflows and move into a GTM-PM role (source: Anthropic blog "How one
Anthropic seller rebuilt his team's workflows", 2026-06-05, by-reference —
figures/org details are claims at publication time). It is outside evidence for
the claim above: the surviving asset is not a "coding background" but *the
ability to design work structure* — the most direct proof for Solon's target,
the non-technical one-person operator.

A large-scale usage-session analysis points the same way: the majority of use
was non-development work, and the biggest block was the connective work
*between* roles — business operations and content production (reports,
trackers, decks), the "work around the work" (source: Claude blog "How people
are using Claude Cowork", 2026-07-07, by-reference — figures stay in the
source, not copied here). In a one-person company all of that connective work
falls on the operator. This is the data backing for Solon's target narrative:
structuring delegation is half the value.
