# Solon SFS — Codex legacy prompt

Prefer project `.agents/skills/sfs/SKILL.md`. This fallback keeps the same
router contract.

Arguments: `$ARGUMENTS`

1. Run `sfs <command> <args>` first.
2. Print adapter stdout/stderr verbatim.
3. Read `.sfs-local/context/kernel.md`, `_INDEX.md`, then only the routed module.
4. For hybrid commands, refine pointed artifacts and answer with one Solon report.
5. AI-era fundamentals apply across all gates, not only implement: shared design
   concept, domain language, feedback loop, interface/artifact boundary, and
   gray-box delegation.
6. For implementation and review work, follow the routed context guardrails:
   surface material assumptions, choose the smallest useful slice, keep changes
   surgical, read actual files/errors before fixing, verify before completion,
   and report exact evidence.
   Gate 3 (Plan) ready-for-implement routes to `sfs review --gate 3` first;
   do not offer `sfs implement` or worker/model handoff until plan review
   passes. Keep C-Level and worker/generator responsibilities separate: C-Level
   owns intent, architecture, AC, and review handoff; worker/generator owns
   fixed implementation slices.
   Gate 3 review must self-review until PASS before cross review. Review round
   count, lens count, or "enough review" is not a PASS; partial/fail routes to
   rework and same-gate self-review.
7. Decision questions must be self-contained: before any `Q1`, `D1`, or option
   id, explain in plain user language what is being decided, why it matters, the
   recommended default, and what each option changes. Labels are
   cross-references, not the explanation.
