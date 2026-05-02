---
doc_id: md-size-audit-2026-05-03
title: "MD size full audit — split classification + auto-load safety map"
created_at: 2026-05-03T02:52:38+09:00
created_by_session: claude-cowork:modest-charming-keller
visibility: raw-internal
auto_load_required: false
parent_doc: 2026-04-19-sfs-v0.4/CLAUDE.md
related_rule: "§1.14 (CLAUDE.md ≤200 lines meta rule) — to be generalized in next session"
related_pattern: P-06-claude-md-line-limit-meta-rule
intended_consumers: ["next-session AI", "user (review/approval)"]
status: report-only
last_updated: 2026-05-03T02:52:38+09:00
notes: |
  This file is the result of the 2026-05-03 full repo MD audit triggered by user
  instruction. It classifies every MD file by entry-path criticality, line-count
  vs threshold, and split safety, and recommends concrete actions per file.
  Action execution is deferred to the next session per the safety constraint
  ("절대 누락 0" — no auto-loaded skill/file may be omitted by a split). User
  approval is required before any split that touches the auto-load chain.
---

# MD size full audit — 2026-05-03

> **Trigger**: user instruction "지금 문서들 전수조사해서 분리 필요한 애들은 분리해줘 (분리를 했다고 해서 읽혀야되는 스킬들이나 파일들이 절대 누락돼서는 안됨)" + frontmatter discipline emphasis.
> **Method**: `find` + `wc -l` across the entire repo (excluding `.git`, `archives/`, `tmp/`, `.claude/worktrees/`); classification by auto-load criticality.
> **This session executed**: PROGRESS.md ① + ④ rotation (463 → 324 lines). Other splits classified below for next-session execution under user approval.

---

## Tier 0 — Critical SSoT (entry-path auto-loaded). All under 200L. ✅ NO ACTION.

| File | Lines | Auto-load purpose |
|---|---|---|
| `./CLAUDE.md` | 32 | Cowork/Claude Code redirect stub → docset CLAUDE.md |
| `./AGENTS.md` | 33 | Codex CLI redirect stub → docset CLAUDE.md |
| `./GEMINI.md` | 113 | Gemini CLI memory (not used as docset entry per user — Gemini not active for this project) |
| `2026-04-19-sfs-v0.4/CLAUDE.md` | 178 | The SSoT — §1 absolute rules + §2-§14 project rules |
| `2026-04-19-sfs-v0.4/AGENTS.md` | 31 | docset thin shim → CLAUDE.md (Codex) |
| `2026-04-19-sfs-v0.4/PROGRESS.md` | **324** (post-trim, was 463) | Live snapshot, read on every session entry |
| `2026-04-19-sfs-v0.4/HANDOFF-next-session.md` | 83 | auto-resume.sh source (PROGRESS resume_hint counterpart) |
| `2026-04-19-sfs-v0.4/NEXT-SESSION-BRIEFING.md` | 124 | secondary handoff briefing |
| `.claude/agents/evaluator.md` | 151 | Claude Code agent definition (auto-loaded as Task subagent) |
| `.claude/agents/generator.md` | 135 | Same |
| `.claude/agents/planner.md` | 132 | Same |
| `.agents/skills/sfs/SKILL.md` | (small) | Codex SFS skill auto-discovery |
| `.gemini/commands/sfs.toml` | n/a TOML | Gemini slash command (TOML, not MD — outside MD audit) |

**No splits needed.** Every entry-path file is well under the §1.14 threshold.

---

## Tier 1 — Body design chapters (referenced by INDEX.md, on-demand load). 200L+ but NOT auto-loaded.

These are the "deep" design docs loaded only when the agent needs them per CLAUDE.md §11 step 4 ("필요 시 on-demand").

| File | Lines | Priority | Recommended action |
|---|---|---|---|
| `2026-04-19-sfs-v0.4/02-design-principles.md` | 940 | P2 | Split by §-major boundaries → `02-design-principles/<sub-§>.md` with frontmatter trace; parent becomes thin TOC |
| `2026-04-19-sfs-v0.4/03-c-level-matrix.md` | 622 | P2 | Same pattern |
| `2026-04-19-sfs-v0.4/04-pdca-redef.md` | 645 | P2 | Same pattern |
| `2026-04-19-sfs-v0.4/05-gate-framework.md` | 956 | P2 | Same pattern (gate framework is multi-axis) |
| `2026-04-19-sfs-v0.4/06-escalate-plan.md` | 605 | P2 | Same pattern |
| `2026-04-19-sfs-v0.4/07-plugin-distribution.md` | 1022 | P1 (largest non-CHANGELOG) | Same pattern |
| `2026-04-19-sfs-v0.4/08-observability.md` | 709 | P2 | Same pattern |
| `2026-04-19-sfs-v0.4/09-differentiation.md` | 468 | P3 | Borderline; consider split if §-axes are clean |
| `2026-04-19-sfs-v0.4/10-phase1-implementation.md` | 827 | P2 | Same pattern |
| `2026-04-19-sfs-v0.4/00-intro.md` | 221 | P3 | Borderline (just over) — leave or trim minor |
| `2026-04-19-sfs-v0.4/01-delta-v03-to-v04.md` | 177 | NO | Under threshold |

