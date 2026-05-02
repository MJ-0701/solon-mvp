# Solon SFS — Codex legacy prompt

Prefer project `.agents/skills/sfs/SKILL.md`. This fallback keeps the same
router contract.

Arguments: `$ARGUMENTS`

1. Run `sfs <command> <args>` first.
2. Print adapter stdout/stderr verbatim.
3. Read `.sfs-local/context/kernel.md`, `_INDEX.md`, then only the routed module.
4. For hybrid commands, refine pointed artifacts and answer with one Solon report.
