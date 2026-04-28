---
doc_id: wu-27-sfs-loop-flow
title: "WU-27 sub-task 2 — /sfs loop flow spec (§2 Ralph 비교 + §3 인자 spec + §4 1-iter pseudo-flow + §5 종료 조건 / Exit codes)"
visibility: business-only
parent_wu: WU-27
parent_file: 2026-04-19-sfs-v0.4/sprints/WU-27.md
sub_task: 2
opened_at: 2026-04-28T22:50:00+09:00
session_opened: admiring-zealous-newton
spec_source: 2026-04-19-sfs-v0.4/tmp/sfs-loop-design.md (v0.3 §2~§5 verbatim mapping + Solon-wide executor convention `--executor` cross-reference to main §3.1)
---

# WU-27 sub-task 2 — /sfs loop flow spec

> main `sprints/WU-27.md §∗` 분할 plan 정합. 본 file = §2 (Ralph 비교) + §3 (인자 spec, §3.1 Solon-wide executor convention 은 main 참조) + §4 (1-iter pseudo-flow) + §5 (종료 조건 / Exit codes).

---

## §2. Ralph Loop vs /sfs loop 차별

| 축 | Ralph Loop (raw) | /sfs loop (Solon-aware) |
|---|---|---|
| 종료 조건 | 사용자 SIGINT | 도메인 전부 closed / max-iters / TTL exhausted / safety_lock trip / human-required escalation |
| 상태 SSoT | 파일시스템 (PROMPT.md) | `PROGRESS.md` frontmatter (domain_locks · resume_hint · scheduled_task_log) |
| 병렬 안전 | 없음 (single loop 가정) | mutex (current_wu_owner + domain_locks + prefer_mode + sub-mutex per domain) |
| Drift 방어 | 없음 | `resume-session-check.sh` (90분 threshold + sched_log_drift exit 16) + heartbeat |
| 사용자 검토 | post-hoc only | escalation marker (⚠️) + W10 TODO 자동 이관 (CLAUDE.md §1.7) |
| Commit 권한 | `--dangerously-skip` + auto commit | §1.5' = file 편집만, host `.git` mutate 0, commit/push 사용자 manual + §1.18 Copy-paste form |
| 가드레일 | 사실상 0 | 원칙 2 (self-validation-forbidden) + safety_locks list (configurable per loop run) |
| 인수인계 | 없음 (loop 단방향) | helper `append-scheduled-task-log.sh` (N=20 rolling tail) + PROGRESS heartbeat 매 iter |
| Multi-vendor | `claude` 단독 hardcoded | **Solon-wide executor convention** (`--executor` global flag, named profile claude/gemini/codex + custom string passthrough — main `sprints/WU-27.md §3.1`) |

**핵심 차별**: Ralph Loop = "에이전트한테 자율 위임하면 됨" 의 brutalist 표현. `/sfs loop` = "자율 위임하되, 다른 동시 진행 에이전트 / 사람 / cron 과 충돌 0 + 사용자 의미결정 영역 escalate + 매 iter 인수인계 가능 + 어떤 vendor LLM 으로도 실행 가능한 형태로 보존."

---

## §3. 명령 인자 spec

### §3.0 인자 시그니처

```
/sfs loop [--mode <user-active|scheduled|user-active-deferred>]
          [--executor <profile|cmd>]                    # main §3.1 Solon-wide convention
          [--domain-filter <D-X,D-Y,...>] [--priority-min <N>] [--priority-max <N>]
          [--max-iters <N>] [--max-wall-min <N>]
          [--ttl-min <N>]
          [--micro-steps-per-iter <N>]
          [--release-between | --exclusive]
          [--dry-run]
          [--escalate-on <safety-lock-id,...>]
          [--owner <codename>]
          [--report-format <text|json|status-line>]
          # ── multi-worker (3차 발화 반영, sub-task 5 spec) ─────────────
          [--parallel <N>]
          [--worker-id <X> | --auto-codename]
          [--coord-only]
          [--worker-prefer-mode <X>]
          [--worker-domain-pin <D-X>]
          [--isolation <process|claude-instance|sub-session>]
          [--no-mental-coupling]   # default true (sub-task 5 invariant)
```

### §3.1 (참조) Solon-wide executor convention

**main `sprints/WU-27.md §3.1` 참조** — `--executor` global flag + `SFS_EXECUTOR` env + `sfs-common.sh::resolve_executor()` shared helper + named profile registry (claude/gemini/codex) + custom string passthrough. 본 file 에서는 inflation table (§3.2) 의 1 row + §4.1 LLM 호출 site 의 적용 사례로만 참조.

### §3.2 핵심 인자 의미 (inflation table)

