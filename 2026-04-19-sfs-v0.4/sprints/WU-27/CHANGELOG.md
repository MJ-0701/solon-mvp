---
doc_id: wu-27-changelog
title: "WU-27 spec version_history (결정 #4 '날짜/버전/skill 분리' 직접 적용)"
visibility: business-only
parent_wu: WU-27
parent_file: 2026-04-19-sfs-v0.4/sprints/WU-27.md
---

# WU-27 spec — version history

> 결정 #4 (24th-52 brave-gracious-mayer continuation 5, "md ≤200L + 날짜/버전/skill 분리 + skill vendor-neutral") 직접 적용. main `sprints/WU-27.md` 의 frontmatter `version_pointer` 가 본 file 의 latest entry 를 참조.

## v0.1 — 2026-04-28T22:00+09:00 (admiring-zealous-newton, 25번째 사이클 sub-task 1 entry)

- main `sprints/WU-27.md` 신설 (~150L) — frontmatter + §0 + §1.1~1.3 + §3.1 (Solon-wide executor convention) + 분할 plan.
- 본 `sprints/WU-27/CHANGELOG.md` 신설 (~10L) — version_history 분리, 결정 #4 직접 적용.
- 부수 갱신: `sprints/WU-22.md` / `WU-23.md` / `WU-26.md` 3 곳 stale reference sed (events.jsonl schema → WU-28+ 재배정) + `cross-ref-audit.md §4` W-20 TODO append + `PROGRESS.md` frontmatter `domain_locks.D-I-WU-27` 신설 + ②/③ 1줄 갱신.
- Spec source = `tmp/sfs-loop-design.md` v0.3 (raw-internal, 639L). 본 WU 가 business-only 격상 + 분할 이관.
- decision_points 5건 (WU27-D1~D5) 명시 — Solon-wide executor convention + CLAUDE.md §15 등재 시점 + spec 분할 plan + version_history 분리 + WU-27 referent 확정.
- review gate (CLAUDE.md §1.15) self-application 첫 사례 통과 — PLANNER PASS-with-cond + EVALUATOR PASS-with-cond + 사용자 final approval.

## v0.2~ (예약, sub-task 2~6 진행 시 entry 추가)

- v0.2: sub-task 2 (sfs-loop-flow.md 신설) 진행 시 append.
- v0.3: sub-task 3 (sfs-loop-locking.md) ; v0.4: sub-task 4 (review-gate) ; v0.5: sub-task 5 (multi-worker) ; v1.0: sub-task 6 (실 bash 구현 완료, 0.5.0-mvp release cut 후보).
