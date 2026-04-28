---
doc_id: wu-27-sfs-loop-multi-worker
title: "WU-27 sub-task 5 — /sfs loop multi-worker spec (§6.0 Worker Independence Invariant + §6.1~§6.4 충돌 회피 + multi-worker spawn / aggregation)"
visibility: business-only
parent_wu: WU-27
parent_file: 2026-04-19-sfs-v0.4/sprints/WU-27.md
sub_task: 5
opened_at: 2026-04-29T00:30:00+09:00
session_opened: admiring-zealous-newton
spec_source: 2026-04-19-sfs-v0.4/tmp/sfs-loop-design.md (v0.3 §6.0~§6.4 verbatim mapping)
---

# WU-27 sub-task 5 — /sfs loop multi-worker spec

> main `sprints/WU-27.md §∗` 분할 plan 정합. 본 file = §6.0 Worker Independence Invariant + §6.1~§6.4 (충돌 케이스 / prefer_mode 분리 / 충돌 가능 파일 / multi-worker spawn). 24th-52 brave-gracious-mayer continuation 5 사용자 2/3차 발화 verbatim 정합.

---

## §6.0 Worker Independence Invariant (핵심)

> **Invariant**: Worker MUST NOT condition its decision on another worker's progress. Each worker SHALL reason as if it is alone in the system, with `domain_locks` mutex providing the only coordination primitive. Time-axis synchronization (`다음 cron 까지 N분 여유` / `scheduled 한테 양보` / `picking up`) is **forbidden**.

**사용자 발화 (2/3차, 24th-52 continuation 5 2026-04-28T20:23+20:30 KST)**:
> "내가 원하는건 완전한 독립이지 지금처럼 바통터치의 느낌이 아닌데 이건 병렬로 작업하는게 아니잖아?" + "/sfs loop 기능도 이런식으로 병렬로 루프 작업을 할 수 있는 기능을 제공해줘"

### §6.0.1 Worker 가 보는 것 / 못 보는 것

**OK to read** (mutex coordination = 정상 입력):
- `domain_locks.<X>.owner` (claim 가능 여부)
- `domain_locks.<X>.priority` / `prefer_mode` / `files_scope` (sweep 결정)
- `domain_locks.<X>.next_step` / `last_step_done.step` (자기 도메인 진행 상태 = step 번호만)
- WU spec `sprints/WU-*.md` (자기 작업 spec)
- `current_wu_owner` (mutex check)

**NOT OK to read** (mental coupling 후보 = invariant 위반):
- `scheduled_task_log` 의 다른 worker entry narrative
- 다른 worker 의 진행 도메인 / row (= "걔는 X 했으니 나는 Y" 사고)
- 다른 worker 의 timing (= "걔 곧 깰 시간이니 빨리/천천히")
- 다른 worker 의 codename (= 자기 결정에 codename 반영)

### §6.0.2 위반 진단 신호 (반-패턴 list)

Worker 의 LLM output 에 다음 표현 등장 시 invariant 위반 의심:
- "scheduled 가 X 했으니 너/나는 Y"
- "다음 cron 까지 N분 여유"
- "scheduled 한테 양보 / picking up / 바통터치"
- "scheduled 가 곧 X 진행할 예정"
- "21:00 cron 까지 ~37분"
- "TTL 안 가능하지만 scheduled 와 중첩 위험"

→ 자동 감지 시 `--no-mental-coupling=true` (default) 가 ⚠️ marker + W10 TODO append (§6.6.6 cascade entry).

### §6.0.3 위반 vs 정당한 fact 의 경계

**정당** (mutex fact 활용):
- "current_wu_owner != self → STOP" (mutex check)
- "D-G priority=2 + prefer_mode=scheduled 매칭 → claim" (sweep 결과)
- "files_scope disjoint 확인 → 진입 OK"

**위반** (다른 worker history reasoning):
- "scheduled 가 row 6 했으니 row 7 = highest priority"
- "scheduled 한테 row 8 양보"

