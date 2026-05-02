---
doc_id: handoff-next-session
title: "Next session handoff — 0.5.95 current truth + MD-size split execution"
written_at: 2026-05-02T17:52:38Z
written_at_kst: 2026-05-03T02:52:38+09:00
last_known_main_commit: e3c98ad
visibility: raw-internal
source_task: claude-cowork-doc-audit-split (mid-flight handoff)
session_codename: modest-charming-keller
---

# Next Session Handoff

## 1. Current Truth

- Latest Solon Product release is **`0.5.95-product`** (codex hotfix train 0.5.87-95 shipped 2026-05-03).
- Stable product repo: tag `v0.5.95-product` (stable sha not recorded individually for 87-95 — see release verifier outputs and tap repo logs).
- Homebrew tap and Scoop bucket: synced through 0.5.95.
- Dev repo main at this handoff: `e3c98ad` (release: 0.5.95-product update UX). **Plus the in-flight commit** of this session that lands the PROGRESS rotation + audit + this handoff.
- `solon-mvp-dist/VERSION` = `0.5.95-product`.
- `bash 2026-04-19-sfs-v0.4/scripts/resume-session-check.sh` should now return exit `0` after the in-flight commit (drift was resolved by repairing PROGRESS resume_hint and HANDOFF written_at to match 0.5.95).

## 2. What Last Session (claude-cowork:modest-charming-keller) Did

- **Phase A — Drift recovery for codex 0.5.87-95 train**: PROGRESS.md frontmatter `last_overwrite`, `session`, `current_wu_owner`, `scheduled_task_log`, `resume_hint.default_action`, `on_ambiguous`, `last_written` all rebased to 0.5.95 baseline. ③ Next note added explaining the codex train was not entered into PROGRESS bullets at release time.
- **Phase B — PROGRESS rotation**: ① Just-Finished + ④ Artifacts pre-0.5.93 bullets rotated verbatim to `archives/progress/PROGRESS-bullets-rotation-2026-05-03-pre-0.5.93.md` (with strict frontmatter trace per next-session split standard). PROGRESS.md down from 463 → 324 lines. 0.5.93/0.5.94/0.5.95 narratives written into the live ① + ④ from CHANGELOG content.
- **Phase C — Full repo MD audit**: comprehensive size + auto-load classification report at [`MD-SIZE-AUDIT-2026-05-03.md`](MD-SIZE-AUDIT-2026-05-03.md). Every MD file in the repo enumerated and tier-classified.
- **Phase D — Splits NOT executed**. Per safety constraint ("절대 누락 0"), all body-chapter / sprint / misc large-file splits are deferred to the next session for user-approved execution. See §4 below for the queue.

## 3. Validation Evidence

- PROGRESS.md trim verified by `wc -l` (463 → 324).
- Archive file integrity: 222 lines, frontmatter compliant with the split standard documented in `MD-SIZE-AUDIT-2026-05-03.md`.
- Auto-load chain unchanged this session (no entry stub touched).
- `release_handoff_drift` from `resume-session-check.sh` should clear once this commit pushes (PROGRESS resume_hint and this HANDOFF both reference 0.5.95-product).

## 4. Default Action for Next Session — MD split execution queue

> **Read this section first**, then read `MD-SIZE-AUDIT-2026-05-03.md` for the per-file detail.

### 4.1 Hard rules before any split

1. **Reference scan**: before touching any target file, run the path-reference grep:
   ```bash
   grep -rn '<target-relative-path>' --include='*.md' --include='*.sh' --include='*.yaml' --include='*.toml' \
     --exclude-dir='.git' --exclude-dir='archives' --exclude-dir='tmp' --exclude-dir='.claude/worktrees'
   ```
   If references exist, decide whether the split target file's path stays stable (file remains as parent stub at same path) or links must be rewritten.
2. **Frontmatter standard** (HARD): every new split file MUST contain the full set listed in `MD-SIZE-AUDIT-2026-05-03.md` "Frontmatter standard" section. No exceptions.
3. **Parent link stub** (HARD): the parent file gets a 1-line `> §X moved to [<file>](path) — split: <reason>. <session>, <ISO>.` at the original §-position.
4. **No splits to "DO NOT split" list** in `MD-SIZE-AUDIT-2026-05-03.md` ("Files that MUST NOT be split" section).
5. **Atomic per file** — one commit per split (`split: <file> §X+Y → <subdir>/`).
6. **After every commit**, run `bash 2026-04-19-sfs-v0.4/scripts/resume-session-check.sh` — must return exit `0`.

