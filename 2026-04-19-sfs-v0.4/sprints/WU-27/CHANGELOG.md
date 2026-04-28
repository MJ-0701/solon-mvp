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

## v0.2 — 2026-04-28T22:50+09:00 (admiring-zealous-newton, 25번째 사이클 sub-task 2 entry, 사용자 'push 완료 이어서 ㄱㄱ')

- `sprints/WU-27/sfs-loop-flow.md` 신설 (~190L) — §2 Ralph 비교 + §3 인자 spec (§3.0 시그니처 + §3.1 main 참조 + §3.2 inflation table + §3.3 sub-command) + §4 1-iter pseudo-flow (12 step) + §4.1 LLM 호출 site (Solon-wide executor convention 적용 첫 사례) + §5 Exit codes 11종 (Exit 9 신규 = executor resolve 실패).
- spec source = `tmp/sfs-loop-design.md` v0.3 §2~§5 verbatim mapping + main §3.1 cross-reference.
- Solon-wide executor convention 본 file 에서 첫 적용 demo: §3.0 시그니처 `--executor` 인자 + §3.2 table 1 row + §4.1 호출 site (`EXECUTOR_CMD=$(resolve_executor "$EXECUTOR"); cat PROMPT.md | eval "$EXECUTOR_CMD"`) + §5 Exit 9 종속.
- review gate light pass — sub-task 1 framework 이미 승인 (decision_points WU27-D1~D5), 본 sub-task 2 = mechanical translation (decision_points 신설 0).

## v0.3 — 2026-04-28T23:25+09:00 (admiring-zealous-newton, 25번째 사이클 sub-task 3 entry, 사용자 'γ 관망 + 다음작업 이어서 ㄱㄱ')

- `sprints/WU-27/sfs-loop-locking.md` 신설 (~140L) — §6.5 Optimistic Locking + Status FSM 4-state (PROGRESS / COMPLETE / FAIL / ABANDONED) + version + retry_count cap=3 + crash recovery sequence + idempotency 요구사항 + bash 함수 spec 7건.
- spec source = `tmp/sfs-loop-design.md` v0.3 §6.5 verbatim mapping + CLAUDE.md §1.16 SSoT 정합 (24th-52 사용자 결정 verbatim 보존).
- §6.5.1 사용자 발화 2건 (Spring JPA conceptual borrowing 명시) + §6.5.2 4-state FSM ASCII diagram + §6.5.3 yaml schema 5 신규 필드 (status / version / retry_count / failed_at / fail_reason) + §6.5.4 transition trigger 7 row table + §6.5.5 crash recovery bash pseudo-code + §6.5.6 idempotency 요구사항 (4 case) + §6.5.7 bash 함수 spec 7건 (claim_lock / release_lock / detect_stale / mark_fail / mark_abandoned / auto_restart / escalate_w10_todo) + §6.5.8 CLAUDE.md §1.16 SSoT 정합 + agents/CLAUDE.md "Max 3 rework iterations" invariant 매핑.
- review gate light pass — sub-task 1 framework 그대로 적용 (mechanical translation).
- 부수: `cross-ref-audit.md §4 W-21 TODO append` (Claude Managed Agents Memory γ 관망 + 1-2 사이클 비교 검증 결정 history 보존).

## v0.4 — 2026-04-29T00:05+09:00 (admiring-zealous-newton, 25번째 사이클 sub-task 4 entry, 사용자 '순차 진행 + sub-task 6 자율 위임 plan')

- `sprints/WU-27/sfs-loop-review-gate.md` 신설 (~165L) — §6.6 Pre-execution Review Gate (PLANNER CEO + EVALUATOR CPO 두 페르소나 review 의무 + cascade depth cap=3 + dogfooding 사례 4건 누적) + CLAUDE.md §1.15 SSoT 정합.
- §6.6.1 사용자 발화 2건 (자율진행 큰 작업 위주 + cascade) + §6.6.2 review gate flow ASCII + §6.6.3 "큰 작업" 5 criteria + §6.6.4 호출 spec 5 step + §6.6.5 PASS-with-conditions 3 case + §6.6.6 cascade 4 option (abandon/split/prereq/custom) + depth cap=3 + §6.6.7 dogfooding 4건 (24th-52 + 25th-1 × 3) + §6.6.8 bash 함수 spec 4건 (review_with_persona / submit_to_user / cascade_on_fail / is_big_task) + §6.6.9 CLAUDE.md §1.15 verbatim 정합.
- spec source = `tmp/sfs-loop-design.md` v0.3 §6.6 verbatim mapping + CLAUDE.md §1.15 SSoT 정합.
- review gate light pass — sub-task 1 framework 그대로 적용 (mechanical translation, decision_points 신설 0).
- **자율 진행 프로토콜 사전 합의 (사용자 발화 25th-1 continuation 4)**: sub-task 6 entry 시 사용자 sleep + AI 자율 위임 (~7시간), §1.15 review gate self-approve (mechanical micro-step 6.1~6.8 분할), §1.5' commit 0건 (file 편집만), §1.16 status FSM 자동 적용.

## v0.5 — 2026-04-29T00:30+09:00 (admiring-zealous-newton, 25번째 사이클 sub-task 5 entry, 사용자 'push 완료 + commit 권한 위임 OK')

- `sprints/WU-27/sfs-loop-multi-worker.md` 신설 (~155L) — §6.0 Worker Independence Invariant (사용자 2/3차 발화 verbatim) + §6.0.1~4 (worker 가 보는 것/못 보는 것 + 반-패턴 6 진단 신호 + 정당 fact 경계 + 운영 의미) + §6.1 충돌 케이스 5-row matrix + §6.2 prefer_mode 4 분리 정책 (scheduled/user-active-only/closed/deferred) + §6.3 충돌 가능 파일 처리 last-writer-wins + §6.4 Coordinator-worker 모델 (`--parallel` + `--isolation` 3 종 + aggregation rule + 24th 자연 prototype 사례 + failure mode 3건).
- spec source = `tmp/sfs-loop-design.md` v0.3 §6.0~§6.4 verbatim mapping.
- review gate light pass — sub-task 1 framework 그대로 적용 (mechanical translation, decision_points 신설 0).
- §∗ 다음 sub-task = **WU-27 frontmatter close** (~5분 small) → 사용자 commit + push 일괄 batch (sub-task 1+2+3+4+5+close 6-batch) → **sub-task 6 entry = 사용자 sleep 시작 + AI ~7시간 자율 구현** (user-active-deferred mode + commit 권한 위임 OK + push 금지). sub-task 6 micro-step 분할 6.1~6.8 명시.
- **commit 권한 위임 명시 (사용자 25th-1 continuation 5 발화 verbatim "자동진행하는동안 commit까지는 자동화 해도 됨")**: §1.5' 일시 완화 = sub-task 6 autonomous mode 한정. push 는 §1.5 절대 보존.

## v0.6~ (예약, WU-27 close + sub-task 6 진행 시 entry 추가)

- v0.6: WU-27 frontmatter close + sprints/_INDEX 이동
- v1.0: sub-task 6 (실 bash 구현 완료, 0.5.0-mvp release cut 후보)