**Rule of thumb**: 자기 결정의 근거가 `domain_locks.<X>` 의 *현재 state* 면 OK, 다른 worker 의 *최근 행동/timeline* 이면 위반.

### §6.0.4 운영 의미

- 두 worker 가 동시에 priority=2 도메인 claim 시도 → mutex last-writer-wins, 후입자 다른 도메인 fallback. **이게 정상.** 사전 분담 = 안티패턴 (단 `--worker-domain-pin` 강제 가능, 그러나 ⚠️ escalate)
- worker 진입 시 PROGRESS *현재 snapshot* 만. 과거 history 학습/조정 = 위반.
- worker reasoning = deterministic (같은 PROGRESS state → 같은 도메인 claim) = testing/replay 가능.

---

## §6.1 충돌 케이스 매트릭스

| 동시 진행 | 충돌 위험 | /sfs loop 의 안전 보장 |
|---|---|---|
| 2 cron 동시 깨어남 (race) | 동일 도메인 claim 시도 | sub-mutex `owner` last-writer-wins (1초 단위), 후입자 fallback |
| cron + user-active 동시 | mode=scheduled vs mode=user-active 동일 도메인 | user-active 우선권 (current_wu_owner 매칭). cron STOP + 사용자 confirm (자동 takeover 금지) |
| 같은 codename 다중 instance | self codename 동시 claim | basename of `/sessions/<x>/` instance 별 unique → 다른 codename = 정상 충돌 처리 |
| 도메인 disjoint (D-G + D-H 등) 동시 | files_scope 거의 겹치지 않음 | 가능. 충돌 가능 4 파일만 last-writer-wins |
| 같은 도메인 안 다른 micro-step | 같은 spec 파일 다른 row | sub-mutex = 도메인 단위 (row 단위 X) → owner = 모든 row 독점 |

---

## §6.2 prefer_mode 분리 정책 (24th-16 strategic shift)

- **scheduled** = 큰 WU (~10-20분 micro-step), spec 결정 영역 0, cron 자율 적합
- **user-active-only** = 작은 WU (~5-10분 정리), cron cycle 낭비 방지
- **closed** = lifecycle 종결 (file 편집 100% + 사용자 manual commit 잔존)
- **deferred (제거 후보)** = 사용자 결정 대기

`/sfs loop --mode <X>` 가 위 분리 enforce → 동일 도메인 두 모드 동시 claim race 사실상 0.

---

## §6.3 충돌 가능 파일 처리 (last-writer-wins)

24th-52 시점 4 파일:
- `sfs-common.sh` (다중 도메인 보강)
- `.claude/commands/sfs.md` (다중 도메인 adapter dispatch)
- `VERSION` / `CHANGELOG.md` (release entry)

Race window 5-10초 micro-step → 손실 가능 데이터 = 5-10초 작업분. PROGRESS scheduled_task_log 가 trace 보존 → 사용자 manual recovery 가능.

**향후 개선** (WU-32+ 후보): hot file 의 함수별 split (e.g. `sfs-common-validate.sh` + `sfs-common-frontmatter.sh`) → race 제거.

---

## §6.4 Multi-worker spawn / aggregation (`--parallel` 정합)

### §6.4.1 Coordinator-worker 모델

```
/sfs loop --parallel 3 --mode user-active-deferred
   │
   ├─ coordinator (호출자, --coord-only 면 작업 0)
   │     ├─ pre-flight (resume-check + CLAUDE.md/PROGRESS Read) 1회
   │     ├─ worker 0 spawn (--worker-id auto-XXX) ────┐
   │     ├─ worker 1 spawn (--worker-id auto-YYY) ────┤  background
   │     ├─ worker 2 spawn (--worker-id auto-ZZZ) ────┤  process
   │     ├─ wait (전체 종료)                           │
   │     └─ aggregate (exit codes + 산출물 list + W10 TODOs)
   │
   ├─ worker 0 (independent) ── pre-flight + sweep + claim D-G + iter loop
   ├─ worker 1 (independent) ── pre-flight + sweep + claim D-H + iter loop
   └─ worker 2 (independent) ── pre-flight + sweep + (claim 0) → 즉시 종료
```

