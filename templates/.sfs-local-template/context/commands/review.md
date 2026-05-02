---
id: sfs-command-review
summary: Run or summarize review evidence without letting the generator self-approve.
load_when: ["review", "검토", "CPO", "verdict", "gate"]
---

# Review

- Adapter-run by default: run `sfs review ...` before summarizing.
- Do not create a new verdict from memory; use `review.md` and recorded result paths.
- Summaries should list verdict, findings, required actions, evidence, and next gate.
- The generator does not self-approve its own implementation.
- Review the whole contract, not only changed code: shared intent, domain
  language consistency, feedback evidence, interface/artifact boundaries, and
  gray-box delegation should still match the G0/G1 record.
