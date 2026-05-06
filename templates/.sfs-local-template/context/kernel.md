---
id: sfs-kernel
summary: Minimal rules every Solon agent reads before acting.
load_when: ["always", "sfs", "entry"]
---

# SFS Kernel

- Run `sfs <command>` first; bash adapter output is SSoT and must be verbatim.
- Bash-first means no AI-side artifact refinement; it does not mean "no Next".
- Start from `sfs status`; read current sprint `report.md` only when one exists.
- Shared durable Solon docs live under `docs/solon/`; `.sfs-local/` is private
  local workbench state and should remain thin.
- Stop on mutex conflicts and report owner/domain.
- Ask only 1-3 blocking questions.
- Decision questions must be self-contained: before any `Q1`, `D1`, or option
  id, explain in plain user language what is being decided, why it matters,
  the recommended default, and what each option changes. Labels are
  cross-references, not the explanation.
- After adapter output, read only the context module routed by `_INDEX.md`.
- Before work can branch, surface material assumptions, tradeoffs, and the
  simpler path when it matters. If shared intent is still unclear, ask the
  smallest blocking question instead of guessing.
- Prefer the minimum useful slice. Do not add speculative flexibility,
  abstractions, adjacent cleanup, or formatting churn that is not traceable to
  the request.
- Read actual files, command output, and error logs before fixing. Do not apply
  memory-pattern fixes until the current evidence explains the failure.
- If files changed, verify with the smallest relevant test, build, smoke, or
  review check before saying complete. Report the exact check and result; if no
  check can run, say why.
- When answering in Korean, do not end Korean sentences with a closing colon.
- For Korean-first projects, new source files should start with a one-line
  Korean role comment directly after any required shebang or directive. Skip
  config, generated, and lock files.
- Keep plan/checklist/context notes inside the current SFS workbench artifacts
  unless the user explicitly asks for root-level files.
- Token/harness hygiene is ambient: keep adapter memory thin, prefer routed
  context and symbol/semantic search before broad reads, and convert repeated
  AI mistakes into guardrails/checks during review or retro.
- AI-era software fundamentals are all-phase guardrails, not only implement
  rules: shared design concept, ubiquitous language, tight feedback loops,
  deep-module boundaries, and gray-box delegation must shape brainstorm, plan,
  implement, review, report, and retro.
- Multi-agent work is thin supervision, not noisy coordination by default:
  use read-only research, fixed-scope worker slices, and independent review only
  when they reduce context pollution or self-validation risk. Share results
  through current SFS workbench artifacts, not through long copied transcripts.
- Do not advance a gate just because raw requirements exist. If shared intent,
  domain terms, acceptance checks, or interface boundaries are unclear, stop at
  the current gate and ask the smallest blocking questions before moving on.