### §6.4.2 Spawn detail (`--isolation process` default)

```bash
for i in $(seq 1 "$PARALLEL"); do
    bash "$SCRIPT_DIR/sfs-loop.sh" \
        --mode "$MODE" \
        --executor "$EXECUTOR" \
        --worker-id "$(generate_codename)" \
        --max-iters "$MAX_ITERS" \
        --max-wall-min "$MAX_WALL" \
        --no-mental-coupling \
        > "/tmp/sfs-loop-worker-$i.log" 2>&1 &
    PIDS+=($!)
done
wait "${PIDS[@]}"
```

**isolation 종류**:
- `process` (default) = bash subshell, 가장 가벼움
- `claude-instance` = 별도 Claude Code conversation spawn (현재 미구현, 후속 WU)
- `sub-session` = `/sessions/<x>/` 별도 mount (가장 무거움, 진짜 독립). 24th 사이클 user-active vs cron run = 사실상 sub-session 사례.

### §6.4.3 Aggregation rule

Coordinator 가 wait 후:
1. exit code 수집 → 모두 0 이면 0, 하나라도 5 (safety-lock) / 7 (verify fail) → 해당 코드 propagate
2. PROGRESS scheduled_task_log 에 **단일 coordinator entry** append (worker entry 는 자체 append)
3. coordinator entry = worker count + 종료 reason summary + 산출물 list 1줄
4. **Coordinator = pure pipe-through** (worker 결과 reasoning 0, §6.0.1 invariant 정합)

### §6.4.4 24th 사이클 자연 적용 사례

24th 사이클 user-active conversation (`brave-gracious-mayer`) + scheduled cron run (`fervent-exciting-carson` 등) = 사실상 `--parallel 2 --isolation sub-session` 모드 (다른 `/sessions/<x>/` mount). 이 운영 = v0.2 spec 의 자연 prototype.

→ `/sfs loop --parallel N` default = `process`, production 운영은 `sub-session` 권장.

### §6.4.5 Failure mode

- **All workers stuck on same domain** → mutex last-writer-wins, 1 명만 성공, 나머지 fallback. fallback 모두 실패 시 즉시 종료 (`no-eligible-domain` exit)
- **Coordinator killed but workers alive** → workers 자기 TTL 안 작업 진행 + release. orphan workers = 자기 종료 후 cleanup (PID file)
- **Worker 가 다른 worker 산출물 발견** (같은 file 동시 편집) → last-writer-wins, §6.3 정합

---

## §∗. 다음 sub-task

- **WU-27 frontmatter close + sprints/_INDEX 이동** (~5분 small step, sub-task 4 → frontmatter close → 사용자 commit + push 일괄 batch) ← **다음 진행 추천**
- **sub-task 6 entry** (실 bash 구현) = 사용자 sleep 시작 trigger 시점 + AI ~7시간 자율 구현 (user-active-deferred + auto-commit 위임 OK + push 금지). micro-step 6.1~6.8 분할:
  - 6.1: sfs-loop.sh skeleton + arg parsing (~60분)
  - 6.2: pre-flight integration (resume-check + CLAUDE/PROGRESS Read) (~45분)
  - 6.3: mutex helpers (sfs-common.sh: claim_lock / release_lock / detect_stale / mark_fail / mark_abandoned / auto_restart / escalate_w10_todo) + resolve_executor (~90분)
  - 6.4: iter loop core (12-step pseudo-flow integration) (~90분)
  - 6.5: multi-worker spawn (--parallel + auto-codename + coord-only) (~60분)
  - 6.6: review-gate helpers (review_with_persona / submit_to_user / cascade_on_fail / is_big_task) (~60분)
  - 6.7: dry-run sandbox smoke (T1~T20+) (~60분)
  - 6.8: edge case + bug fix buffer (~60-120분)
  - 누적 ~7-9시간 → MVP cut point at 6.5 (parallel) or 6.6 (review-gate) 가능
