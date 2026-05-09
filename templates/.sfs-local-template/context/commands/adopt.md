---
id: sfs-command-adopt
summary: Adopt existing projects into a compact SFS baseline without document sprawl.
load_when: ["sfs adopt", "adopt", "legacy baseline", "existing project", "documentation cleanup"]
---

# Adopt Command Context

Applies to `sfs adopt`.

Rules:
- Run the adapter first and keep stdout/stderr verbatim.
- `adopt` is bash-first for the repository scan and archive policy; AI-side work is a compact interpretation of the adapter result, not a replacement for it.
- A quoted free-text brief is valid: `sfs adopt "docs cleanup and current-state handoff"`.
- Default mode is dry-run. If the user clearly wants files created, use `sfs adopt --apply "<brief>"`; otherwise show the dry-run result and ask before applying.
- Shared visible output is intentionally one handoff file under
  `docs/<workspace>/<yyyyMMdd>/handoff.md`. For adopt, `<workspace>` is the
  adopt id (`legacy-baseline` by default, or `--id <name>`). Raw scan evidence
  belongs under `.sfs-local/archives/adopt/...`.
- Apply `policies/deprecation-and-migration.md`: legacy visible state is a
  liability unless it still earns its place. Archive or remove residue only
  after the durable handoff path exists, and report how to recover cold
  evidence.
- `adopt --apply` must not leave an active sprint pointer. It summarizes and
  cleans the legacy state; the first real sprint starts afterward.
- Do not expand old sprint/archive material into the active working context unless the user asks for archaeology or recovery.
- After apply, the next useful move is usually `sfs start "<first real cleanup slice>"`, then Gate 2 (Brainstorm) if scope is still fuzzy.