| 인자 | default | 의미 |
|---|---|---|
| `--mode` | `user-active-deferred` | resume_hint default_action 의 mode 값. user-active = 모든 prefer_mode claim / scheduled = `prefer_mode: scheduled` 만 / user-active-deferred = scheduled 권한 + 사용자 자리비움 trace |
| `--executor` | `claude` (env `SFS_EXECUTOR` 우선) | Solon-wide convention (main §3.1). named profile or custom cmd string |
| `--domain-filter` | (모든 도메인) | `D-A,D-G` 쉼표 분리 |
| `--priority-min` / `--priority-max` | 1 / 10 | priority 범위 |
| `--max-iters` | 5 | 최대 iter 수 (Ralph Loop 의 `while :;` 무한 cap) |
| `--max-wall-min` | 30 | 총 wall-clock 시간 cap (다중 iter 누적) |
| `--ttl-min` | 30 | per-iter mutex TTL (CLAUDE.md §1.12 정합) |
| `--micro-steps-per-iter` | 1 | 1 iter 당 micro-step 수 (resume_hint step 6 매개변수화) |
| `--release-between` | true | 매 iter 끝에 owner null release (다른 세션 / cron 양보) |
| `--exclusive` | false | owner lock 유지 (TTL 동안 독점, `--release-between` 무효) |
| `--dry-run` | false | claim 안 하고 plan 만 stdout |
| `--escalate-on` | (default safety_locks 전부) | 특정 lock 위반 시 즉시 loop 중단 + ⚠️ |
| `--owner` | self codename | mutex owner 표시 (basename of `/sessions/<x>/`) |
| `--report-format` | `text` | iter 별 보고 형식 (`status-line` = solon-status-report.md spec 정합) |
| `--parallel <N>` | 1 | N worker 병렬 spawn (sub-task 5 detail) |
| `--worker-id <X>` | auto-codename | worker 별 mutex owner 식별 |
| `--auto-codename` | true (`--parallel >1` 시) | adjective-adjective-surname 자동 생성 |
| `--coord-only` | false | coordinator 만 (worker N spawn + wait + aggregate) |
| `--worker-prefer-mode <X>` | --mode 그대로 | worker 별 prefer_mode override |
| `--worker-domain-pin <D-X>` | (none) | 특정 worker 가 특정 도메인만 (mental coupling 위험, ⚠️ escalate, sub-task 5 §6.0) |
| `--isolation` | `process` | `process` (subshell) / `claude-instance` (후속 WU) / `sub-session` (별도 mount) |
| `--no-mental-coupling` | true | sub-task 5 §6.0 invariant 강제. 위반 시 ⚠️ + W10 TODO |

### §3.3 Sub-command (확장 후보)

- `/sfs loop status` — 진행 중 loop 의 iter / claimed 도메인 / TTL 잔여 status-line 1줄
- `/sfs loop stop` — 즉시 중단 + owner release + 종료 보고
- `/sfs loop replay <task-log-id>` — 과거 scheduled_task_log entry 재현 (debug)

---

## §4. 1 iter pseudo-flow (resume_hint default_action step 1~11 캡슐화)

```
loop iter N:
  ┌─ pre-flight (멱등) ─────────────────────────────────────────────────┐
  │ 1. CLAUDE.md SSoT Read (§1 18규율 + §1.5' + §1.12 + §1.14 + §1.18) │
  │ 2. PROGRESS.md frontmatter Read (domain_locks + current_wu_owner +  │
  │    resume_hint + scheduled_task_log)                                 │
  │ 3. scripts/resume-session-check.sh                                   │
  │    └─ exit 0 → 진행 / exit 16 = drift → drift report only + 종료    │
  └──────────────────────────────────────────────────────────────────────┘
  ┌─ mutex / claim ─────────────────────────────────────────────────────┐
  │ 4. §1.12 + domain_locks 통합 mutex check                             │
  │    - current_wu_owner=null → 자유 진행                              │
  │    - != null + 다른 codename + TTL 미만 + mode=user-active → STOP   │
  │    - TTL 초과 stale → mode 확인 후 자동 takeover                     │
  │ 5. domain_locks scan → highest-priority unowned 도메인 claim         │
  │    매칭 도메인 0 → 종료 (exit = "all-domains-closed-or-locked")     │
  └──────────────────────────────────────────────────────────────────────┘
  ┌─ execute (--micro-steps-per-iter 회 반복) ──────────────────────────┐
  │ 6. WU spec §5 의 next 1 micro-step 진행 (file 편집만, §1.5' 정합)   │
  │    - 산출물 신설 / 수정 + bash -n / smoke / verify                  │
  │    - safety_lock 위반 검사 → ⚠️ + W10 TODO + iter 중단 + escalate │
  │    - LLM 호출 시 = §4.1 site (Solon-wide executor convention 적용)  │
  └──────────────────────────────────────────────────────────────────────┘
  ┌─ persist / heartbeat ───────────────────────────────────────────────┐
  │ 7. PROGRESS heartbeat                                                │
  │    - frontmatter `last_overwrite` 갱신                               │
  │    - domain_locks.<X>.next_step / last_step_done block 갱신          │
  │      (step / by / at / files / claim_note / verification /          │
  │       ssot_note / cross_dep_note / prior_step_history 9 fields)     │
  │ 8. 본문 ② In-Progress + ③ Next 1줄 갱신                             │
  │ 9. scheduled_task_log entry append (helper                           │
  │    scripts/append-scheduled-task-log.sh, N=20 rolling)               │
  │ 10. WU 전환 발생 시 Solon Status Report (code fence,                 │
  │     solon-status-report.md v0.6.3 spec)                              │
  └──────────────────────────────────────────────────────────────────────┘
  ┌─ release / iter 종료 ───────────────────────────────────────────────┐
  │ 11. --release-between → owner=null + last_step / forward_idx /      │
  │     reverse_idx 갱신 / --exclusive → owner 유지                     │
  │ 12. iter check                                                       │
  │     - max-iters 초과 → 종료 (exit = "max-iters-reached")            │
  │     - max-wall-min 초과 → 종료 (exit = "max-wall-reached")          │
  │     - 모든 도메인 closed → 종료 (exit = "all-domains-closed")       │
  │     - safety_lock trip → 종료 (exit = "safety-lock-tripped")        │
  │     - else → continue (iter N+1)                                     │
  └──────────────────────────────────────────────────────────────────────┘
```

