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
- `sfs review` is an artifact acceptance review. Code review is only the
  `code` lens; docs, strategy, design, taxonomy, QA, ops, release, and generic
  artifacts use their own acceptance lens.
- Let the adapter's `review_lens` stand unless it is clearly wrong. Use
  `--lens <name>` only as an override.
- Review the whole contract, not only changed code: shared intent, domain
  language consistency, feedback evidence, interface/artifact boundaries, and
  gray-box delegation should still match the Gate 2/3 record.
- Surface the evaluator's next action. Pass should move toward report/retro;
  partial should name the smallest rework slice; fail should return to plan,
  implementation, or user escalation.
- If the review finds a repeated agent mistake, record the smallest harness
  improvement: guardrail/check/hook/context-rule. Claude users may map this to
  Hookify; other agents should use their equivalent hook or scripted check.
