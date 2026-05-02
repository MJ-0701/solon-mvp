---
id: sfs-kernel
summary: Minimal rules every Solon agent reads before acting.
load_when: ["always", "sfs", "entry"]
---

# SFS Kernel

- Run `sfs <command>` first; bash adapter output is SSoT and must be verbatim.
- Bash-first means no AI-side artifact refinement; it does not mean "no Next".
- Start from `sfs status` and current sprint `report.md`; avoid old logs unless needed.
- Stop on mutex conflicts and report owner/domain.
- Ask only 1-3 blocking questions.
- After adapter output, read only the context module routed by `_INDEX.md`.
- Token/harness hygiene is ambient: keep adapter memory thin, prefer routed
  context and symbol/semantic search before broad reads, and convert repeated
  AI mistakes into guardrails/checks during review or retro.
- AI-era software fundamentals are all-phase guardrails, not only implement
  rules: shared design concept, ubiquitous language, tight feedback loops,
  deep-module boundaries, and gray-box delegation must shape brainstorm, plan,
  implement, review, report, and retro.
- Do not advance a gate just because raw requirements exist. If shared intent,
  domain terms, acceptance checks, or interface boundaries are unclear, stop at
  the current gate and ask the smallest blocking questions before moving on.
