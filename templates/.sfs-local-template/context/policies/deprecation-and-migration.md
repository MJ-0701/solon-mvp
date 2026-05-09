---
id: sfs-policy-deprecation-and-migration
summary: Remove or migrate legacy code/state only after replacement, handoff, and verification exist.
load_when: ["deprecation", "migration", "legacy", "adopt", "tidy", "upgrade", "cleanup"]
---

# Deprecation And Migration

Use this policy for legacy project adoption, visible residue cleanup, old
runtime migration, public API replacement, and dead-code removal.

Principles:
- Old code, old state, and old documents are liabilities unless they still earn
  their visible cost.
- Removal needs a replacement path: new behavior, new handoff, cold archive,
  migration guide, or explicit user decision.
- Do not keep a visible file just because it might be useful someday. If its
  keep reason cannot be stated in one sentence, archive or remove it after
  durable handoff evidence exists.
- Advisory deprecation is for low-risk optional migration. Compulsory
  deprecation needs a reason such as security, data loss, blocked progress, or
  unsustainable maintenance, plus tooling or clear steps.
- Hyrum's-law surfaces matter: CLI flags, output paths, persisted data shape,
  public API behavior, and automation-consumed text need migration notes before
  change.

Adopt/tidy/upgrade application:
- Create or update `docs/solon/<english-workspace>/<yyyyMMdd>/handoff.md`, `report.md`, or
  `retro.md` before removing visible workbench/history state.
- Cold-archive recoverable evidence under `.sfs-local/archives/...`; do not
  expand it into active context unless the user asks for archaeology.
- Verify zero active dependency before deleting a visible legacy pointer.
- Migration output should say what moved, where the durable handoff lives, and
  how to recover archived evidence.

Verification:
- Replacement/handoff path exists.
- Archive or migration manifest names what moved.
- Active pointers do not reference removed state.
- Public surfaces changed intentionally and are documented.
