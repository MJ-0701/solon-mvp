---
id: sfs-command-review
summary: Run or summarize review evidence without letting the generator self-approve.
load_when: ["review", "검토", "CPO", "verdict", "gate"]
---

# Review

- Adapter-run by default: run `sfs review ...` before summarizing.
- Do not create a new verdict from memory; use `review.md` and recorded result paths.
- Summaries should list verdict, findings, required actions, evidence, and next gate.
  Show gates as `Gate N (Name)`, for example Gate 6 (Review), not a naked
  internal id.
- The generator does not self-approve its own implementation.
- Review the whole contract, not only changed code: shared intent, domain
  language consistency, feedback evidence, interface/artifact boundaries, and
  gray-box delegation should still match the Gate 2/3 record.
- Load `policies/knowledge-pack-router.md` first, or
  `policies/knowledge-pack-router.ko.md` for Korean preference. Read matching
  full division packs only when explicitly needed for review scope and from router
  mapping.
- For backend/JVM/Spring/JPA/transaction/batch/integration/DevOps/AWS work,
  check matching ids from `policies/backend-knowledge-pack.md` or
  `policies/backend-knowledge-pack.ko.md`.
  Flag both missing high-risk topics and over-activated topics for the project
  size.
- For strategy-pm, QA, design/frontend, infra, or taxonomy work, read the
  matching `policies/*-knowledge-pack.md` or `policies/*-knowledge-pack.ko.md`
  file and check only the matching ids.
  Flag both missing high-risk division topics and over-activated topics.