### §4.1 LLM 호출 site (Solon-wide executor convention 적용 첫 사례)

step 6 의 micro-step 안 LLM 호출이 필요하면:

```sh
# main §3.1 의 resolve_executor() shared helper 사용
EXECUTOR_CMD=$(resolve_executor "$EXECUTOR")   # CLI > env > "claude" fallback
cat PROMPT.md | eval "$EXECUTOR_CMD"
```

→ `--executor claude` (default) / `--executor gemini` / `--executor codex` / `--executor "<custom>"` 모두 동일 호출 site. 본 site = Ralph Loop 의 `cat PROMPT.md | claude -p --dangerously-skip-permissions` 의 vendor-neutral 일반화.

---

## §5. 종료 조건 / Exit codes

| Exit | 의미 | 사용자 액션 |
|:-:|---|---|
| 0 | 정상 종료 (max-iters or all-domains-closed or max-wall) | 누적 산출물 검토 + manual commit + push (§1.5' / §1.18 Copy-paste form) |
| 1 | invalid usage (인자 검증 실패) | 인자 재확인 |
| 2 | PROGRESS.md frontmatter 파싱 실패 | YAML 무결성 점검 |
| 3 | resume-session-check exit 16 (drift detected) | mac cron daemon 점검 (`launchctl list \| grep solon` / `crontab -l`) |
| 4 | mutex claim 실패 (다른 active owner + TTL 미만) | 다른 세션 종료 후 재시도 or `--takeover-stale` |
| 5 | safety_lock trip (escalate 발생) | ⚠️ marker / W10 TODO append 검토 후 사용자 결정 |
| 6 | 도메인 spec 파일 (sprints/WU-*.md) 누락 / 손상 | spec 복구 후 재시도 |
| 7 | 산출물 verify 실패 (bash -n / smoke / yaml.safe_load 등) | 산출물 검토 + 회복 후 재시도 |
| 8 | PROGRESS heartbeat 쓰기 실패 (FUSE lock 등) | FUSE bypass (CLAUDE.md §1.6) 적용 후 재시도 |
| 9 | executor resolve 실패 (`--executor` invalid + `SFS_EXECUTOR` env 도 invalid) | profile 명 / cmd path 재확인 (main §3.1 named profile registry 참조) |
| 99 | unknown internal error | bug report |

---

## §∗. 다음 sub-task

- **sub-task 3** = `sprints/WU-27/sfs-loop-locking.md` (~120-150L) — §6.5 Optimistic Locking + Status FSM (PROGRESS / COMPLETE / FAIL / ABANDONED 4-state, version + retry_count cap=3, Spring JPA `@Version` conceptual borrowing)
- sub-task 4 = `sfs-loop-review-gate.md` (~120-150L) — §6.6 Pre-execution Review Gate (PLANNER + EVALUATOR persona invocation, CLAUDE.md §1.15 정합)
- sub-task 5 = `sfs-loop-multi-worker.md` (~100-120L) — §6.0 Worker Independence Invariant + §6.4 Multi-worker spawn / aggregation (`--parallel` / `--isolation` / mental coupling 진단)
- sub-task 6 (구현) = sfs-loop.sh ~500-650L + sfs-loop-coord.sh + sfs-common.sh::resolve_executor() helper + sfs.md adapter +1 row "loop"
