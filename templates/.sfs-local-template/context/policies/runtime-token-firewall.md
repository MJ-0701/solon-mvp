---
id: sfs-policy-runtime-token-firewall
summary: Capsule-only handoff rules for worker, reviewer, and external executor bridges.
load_when: ["token", "harness", "worker", "review", "executor", "bridge", "Claude", "Codex", "Gemini"]
---

# Runtime Token Firewall

- Apply this when SFS hands work from a lead/C-Level agent to a worker,
  reviewer, external executor, plugin, or helper runtime.
- Capsule-only handoff is the default: pass the goal, acceptance criteria,
  files_scope, allowed edits, exact commands, expected output paths, and compact
  evidence references. Do not forward the lead agent's full conversation
  history, hidden chain, old workbench transcript, or unrelated prior turns.
- A bridge that forwards main-thread conversation history is non-compliant by
  default, even if it calls a cheaper model behind the scenes. It spends lead
  runtime tokens, weakens role separation, and makes review cost scale with the
  chat instead of the work slice.
- Claude in-process Codex/Gemini plugin wrappers, rescue subagents, or
  forked-context helpers must be treated as manual escape hatches, not the
  default SFS executor path. Prefer a real CLI bridge that reads a prompt from
  stdin and writes result/evidence files, or use `--prompt-only` for manual UI
  handoff.
- Poll artifacts, not thoughts: workers should write `status`, `result`,
  `evidence`, and touched-file manifests under the current workbench/run
  directory. The lead agent should inspect those compact artifacts instead of
  repeatedly rereading source files, diffs, build logs, or the main thread.
- Preserve the lead session for user intent and exception judgment. Repetitive
  phase sequencing belongs in scripts or run ledgers; each worker gets the next
  bounded capsule and writes back artifacts rather than inheriting the lead's
  live context.
- A docs diff, ADR delta, or compact run brief is preferred over a transcript
  when the worker needs to know what changed. If the change basis is missing,
  return partial/fail and ask for that artifact.
- Chat threads are not full-history handoffs. A channel or thread link may
  identify evidence, but the worker still receives a capsule; resuming an
  archived thread requires a compact summary artifact instead of replaying the
  whole chat.
- If evidence is insufficient, return partial/fail and name the missing
  artifact. Do not ask the host runtime to send the entire conversation or keep
  polling until context accumulates.
- Budget failure is a product finding. If a worker/review bridge repeatedly
  exceeds the expected token or wall-clock budget, record a harness finding and
  tighten the capsule, files_scope, or executor bridge before another run.
- Session continuation budget is separate from bridge budget. If the host
  session itself is already large, do not hide that by spawning another
  full-history worker or reviewer. Stop, capture a fresh-session handoff, and
  resume from artifacts in a new session.