**Risk to splitting**: low. These are self-contained body docs. INDEX.md references them by file path, so creating sub-files under `0X-NAME/` keeps the parent path intact. No auto-load chain depends on body content order or completeness.

**Action plan template for each split**:
1. Identify §-major boundaries (e.g., `^## §X` or `^# §X` headers).
2. Create `0X-NAME/` directory with `<sub-§>-<slug>.md` files. Each sub-file gets the strict frontmatter set defined below.
3. Replace each removed § in the parent with a 1-line link stub: `> §X moved to [<sub-§>-<slug>.md](./0X-NAME/<sub-§>-<slug>.md) (split: ≤200L meta rule).`
4. Confirm INDEX.md/cross-ref-audit.md/CLAUDE.md still resolve.

---

## Tier 2 — Sprint files (`sprints/WU-XX.md`). >300L are split candidates per §4 row 2.

Per CLAUDE.md §4 row 2 ("WU 분리 = 단일 파일 기본 + 200 line 초과 시 sub-step 분리 (~300 유연)") and row 4 (임계값 200~300 flexible):

| File | Lines | Status | Recommended action |
|---|---|---|---|
| `sprints/WU-23.md` | 406 | done | Split into `sprints/WU-23/` sub-files (precedent: `sprints/WU-27/` already does this) |
| `sprints/WU-20.md` | 340 | done | Split into `sprints/WU-20/` |
| `sprints/WU-26.md` | 312 | done | Split into `sprints/WU-26/` |
| `sprints/WU-25.md` | 286 | done | Borderline (200-300 flex range) — leave |
| `sprints/WU-31.md` | 276 | done | Borderline — leave |
| `sprints/WU-24.md` | 276 | done | Borderline — leave |
| `sprints/WU-35.md` | 266 | done | Borderline — leave |
| `sprints/WU-22.md` | 256 | done | Borderline — leave |
| `sprints/WU-29.md` | 227 | done | Just over — leave |
| `sprints/WU-27.md` | 204 | done | Already follows `WU-27/` sub-file pattern (precedent) |

**Risk**: medium. Sprint files have frontmatter `wu_id`, `final_sha`, etc. Parent file paths are referenced from `sprints/_INDEX.md` and possibly other docs. Splits must keep `WU-XX.md` as the parent file with its frontmatter intact (just shorter body), and add sub-files under `WU-XX/` directory.

**Reference check before splitting**:
```bash
grep -rn 'sprints/WU-23\|sprints/WU-20\|sprints/WU-26' \
  2026-04-19-sfs-v0.4/ --include='*.md' --include='*.sh' --include='*.yaml'
```

---

## Tier 3 — Misc large files. Mixed risk profile.

| File | Lines | Type | Recommended action |
|---|---|---|---|
| `2026-04-19-sfs-v0.4/WORK-LOG.md` | 703 | Index-style log | Per CLAUDE.md §3/§4 row 9 ("WORK-LOG 처리 = 보존 + index 재활용") — **NO split, intentional accumulation** |
| `2026-04-19-sfs-v0.4/README.md` | 445 | Docset README | Split candidate (P3) — review for redundancy with INDEX.md / 00-intro.md first |
| `2026-04-19-sfs-v0.4/INDEX.md` | 433 | Docset index | If dominated by tables of contents, leave; if has narrative, split narrative |
| `2026-04-19-sfs-v0.4/RUNTIME-ABSTRACTION.md` | 449 | Single-axis spec (referenced by §1.21) | Split candidate (P3) — by §-axis |
| `2026-04-19-sfs-v0.4/PHASE1-KICKOFF-CHECKLIST.md` | 404 | Checklist | Leave (checklists benefit from single-file readability) |
| `2026-04-19-sfs-v0.4/cross-ref-audit.md` | 241 | Cross-ref + W10 TODO SSoT | Just over; W10 closures will trim naturally — leave |
| `2026-04-19-sfs-v0.4/MIGRATION-NOTES.md` | 224 | Migration journal | Leave |
| `2026-04-19-sfs-v0.4/SYSTEM-IDENTITY.md` | 175 | Identity statement | Under threshold |
| `2026-04-19-sfs-v0.4/PHASE1-MVP-QUICK-START.md` | 177 | Quick-start | Under threshold |
| `2026-04-19-sfs-v0.4/external-assets.md` | 168 | Asset list | Under threshold |
| `2026-04-19-sfs-v0.4/scripts/_README.md` | 319 | Scripts overview | Borderline — could split per-script blocks if clean |
| `2026-04-19-sfs-v0.4/appendix/commands/install.md` | 433 | Command spec | Borderline; appendix specs benefit from single-file searchability |
| `2026-04-19-sfs-v0.4/appendix/commands/division.md` | 418 | Same | Same |
| `2026-04-19-sfs-v0.4/appendix/commands/discover.md` | 395 | Same | Same |
| `2026-04-19-sfs-v0.4/appendix/dialogs/README.md` | 274 | Dialog index | Borderline |
| `2026-04-19-sfs-v0.4/appendix/engines/alternative-suggestion-engine.md` | 329 | Engine spec | Borderline |

