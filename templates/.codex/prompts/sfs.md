# Solon SFS — Codex legacy prompt

Prefer project `.agents/skills/sfs/SKILL.md`. This fallback keeps the same
router contract.

Arguments: `$ARGUMENTS`

1. Run the platform adapter first: `sfs <command> <args>` on macOS/Linux/Git
   Bash/WSL, `sfs.cmd <command> <args>` on Windows PowerShell/cmd.
2. If Windows execution fails before SFS starts with Git Bash
   `couldn't create signal pipe, Win32 error 5`, rerun the same command via
   `sfs.cmd ...` outside the sandbox. If that run is empty or fails, report the
   exact stdout/stderr and ask for `sfs.cmd --help`.
3. Empty adapter output is not success for visible SFS commands. `start`,
   `brainstorm`, `plan`, `implement`, `review`, `retro`, `adopt`, `profile`,
   `upgrade`, and `agent install` must print output or change their expected
   artifact. For `start`, verify `.sfs-local/current-sprint` and the sprint
   directory exist before reporting success.
4. Print adapter stdout/stderr verbatim.
5. Read `.sfs-local/context/kernel.md`, `_INDEX.md`, then only the routed module.
6. For hybrid commands, refine pointed artifacts and answer with one Solon report.
7. AI-era fundamentals apply across all gates, not only implement: shared design
   concept, domain language, feedback loop, interface/artifact boundary, and
   gray-box delegation.
8. For implementation and review work, follow the routed context guardrails:
   surface material assumptions, choose the smallest useful slice, keep changes
   surgical, read actual files/errors before fixing, verify before completion,
   and report exact evidence.
   Gate 3 (Plan) ready-for-implement routes to `sfs review --gate 3` first;
   do not offer `sfs implement` or worker/model handoff until plan review
   passes. Keep C-Level and worker/generator responsibilities separate: C-Level
   owns intent, architecture, AC, and review handoff; worker/generator owns
   fixed implementation slices.
   Codex worker default is `gpt-5.3-codex`; `gpt-5.3-codex-spark` is helper-only
   for bounded mechanical subtasks after scope/files_scope/AC are locked.
   Complex shared behavior escalates to high reasoning before coding.
   Multi-agent implement is optional, never the default: use single-agent mode unless the user selects parallel agents, each lane has disjoint files_scope and a clear native-language commit message, and post-implement cross review is recorded before Gate 6. Commit messages default to the user's native/workspace language; English is only the default when that is the user or repo language.
   Gate 3 review must self-review until PASS before cross review. Review round
   count, lens count, or "enough review" is not a PASS; partial/fail routes to
   rework and same-gate self-review.
9. Decision questions must be self-contained: before any `Q1`, `D1`, or option
   id, explain in plain user language what is being decided, why it matters, the
   recommended default, and what each option changes. Labels are
   cross-references, not the explanation.
