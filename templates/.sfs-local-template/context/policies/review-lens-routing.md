---
id: sfs-policy-review-lens-routing
summary: Split router for review lens aliases and knowledge-pack loading.
load_when:
  - review lens
  - lens routing
  - knowledge pack
  - source-docs
  - api-contract
status: filled-v1
parent_doc: commands/review.md
split_from_section: "Review lens aliases and knowledge-pack loading"
split_reason: "keep command review context under 200 lines while preserving routed lens settings"
content_policy: "read only when review lens aliases or knowledge-pack mapping are needed"
---

# Review Lens Routing

Use public lens names in commands. `strategy-pm` maps to `strategy`,
`design/frontend` maps to `design`, `infra` maps to `ops`, and
`finance`/`accounting` maps to `management-admin`.

Additional public lens names strengthen `sfs review` instead of creating new
commands:

- `source-docs`: official-source evidence for frameworks, libraries, APIs, or
  standards.
- `simplify`: behavior-preserving simplification.
- `security`: untrusted input, secrets, auth, PII, or permission risk.
- `performance`: measurement-backed latency, memory, bundle, or throughput
  review.
- `api-contract`: public interface, schema, compatibility, and error semantics.

Read order:

1. Read `policies/knowledge-pack-router.md`, or
   `policies/knowledge-pack-router.ko.md` for Korean preference.
2. Read only the matching parent pack, for example
   `policies/backend-knowledge-pack.md` or
   `policies/design-knowledge-pack.md`.
3. If the parent pack points to split child packs, open only the matching child
   file for the active AC, risk, or review lens, such as
   `backend-knowledge-pack-runtime.md`, `backend-knowledge-pack-transactions.md`,
   or `design-knowledge-pack-operating.md`.

Backend/JVM/Spring/JPA/transaction/batch/integration/DevOps/AWS work should
check matching ids from the backend split packs and flag both missing high-risk
topics and over-activated topics for the project size. Strategy, QA, design,
taxonomy, ops, and management/admin work should do the same with their matching
division packs.