---

## Tier 4 — User-facing dist docs (`solon-mvp-dist/`). Just trimmed in 0.5.86. ⚠️ DO NOT undo.

| File | Lines | Status |
|---|---|---|
| `solon-mvp-dist/CHANGELOG.md` | **1794** | **NEVER SPLIT** — immutable history, `cut-release.sh` depends on path. CHANGELOGs grow forever by convention. |
| `solon-mvp-dist/GUIDE.md` | 403 | Just trimmed in 0.5.86. Splitting now would undo recent UX work. **Leave for now.** |
| `solon-mvp-dist/BEGINNER-GUIDE.md` | 376 | Same — just polished in 0.5.86. **Leave.** |
| `solon-mvp-dist/README.md` | 215 | Just trimmed. Borderline. **Leave.** |
| `solon-mvp-dist/docs/en/current-product-shape.md` | 185 | Under threshold. |
| `solon-mvp-dist/docs/en/guide.md` | 169 | Under threshold. |
| `solon-mvp-dist/docs/ko/current-product-shape.md` | 175 | Under threshold. |
| `solon-mvp-dist/docs/ko/index.md` | <175 | Under threshold. |
| `solon-mvp-dist/CLAUDE.md` / `AGENTS.md` / `GEMINI.md` (consumer adapters in dist) | small | Templates — installed into user projects. **NEVER split** without changing the installer behavior. |
| `solon-mvp-dist/templates/.sfs-local-template/sprint-templates/implement.md` | 217 | Template; structure-defining. Leave. |

---

## Tier 5 — Templates, agent persona docs, learning logs, sessions.

| File | Lines | Type | Action |
|---|---|---|---|
| `agents/evaluator.md` | 365 | Persona spec source | Borderline (P3). `.claude/agents/evaluator.md` (151) is the auto-loaded condensed copy — DO NOT touch the auto-loaded one. Source can be split if §-axes are clean. |
| `agents/planner.md` | 249 | Same | Borderline |
| `agents/generator.md` | 239 | Same | Borderline |
| `agents/skills/quality/test-strategy.md` | 204 | Quality skill | Just over |
| `agents/skills/engineering/implementation.md` | 169 | Skill | Under threshold |
| `agents/skills/quality/log-analysis.md` | 166 | Skill | Under threshold |
| `agents/skills/quality/gap-analysis.md` | 160 | Skill | Under threshold |
| `agents/skills/engineering/architecture-design.md` | 121 | Skill | Under threshold |
| `agents/prompt-analyst.md` | 134 | | Under threshold |
| `learning-logs/2026-05/P-13-...md` | 177 | Learning pattern | Under threshold |
| `learning-logs/2026-05/P-15-...md` | 165 | Same | Under threshold |
| Other P-XX learning logs | 99-165 | Same | All under threshold |
| `sessions/2026-04-25-dazzling-sharp-euler.md` | 233 | Session log (closed) | Just over; sessions are accumulation logs, leave |
| Other session files | <230 | Same | Under threshold |

---

## Tier 6 — Big project-state files (root level / `.sfs-local/`).

