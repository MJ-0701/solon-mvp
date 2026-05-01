---
phase: report
status: final
sprint_id: sfs-doc-tidy-release-notes
goal: "SFS doc tidy command + update awareness + release notes policy"
created_at: 2026-05-01T21:52:50+09:00
last_touched_at: 2026-05-01T12:54:11+00:00
closed_at: 2026-05-01T12:54:11+00:00
---

# Report — SFS doc tidy command + update awareness + release notes policy

> Sprint completion report. This is the concise, final artifact for a closed
> sprint. The other sprint files are workbench artifacts: they may be verbose
> while work is active, but completed work should be read from this report first.
> After close/tidy, workbench originals may live under `.sfs-local/archives/`.
> Raw history belongs in `retro.md`, archived workbench files, session logs,
> and events.jsonl.

---

## §1. Executive Summary

- **Goal**: Make completed SFS sprint workbench docs cleanly archivable, make
  update/release-note discovery explicit, and enforce release-note presence
  before product release cuts.
- **Outcome**: done
- **Final verdict**: G4 `pass`
- **One-line result**: `sfs tidy` and the close/compact lifecycle now preserve
  workbench evidence under archive while leaving `report.md`/`retro.md` as the
  durable reading path.

## §2. Final Scope

- **Delivered**:
  - `sfs tidy` dry-run/apply flow with `--sprint <id-or-ref>` and archive-first
    cleanup semantics.
  - Shared workbench archive behavior for `sfs tidy`, `sfs report --compact`,
    and `sfs retro --close`.
  - Matching tmp review prompt/run artifact archival for the closed sprint.
  - Docs/adapter wording for `sfs upgrade`, `sfs version --check`, SFS as
    Solo Founder System, and release-note discovery.
  - `cut-release.sh --apply` preflight that blocks missing target
    `CHANGELOG.md` entries with exit `8`.
- **Explicitly not delivered**:
  - GUI/archive browser, automatic background update notifier, historical bulk
    cleanup of every existing sprint, or a restore command.
- **Carried forward**:
  - Optional archive exploration/restore UX and broader queue/loop follow-up
    work are split into separate backlog items.

## §3. Key Decisions

- **Named cleanup command** — chose explicit `sfs tidy` over hiding cleanup
  inside `report --compact`, because users need a discoverable migration path
  for already-noisy sprint folders.
- **Archive, do not delete** — workbench docs and tmp review artifacts move
  under `.sfs-local/archives/`; durable sprint folders keep final reading
  artifacts visible.
- **Release-note-first publish** — product release cuts require a target
  changelog entry so Homebrew/Scoop users can see what changed.

## §4. Implementation Summary

- **Changed files/modules**:
  - Active SFS scripts: `sfs-tidy.sh`, `sfs-common.sh`, `sfs-report.sh`,
    `sfs-retro.sh`, `sfs-dispatch.sh`.
  - Product distribution: `bin/sfs`, `.sfs-local-template/scripts/*`,
    README/GUIDE/SFS/agent adapters, report template, `.gitignore`, changelog.
  - Release tooling: `2026-04-19-sfs-v0.4/scripts/cut-release.sh`.
- **Behavior added/changed**:
  - Dry-run is default; `--apply` creates `report.md` when missing and archives
    workbench files instead of writing redirect stubs or deleting content.
  - Short sprint refs are accepted when they uniquely match a sprint suffix.
  - `report --compact` and `retro --close` use the same archive-first helper.
- **Compatibility notes**:
  - `sfs update` remains an alias for `sfs upgrade`.
  - No automatic cleanup runs without explicit command/close action.

## §5. Verification Evidence

- **Commands/checks**:
  - `bash -n` over active/product SFS scripts and `cut-release.sh`.
  - `sfs tidy` dry-run on current sprint, named sprint, and bare current-sprint
    default.
  - Fresh temp project `sfs tidy --apply` archive smoke with visible tree and
    recovery checks.
  - Fresh temp project `sfs report --compact` and `sfs retro --close`
    regression smokes.
  - Docs/release `rg` checks for tidy/upgrade/version/SFS naming/archive and
    Added/Changed/Fixed release-note wording.
  - Missing release-note preflight:
    `cut-release.sh --version 9.9.9-product --apply --allow-dirty --allow-divergence --no-tag`.
- **Result**:
  - Syntax checks passed.
  - Dry-run left `git status --short` unchanged in a fresh repo.
  - Apply/compact/close smokes left only `report.md` and `retro.md` visible and
    archived workbench/tmp evidence.
  - Missing release note failed with exit `8` and `release note required before --apply`.
  - CPO G4 review result: `pass`
    (`.sfs-local/tmp/review-runs/sfs-doc-tidy-release-notes-G4-20260501T125053Z.result.md`).
- **Manual smoke/inspection**:
  - Archive file lists and recovery checks confirmed original workbench content
    remains recoverable.

## §6. Risks / Follow-ups

- **Remaining risks**:
  - CPO review was cross-instance Codex, not cross-vendor, because `claude` and
    `gemini` review executors were unavailable.
  - Working tree also contains unrelated pending `0.5.51-product` `sfs adopt`
    cold-archive changes; keep them out of this sprint close/release payload.
- **Next sprint candidates**:
  - Queue lifecycle split and multi-worker smoke.
  - Event emit restoration/audit.
  - Adapter/dispatch docs parity audit.
  - Archive exploration/restore UX, if users need it after `tidy`.
- **Open questions**:
  - None for closing this sprint.

## §7. Artifact Map

- `.sfs-local/archives/.../brainstorm.md` — archived workbench: raw context and problem shaping
- `.sfs-local/archives/.../plan.md` — archived workbench: sprint contract and AC
- `.sfs-local/archives/.../implement.md` — archived workbench: implementation slice evidence
- `.sfs-local/archives/.../log.md` — archived workbench: chronological notes and smoke outputs
- `.sfs-local/archives/.../review.md` — archived evidence: CPO verdict and required actions
- `retro.md` — history: KPT/PDCA learning and retrospective context