### 4.2 Tier 1 split queue (body design chapters — recommended first)

| Order | File | Lines | Suggested target |
|---|---|---|---|
| 1 | `07-plugin-distribution.md` | 1022 | `07-plugin-distribution/<sub-§>.md` × N |
| 2 | `05-gate-framework.md` | 956 | `05-gate-framework/<sub-§>.md` × N |
| 3 | `02-design-principles.md` | 940 | `02-design-principles/<sub-§>.md` × N |
| 4 | `10-phase1-implementation.md` | 827 | `10-phase1-implementation/<sub-§>.md` × N |
| 5 | `08-observability.md` | 709 | `08-observability/<sub-§>.md` × N |
| 6 | `04-pdca-redef.md` | 645 | `04-pdca-redef/<sub-§>.md` × N |
| 7 | `03-c-level-matrix.md` | 622 | `03-c-level-matrix/<sub-§>.md` × N |
| 8 | `06-escalate-plan.md` | 605 | `06-escalate-plan/<sub-§>.md` × N |

Pattern: keep parent file as TOC/index pointing at sub-files; each sub-file gets full frontmatter; INDEX.md / cross-ref-audit.md continue to reference parent path.

### 4.3 Tier 2 split queue (closed sprint files)

| Order | File | Lines | Target |
|---|---|---|---|
| 9 | `sprints/WU-23.md` | 406 | `sprints/WU-23/<sub-step>.md` (precedent: `sprints/WU-27/`) |
| 10 | `sprints/WU-20.md` | 340 | `sprints/WU-20/<sub-step>.md` |
| 11 | `sprints/WU-26.md` | 312 | `sprints/WU-26/<sub-step>.md` |

Keep parent `WU-XX.md` with frontmatter (`wu_id`, `final_sha`, etc.) intact; only body content moves to sub-files. Update `sub_steps_split: true` in parent frontmatter.

### 4.4 Tier 3 (misc large) — review case-by-case

See `MD-SIZE-AUDIT-2026-05-03.md` Tier 3 table. Pre-flight reference scan + user confirmation per file recommended.

### 4.5 §1.14 generalization (after splits land)

Once Tier 1+2 splits are exercised:
1. Update CLAUDE.md §1.14 from "CLAUDE.md 는 항상 ≤200 lines" → "단일 SSoT MD 파일 (CLAUDE.md, PROGRESS.md, HANDOFF, body-chapter parents 등) 은 ≤200 lines. 누적성 파일 (CHANGELOG, WORK-LOG, sessions, learning-logs) 은 예외".
2. Create `scripts/check-md-size.sh` and wire into `resume-session-check.sh` as check #9 (exit code 18 for size warning).
3. Add `cut-release.sh --apply` post-flight hook: rotate oldest ① Just-Finished + ④ Artifacts release bullet to `archives/progress/PROGRESS-bullets-rotation-<period>.md` automatically.
4. Create `learning-logs/2026-05/P-XX-md-rotation-pattern.md` companion to P-06 for the PROGRESS-style accumulation case.

## 5. Guardrails

- Do not bypass reference scan before splitting. The "절대 누락 0" rule from user is non-negotiable.
- Do not edit `solon-mvp-dist/CHANGELOG.md`, `WORK-LOG.md`, or any file in `archives/**` / `.sfs-local/**` / `.claude/worktrees/**` as part of MD splits. They are accumulation or runtime-managed.
- Do not undo recent 0.5.86 work on `solon-mvp-dist/GUIDE.md` / `BEGINNER-GUIDE.md` / `README.md`. They were intentionally trimmed and should not be split further without product UX review.
- Do not modify auto-loaded files (`.claude/agents/`, `.agents/skills/`, `.gemini/commands/`, root stubs). They are intentionally minimal.
- After a task branch is merged into `main`, do not use it for the next session; the next direct task gets a fresh branch from `main`.

## 6. Outstanding work the user asked about

- ✅ PROGRESS.md slim (this session — done).
- ⏸ §1.14 generalization (deferred to next session per user's "다음 세션에서 인계받아서 할께").
- ⏸ Full doc audit + split execution (this session: audit done, splits deferred — see §4 above).
- ⏸ Frontmatter standard for split files (defined in `MD-SIZE-AUDIT-2026-05-03.md`; ready for use).
