---
id: sfs-command-start
summary: SFS start/status-class commands keep adapter output verbatim, then may add compact state and Next.
load_when: ["sfs start", "start", "new sprint", "status-class", "bash-first"]
---

# Start / Bash-First Command Context

Applies to `sfs start` and similar bash-first commands (`status`, `guide`,
`auth`, `version`, `commit`, `loop`) unless a more specific routed module
exists.

Rules:
- Run the adapter first and show stdout/stderr verbatim.
- "Bash-first" means no AI-side artifact refinement. It does not forbid a
  short user-facing Solon recap/status after the verbatim adapter output.
- For `start`, adapter stdout should include exactly one `next:` line. If that
  line is already enough, do not add a second multi-step plan.
- Do not create or imply durable `report.md` creation for `start`. The durable
  sprint `report.md` lifecycle belongs to `report`, `retro`, or `tidy`.
- After `start`, infer `Next` from sprint mode:
  - fresh discovery/planning goal -> `sfs brainstorm "<raw goal/context>"`
  - inherited implementation sprint -> first implementation slice + `log.md`
    evidence, then later `sfs review --gate G4`
  - unclear mode -> ask 1 blocking question or point to `sfs status`
- A compact chat Solon report is allowed when it adds state or next action, but
  it must not paraphrase or contradict adapter stdout.