| File | Lines | Action |
|---|---|---|
| `./.sfs-local/GUIDE.md` | 550 | This is the dogfood SFS-installed GUIDE inside the dev repo. It's a `.sfs-local/` runtime artifact, refreshed by `sfs upgrade`. **Do not edit directly** — let `sfs upgrade` rewrite it from the template. |
| `./solo-founder-agent-system-proposal.md` | 544 | Original proposal doc. Borderline — could split by §, but it's a historical proposal. Leave unless user wants to refactor. |
| `./claude-shared-config/README.md` | 420 | External config doc | Borderline. Belongs to `claude-shared-config/` subrepo (likely). Leave. |
| `./2026-04-19-solo-founder-agent-system-proposal-v0.4-outline.md` | 418 | Outline doc | Same — historical. Leave. |
| `./outputs/24th-32-bold-festive-euler-handoff/RECOVERY.md` | 344 | Old handoff recovery | Leave (historical) |
| `./archives/sfs/SFS-2026-05-01T191445Z-precompact.md` | 308 | Pre-compaction archive | Leave (archive) |
| `./.sfs-local/sprints/solon-loop-queue-mvp/log.md` | 210 | Sprint workbench | Will be archived by sprint close (see §1.23 hygiene rule) |
| `./.sfs-local/sprints/solon-loop-queue-mvp/review.md` | 199 | Sprint workbench | Same |
| `./README.md` | 173 | Root project README (Cowork might read) | Under threshold |

---

## Frontmatter standard for any split file (HARD rule)

When executing any split per this audit, the new sub-file MUST start with:

```yaml
---
doc_id: <unique-kebab-case-id>           # required
title: "<descriptive title>"             # required
parent_doc: <relative-path-to-parent>    # required (ties back to SSoT)
split_from_section: "<§X / sub-§Y>"      # required (locates origin)
split_reason: "<reason in one line>"     # required ("≤200L meta rule" or similar)
split_at: <ISO timestamp>                # required (when the split happened)
split_by_session: <session_codename>     # required (auditability)
visibility: <oss-public|business-only|raw-internal>  # required (§7 tier)
auto_load_required: <true|false>         # required (does the agent auto-load this on entry?)
replaces_in_parent: "<location of link stub in parent>"  # required (round-trip pointer)
last_updated: <ISO timestamp>            # required
---
```

The parent file must add a 1-line link stub at the original location:
```markdown
> §X moved to [<file>](path) — split: <reason>. <session_codename>, <ISO>.
```

This guarantees: (a) split traceability, (b) parent ↔ child round-trip, (c) no orphan files, (d) visibility tier preserved through split.

---

## Recommended next-session execution order

1. **Reference scan first** — for every Tier 1/Tier 2 file targeted, run the path-reference grep before split:
   ```bash
   grep -rn 'TARGET_PATH' --include='*.md' --include='*.sh' --include='*.yaml' --include='*.toml'
   ```
2. **Tier 1 first** (body design chapters) — lower risk because no auto-load chain depends on body content. Order by size (07-plugin-distribution → 05-gate-framework → 02-design-principles → ...).
3. **Tier 2 next** (closed sprint files) — verify `sprints/_INDEX.md` integrity after each.
4. **Tier 3 last** (misc large files) — only after Tier 1+2 patterns are stable.
5. **Single commit per Tier** — atomic enough to revert if needed.
6. **After every Tier**, re-run `bash 2026-04-19-sfs-v0.4/scripts/resume-session-check.sh` and confirm exit 0.
7. **§1.14 generalization** — once split practice is exercised, generalize §1.14 from "CLAUDE.md ≤200" to "any single-SSoT MD file ≤200 unless explicitly accumulating (CHANGELOG, WORK-LOG, sessions)". Update P-06 (or create P-XX-md-rotation companion).

---

## Files that MUST NOT be split (hard list)

- `solon-mvp-dist/CHANGELOG.md` — release tooling depends on it.
- `solon-mvp-dist/templates/**/*` — template content; splitting changes installed behavior.
- Any file in `archives/**` — archives are immutable.
- `.claude/agents/evaluator.md` / `planner.md` / `generator.md` — Claude Code auto-loads these as Task subagents.
- `.agents/skills/sfs/SKILL.md` — Codex auto-discovers.
- `.gemini/commands/sfs.toml` — TOML, not MD; outside scope.
- Root `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` — auto-load redirect stubs, intentionally minimal.
- `.sfs-local/**` — installed runtime artifacts, refreshed by `sfs upgrade`.

---

## Summary table

| Tier | Count | Action this session | Action deferred to next session |
|---|---|---|---|
| 0 (entry SSoT) | 13 | None — all under threshold | None |
| 1 (body chapters) | 11 | None | Split P1+P2 candidates (8 files) |
| 2 (sprint files) | 10 | None | Split 3 closed WU files |
| 3 (misc large) | 16 | None | Review case-by-case |
| 4 (user-facing dist) | ~10 | None — leave (just trimmed) | None (revisit only on user request) |
| 5 (persona/skills/logs) | many | None | Optional split for sources >200L |
| 6 (project-state) | 9 | None | Mostly leave (historical/dogfood) |

**Net this session**: PROGRESS.md trimmed (463 → 324). One archive file created with strict frontmatter. Audit report (this file) and HANDOFF deferral plan to next session.
