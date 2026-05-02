---
name: sfs
description: Solon SFS command router for Codex. Dispatch `$sfs` / `sfs` / visible `/sfs` text to the deterministic `sfs` bash adapter, then read only routed `.sfs-local/context` modules. `profile` is a narrow SFS.md project-overview refinement.
---

# Solon SFS — Codex Router

1. Prefer `$sfs <command>` or `sfs <command>`; `/sfs` is valid only if the text
   reaches the model.
2. Run `sfs <command> <args>` first. Vendored fallback:
   `bash .sfs-local/scripts/sfs-dispatch.sh <command> <args>`.
3. Keep adapter stdout/stderr verbatim.
4. Read `.sfs-local/context/kernel.md`, `_INDEX.md`, then only the routed module.
5. For bash-first commands, do not refine artifacts, but a compact state/Next is allowed.
6. For `profile`, edit only the `SFS.md` project overview section.
7. For hybrid commands, refine pointed artifacts and answer with one Solon report.
8. AI-era software fundamentals are cross-phase, not implement-only. Before a
   gate advances, check shared design concept, domain language, feedback loop,
   interface/artifact boundary, and gray-box delegation.
9. For `brainstorm`, ask 1-3 blocking questions when shared understanding is
   missing. Do not run or recommend `plan` as the next step until G0 is
   `ready-for-plan`.
10. For `plan`, derive the contract from `brainstorm.md`; unresolved G0
    questions stay visible instead of being hidden by assumptions.
