---
doc_id: sfs-current-product-shape-domain-knowledge-assets-en
title: "Domain Knowledge Assets"
visibility: oss-public
doc_type: product-reference-section
language: en
updated: 2026-05-28
summary: "Expert know-how becomes durable leverage when SFS compiles it into AI-usable assets."
load_when: "Read when the user wants to turn domain expertise, repeated explanations, or craft rules into reusable SFS memory."
---
# Domain Knowledge Assets

In the AI era, generic coding skill is less of a moat because more people can
reach a similar code generator. The harder-to-copy advantage is expert domain
knowledge: the words, edge cases, taste, examples, counterexamples, and "here we
do it this way" rules that live in a practitioner's head.

Solon treats that knowledge as an asset only after it becomes reusable by an
agent. A useful asset can be a glossary, domain map, playbook, checklist,
knowledge pack, review lens, skill, fixture, test, or wiki TopicHub. The form
depends on what will make the next sprint behave better.

The six-division council is the product's default collector for those assets.
Strategy-PM catches positioning and priority judgment; taxonomy catches naming
and classification; design catches workflow, copy, and taste; dev catches
architecture and invariants; QA catches risk and acceptance edge cases; infra
catches reliability, security, deployment, and rollback knowledge. Each relevant
division row should name an `asset_candidate` so repeated know-how has a path
from one task into durable SFS memory.

That path is executable in the sprint artifacts. Plan has `Domain Asset Promotion Ledger`;
implementation records artifact path and verification; review checks source,
owner, confidence, and gaps before reuse or publication.

The rule is source first. Keep the raw note, interview, review comment, meeting
note, or support example in its original place. Then compile only the durable
meaning: the canonical terms, decision rule, risk signal, example, counterexample,
owner, confidence, gap, and the check that proves the knowledge changed behavior.

Skills are one possible output shape, not a new command by default. If a camera
operator, marketer, accountant, designer, support lead, or engineer has a repeatable
judgment pattern, SFS should first ask what smallest artifact makes that judgment
loadable and reviewable. Public sharing, paid distribution, attribution, private
notes, and IP boundaries stay human-owned decisions.
