---
phase: do
sprint_id: "solon-loop-queue-mvp"
goal: "Solon loop queue MVP: file-backed queue for /sfs loop"
created_at: "2026-04-30T23:18:27+09:00"
---

# Log — <sprint title>

> Sprint **Do** 단계 작업 로그. 시간순 append 형식. 각 entry 는 1줄 요약 + 필요 시 details.
> `.sfs-local/events.jsonl` 이 machine-readable trace, 본 파일은 human-readable 보강.
> 새 entry 는 본 §1 의 **위쪽** 에 append 권장 (최신 우선).

---

## §1. 작업 로그 (시간순 append)

```
### YYYY-MM-DDTHH:MM:SS+09:00 — <요약>

- 무엇을 했는가
- 왜 했는가 / 어떤 결정에 의한 것인가
- 결과 / 관찰 / 다음 액션
```

<!-- 첫 entry 예시 (삭제 후 실 entry 로 교체) -->

### 2026-05-01T09:15:03+09:00 — Step 2 + Step 3 완료: events backfill (β manual-repair) + manual close

- 사용자 결정: 옵션β 자율진행 승인 (timestamp=현재 / by=manual-repair / note="backfill: adapter emit gap (F-4b)").
- **Step 2 완료**: `.sfs-local/events.jsonl` 에 4 entry append, 모두 `by:"manual-repair"` + note 명시 (pretend-normal 금지 정합):
  - `09:15:00 review_open` (G4) — backfill, semantic ts ≈ CPO G4 review 02:30 KST 작업분.
  - `09:15:01 retro_open` — backfill, semantic ts ≈ retro draft 09:10 KST 작업분.
  - `09:15:02 gate_review` (G5 verdict=pass) — manual emit (F-4b 어댑터 미동작 정합).
  - `09:15:03 sprint_close` — manual emit, 본 sprint close action.
  - JSON validity python `json.loads` × 4 PASS.
- **Step 3 완료**: manual close path 채택 (`sfs retro --close` 의 auto-commit 이 원본 queue task spec "Do not git add/commit/push" + CLAUDE.md §1.5 위배 → manual close 가 deterministic safe path).
  - retro.md frontmatter `closed_at = 2026-05-01T09:15:03+09:00` (sprint_close event ts 와 동일).
  - retro.md §5 G5 close 체크: 4 항목 중 2 항목 [x] (events.jsonl + closed_at), 2 항목 [ ] 사용자 manual 영역 (HANDOFF link + 분기 sprint 등재).
- 사용자 manual 잔여 (wake 시 처리):
  - HANDOFF-next-session.md / sessions/_INDEX.md 에 본 sprint 결과 link 1줄.
  - 분기 sprint 4건 (`solon-loop-queue-lifecycle` / `solon-events-emit-restore` / `solon-adapter-dispatch-audit` / `solon-loop-queue-multi-worker-smoke`) 의 backlog 등재 결정.
  - host repo `0b43423` 위에 dirty worktree (~25 file) git commit + push (CLAUDE.md §1.5 / §1.18 형식).
- git 조작 0 — events.jsonl + retro.md + log.md 모두 file 편집만.

### 2026-05-01T09:10:00+09:00 — Step 1 완료: retro.md G5 draft (KPT + PDCA + 메트릭 + 분기 + close 체크)

- 사용자 지시 "1,2,3 순서대로 진행해" 의 Step 1 = retro.md draft 작성. 사용자 결정 영역 (Step 2 backfill 정책) 진입 전에 멈출 수 있도록 retro.md 안에 결정 대기 항목을 ⚠️ 마커로 명시.
- KPT: Keep 5건 (AC 6/6 + active/dist sync + CTO/CPO 분리 + queue base 확장성 + mid-review docs auto-mitigation), Problem 4건 (F-3 process drift + F-4a adapter dispatch drift + F-4b runtime emit drift + 결정 escalation 누적), Try 5건 (chunky follow-up 별도 sprint 분기 / dispatch audit / events emit restore / multi-worker contention smoke / mid-review pattern 패턴화).
- PDCA: Plan vs Actual scope 7배 차이 분석 (queue MVP → Queue Bundle 흡수), Do learning patterns 후보 2건 (P-mid-review-doc-mitigation, P-codex-cross-check-runtime-drift), Check verdict pass + retro 시점 추가 surface, Act = CLAUDE.md 룰 추가 검토 + 다음 cycle backlog 등재.
- 정량 메트릭: 시간 estimate 1~2h vs actual 9.6h (overnight 자율주행 포함), AC 6/6 PASS, files touched ~25, ahead 변화 0 (dirty worktree, §1.5 정합), 5-Axis 22/25=88%.
- 분기 sprint 가칭 4건: solon-loop-queue-lifecycle / solon-events-emit-restore / solon-adapter-dispatch-audit / solon-loop-queue-multi-worker-smoke.
- §5 G5 close 체크: `events.jsonl 마지막 entry = gate_review G5:pass` + `closed_at frontmatter` + `HANDOFF/sessions log link` + `분기 sprint backlog 등재` 4 항목 모두 unchecked. **선결 = §4 결정 대기 (F-4b backfill 정책)**.
- ⚠️ 본 entry 도 events.jsonl emit 안 됨 (F-4b self-evidence 누적).
- git 조작 0. retro.md 1 file 편집만. 다음: Step 2 (F-4b backfill 결정 briefing) → 사용자 결정 대기 → Step 3 (close 판단) 진입.

### 2026-05-01T08:55:00+09:00 — codex cross-check addendum (review.md §2.9 + F-4a/F-4b)

- 본 sprint 의 G4 review (verdict: pass) 가 durable 함을 codex 가 cross-check 로 확인. 단 sprint state 의 두 추가 fact surface:
  - F-4a (Adapter drift): `sfs log` 가 `bin/sfs` dispatch table 에 없음 (status/start/guide/auth/brainstorm/plan/review/decision/retro/loop 만). docs vs adapter surface gap.
  - F-4b (Runtime drift): `.sfs-local/events.jsonl` 이 마지막 `plan_open` 이후 갱신 안 됨. 본 sprint 의 queue 구현 / review / lifecycle / sizing 등 어디서도 `review_open`/`retro_open`/`sprint_close` event 가 emit 되지 않음. README/GUIDE 가 약속한 event timeline 과 실 동작 mismatch.
- 본 G4 review verdict (pass) 에는 영향 없음 (queue MVP code 영역 vs adapter/runtime 영역 분리). review.md 에 §2.9 추가 + F-4a/F-4b 잔여 권고로 등재. retro 안건 (D4/Drift 또는 KPT/P).
- ⚠️ `sfs retro --close` 자동 진행 금지 — F-4b 의 events backfill 정책 + retro.md refine 이 사용자 손에서 끝날 때까지. 현재 events.jsonl 상태로 close path 가 exit 8 risk. backfill 시 entry tag "repair/backfill" 명시 필수, 정상 adapter log 으로 가장 금지.
- 본 entry 자체도 events.jsonl emit 안 됨 (adapter 가 그 경로를 갖고 있지 않음, F-4b 의 self-evidence).
- git 조작 0 (queue task spec + CLAUDE.md §1.5/§1.5' 정합).

### 2026-05-01T08:34:45+09:00 — cross-runtime wording strengthened

- 사용자 판단 반영: runtime 분리는 "서로 못 보게 함" 이 아니라 "서로 확인하되 남의 작업 범위를 건드리지 않음" 으로 명확화.
- `RUNTIME-ABSTRACTION.md §6.5` 에 Cross-runtime visibility / write ownership invariant 추가. shared filesystem evidence cross-check 는 허용/권장, write ownership 은 claim/task/files_scope/review/log append 로 제한.
- moving target 규칙 강화: review 중 다른 runtime 변경이 발생하면 시작 시점 evidence 와 post-state 를 분리 기록하고, verdict 영향 여부를 명시.
- git 조작 0. 문서 표현 강화 + 본 log append 만 수행.

### 2026-05-01T08:18:06+09:00 — Final verification pass (review.md consistency + no git ops)

- `review.md` 를 end-to-end 재확인했다. §2.1 AC1~AC6 PASS, §2.6 5-Axis 22/25=88%, §3 verdict pass, §6 invocation log 가 서로 모순 없이 정합.
- §2.7 의 mid-review codex 진행분은 out-of-scope 정보 관찰로 분리되어 있고, §2.8 / §3 에서 F-1·F-2 는 RESOLVED, F-3 만 info-only 로 유지되어 verdict 와 충돌하지 않음.
- 기존 `log.md` 02:30 entry 와도 정합: active/dist `sfs-loop.sh` byte-identical ×2 시점, `bash -n` 양쪽 PASS, sandbox enqueue/queue/claim + quoted title escaping PASS, 회귀 0.
- git 조작 0. 본 final pass 도 파일 append 만 수행했고, CPO review invocation log 역시 `no git operations performed` 로 기록됨. host repo commit/push 는 사용자 manual 영역으로 유지.

### 2026-05-01T02:30:00+09:00 — CPO G4 review 실행 (verdict: pass)

- queue task `loopq-20260430T165820Z-8266-claude-cpo-review-queue-mvp-and-docs.md` (claimed by `claude-overnight`) 를 single-task 자율 실행으로 처리. evaluator_executor=claude, generator_executor=codex (self-validation 방지 정합).
- scope = plan.md AC1~AC6 (queue MVP) + active/dist parity + product/wording/handoff risk. lifecycle/verify/sizing/depends-on/files-scope 등은 plan.md §3 Out of scope 이므로 본 review 의 verdict 입력에서 제외하고 §2.7 정보-only 관찰로 분리.
- AC1~AC6 6개 전부 CPO 측 독립 재검증 PASS — `find` 로 5 dir scaffold 확인, sandbox `cp -a .sfs-local /tmp/...` 후 enqueue (quoted title escaping 포함) / queue / claim 재현 PASS, AC5 dry-run 은 code path inspection (`_pick_queue_task` → `_pick_domain` 순서) + 기존 sandbox 증거 재확인. active vs dist `cmp -s` IDENTICAL (985L 시점 + 이후 1207L 시점 모두), bash -n 양쪽 PASS, drift 0. 회귀 0.
- 5-Axis CPO 평균 22/25 = 88%, **verdict: pass**.
- 식별한 doc 권고 F-1 / F-2 는 review 진행 중 codex 02:21 entry 가 README/GUIDE 갱신하면서 자연 RESOLVED. F-3 (process, lifecycle 작업이 본 sprint log §1 에 inline append 된 관찰) 만 info-only 로 유효 — 향후 chunky follow-up 은 별도 sprint id 로 분리 권고.
- 산출: `review.md` (G4 verdict 매트릭스 + §2.7 mid-review 진행분 관찰 + §2.8 권고 status 재조정 + invocation log).
- git 조작 0 (queue task spec + CLAUDE.md §1.5/§1.5' 정합). 다음: CTO Generator (codex) 최종 확인 → G5 retro 진입.

### 2026-05-01T02:25:45+09:00 — queue dependency and files-scope guard implemented

- queue picker 가 pending task 의 `depends_on` task IDs 를 확인하고, 모든 dependency 가 `done/` 에 있을 때만 claim 대상으로 삼도록 변경했다.
- queue picker 가 다른 owner 의 claimed task `## Files Scope` 와 pending task scope 를 단순 string/prefix overlap 으로 비교해 충돌 후보를 skip 한다.
- `queue` 출력은 기존 count/stale line 에 더해 blocked pending task 를 `blocked · deps ...` 또는 `blocked · files_scope ...` 형식으로 표시한다. destructive takeover/reorder 는 하지 않는다.
- task 에 dependency/files scope 가 없으면 기존처럼 claim 가능하다.
- 검증: active/dist `bash -n` PASS, active/dist `cmp` PASS, sandbox dependency missing → blocked PASS, dependency done → claimable PASS, files-scope overlap with other owner → blocked PASS, no-scope task remains claimable PASS, `git diff --check` PASS.

### 2026-05-01T02:23:45+09:00 — max-attempts and abandoned policy implemented

- `sfs-loop.sh` 에 `abandon <task-id-or-path>` subcommand 를 추가했다.
- `retry` 는 attempts 를 1 증가시킨 뒤 `max_attempts` 를 초과하면 task 를 `pending/` 대신 `abandoned/` 로 이동하고 `abandoned_at` 을 기록한다.
- verification failure 자체는 attempts 를 증가시키지 않는 기존 정책을 유지한다. attempts 증가는 `retry` 의 책임으로 고정했다.
- README / GUIDE / SFS.md.template 에 `abandon` 과 `max_attempts` 초과 시 abandoned 이동 정책을 반영했다.
- 검증: active/dist `bash -n` PASS, active/dist `cmp` PASS, sandbox retry attempts 0→1 pending PASS, 1→2 pending PASS, 2→3 abandoned PASS, manual `abandon` claimed→abandoned PASS, docs `rg` PASS, `git diff --check` PASS.

### 2026-05-01T02:21:00+09:00 — queue sizing/stale policy and docs implemented

- `enqueue` 에 `--size small|medium|large` 와 `--target-minutes N` 옵션을 추가하고, 생성 task frontmatter 에 `size` / `target_minutes` 를 기록한다. 기본값은 `medium` / `45`.
- `queue` 출력은 기존 count line 을 유지하면서, `--ttl-min` 기준보다 오래된 claimed task 를 `stale · age ... · owner ... · task ...` 형식으로 추가 표시한다. 자동 takeover/delete 는 하지 않는다.
- README / GUIDE / SFS.md.template 에 queue = execution backlog / 실행 대기열, sprint scope SSoT = brainstorm/plan/decision file 을 명시했다.
- docs 에 manual lifecycle (`verify`, `complete`, `fail`, `retry`), non-live prompt artifact behavior, `SFS_LOOP_LLM_LIVE=1`, `SFS_LOOP_VERIFY=1`, medium/large overnight sizing 기준을 반영했다.
- 검증: active/dist `bash -n` PASS, active/dist `cmp` PASS, docs `rg` PASS, sandbox `enqueue --size small --target-minutes 5` frontmatter PASS, compat `enqueue` 기본 medium/45 PASS, stale claimed visibility PASS, `git diff --check` PASS.

### 2026-05-01T02:18:30+09:00 — queue verify runner and auto lifecycle implemented

- `sfs-loop.sh` 에 `verify <task-id-or-path>` subcommand 와 `_queue_run_verify` helper 를 추가했다.
- `## Verify` 섹션에서 보수적인 runnable bullet 만 추출한다: backtick command 또는 command-like prefix (`bash`, `cmp`, `test`, `grep`, `find`, `git diff --check`, `./` 등). prose/TBD 는 무시한다.
- verify evidence 는 task run artifact 아래 `verify.commands` / `verify.out` / `verify.err` / `verify.exit` 로 기록된다.
- default `/sfs loop` 는 `SFS_LOOP_VERIFY=1` 일 때 queue task 실행 artifact 생성 후 verify 를 돌리고, pass 면 `done/`, fail 이면 `failed/` 로 이동한다. verify failure 는 attempts 를 증가시키지 않고, `retry` 시점에만 attempts 를 1 증가시킨다. `max_attempts` enforcement 는 후속으로 deferred.
- 검증: active/dist `bash -n` PASS, active/dist `cmp` PASS, sandbox pass task → `done/` PASS, sandbox fail task → `failed/` PASS, `retry` → `pending/` + attempts=1 PASS, manual `loop verify <claimed-task>` → `done/` PASS.

### 2026-05-01T02:14:30+09:00 — queue task execution prompt artifacts implemented

- default `/sfs loop` queue-first branch 가 task claim 후 `.sfs-local/queue/runs/<task-id>/<timestamp>/` 아래 run artifact 를 생성하도록 변경했다.
- 생성 파일: `PROMPT.md` (task body + Files Scope + Verify + no-git guard + metadata), `metadata.env` (task_id/title/path/owner/executor/prompt path).
- `SFS_LOOP_LLM_LIVE=0` 기본 경로는 executor 를 호출하지 않고 prompt artifact 만 만든다. `SFS_LOOP_LLM_LIVE=1` 일 때만 resolved executor 를 호출하고 `executor.out` / `executor.err` / `executor.exit` 를 기록한다.
- active runtime 과 product dist template `sfs-loop.sh` 는 byte-identical sync 유지.
- 검증: active/dist `bash -n` PASS, active/dist `cmp` PASS, isolated sandbox enqueue→default loop non-live→claim + run artifact 생성 PASS, `PROMPT.md` title/Goal/Files Scope/Verify/no-git guard 포함 PASS, non-live executor artifacts 미생성 PASS.

### 2026-05-01T02:11:00+09:00 — autonomous queue backlog resized to chunky work

- 사용자 피드백: `execute that task only` 는 맞지만, queue 에 애초부터 overnight 자율주행용 묵직한 작업이 같이 들어 있어야 했다.
- pending queue 에 large/medium 후속 task 3건 추가: task body execution path, verify runner + auto lifecycle, sizing/stale policy + docs.
- 각 task 는 Files Scope / Verify / no git add·commit·push guard 를 포함해 다음 worker 가 단독 claim 후 진행 가능하게 작성했다.
- 관찰: small leaf task 는 standalone overnight item 이 아니라 큰 queue item 의 micro-step 으로 묶거나 batch 후보로 남겨야 한다.

### 2026-05-01T02:07:00+09:00 — queue lifecycle subcommands implemented

- `sfs-loop.sh` 에 `complete <task-id-or-path>`, `fail <task-id-or-path>`, `retry <task-id-or-path>` 추가.
- active runtime 과 product dist template 을 동일 sync 유지.
- lifecycle 정책: `complete`/`fail` 은 claimed task 만 각각 `done/`·`failed/` 로 이동하고 `completed_at`·`failed_at` 을 기록한다. `retry` 는 failed/abandoned/claimed task 를 `pending/` 으로 되돌리고 `owner`/`claimed_at` 을 비우며 `attempts` 를 1 증가시킨다.
- 검증: active/dist `bash -n` PASS, active/dist `cmp` PASS, sandbox enqueue→claim→complete PASS, enqueue→claim→fail→retry PASS, task-id targeting PASS, done path complete 거부 PASS.
- 다음: claimed queue task body 를 executor prompt 로 넘기는 live execution path + verify runner 는 후속 후보.

### 2026-04-30T23:25:00+09:00 — file-backed loop queue MVP implemented

- `/sfs start` / `/sfs brainstorm` / `/sfs plan` 으로 `solon-loop-queue-mvp` sprint 생성 + G0/G1 계약 작성.
- `sfs-loop.sh` 에 queue MVP 추가: `queue`, `enqueue <title>`, `claim`, default run 의 queue-first pick + domain_locks fallback.
- queue scaffold 추가: `.sfs-local/queue/{pending,claimed,done,failed,abandoned}` 와 product dist template 동일 구조.
- active runtime `.sfs-local/scripts/sfs-loop.sh` 와 product dist template `solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh` 동일 sync 유지.
- README / GUIDE / SFS template 에 queue subcommands 최소 문서화.
- 검증: active/dist `bash -n` PASS, active/dist `cmp` PASS, `git diff --check` PASS, sandbox enqueue/queue/dry-run/claim PASS, quoted title escaping PASS.
- 다음: `complete/fail/retry` subcommands + task body execution prompt + verify runner 는 후속 sprint 후보.

## §2. 발견된 결정 / 블로커 (decision log 후보)

- 결정 갈림길 발견 시 `.sfs-local/decisions/<topic>.md` 로 mini-ADR 분리.
- 차단 요소 (외부 답변 대기, 리소스 부족 등) 는 본 섹션에 기록 후 `review.md` 에서 verdict 로 반영.

## §3. CTO 구현 메모

- **CTO Generator persona**: `.sfs-local/personas/cto-generator.md`
- **구현 executor/tool**: codex
- **변경 파일/모듈**:
  - `.sfs-local/scripts/sfs-loop.sh`
  - `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`
  - `.sfs-local/queue/{pending,claimed,done,failed,abandoned}/.gitkeep`
  - `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/queue/{pending,claimed,done,failed,abandoned}/.gitkeep`
  - `2026-04-19-sfs-v0.4/solon-mvp-dist/README.md`
  - `2026-04-19-sfs-v0.4/solon-mvp-dist/GUIDE.md`
  - `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/SFS.md.template`
- **실행한 테스트/스모크 체크**:
  - `bash -n .sfs-local/scripts/sfs-loop.sh`
  - `bash -n 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`
  - `cmp -s` active/dist `sfs-loop.sh`
  - sandbox: `queue` -> `enqueue 'Queue "quote" smoke task'` -> `queue` -> `--dry-run --max-iters 1 --no-review-gate` -> `claim --owner smoke-owner` -> `queue`
  - claimed task frontmatter checked: `status: claimed`, escaped title, `owner: smoke-owner`, `claimed_at`.
- **CPO 에게 넘길 검증 포인트**:
  - queue 가 scope SSoT 로 오해되지 않도록 docs wording 이 충분한가.
  - default loop 의 queue-first behavior 가 domain_locks fallback 을 깨지 않는가.
  - non-live default run 이 queue task 를 claimed 로 남기는 MVP 정책이 acceptable 한가.

## §4. 다음 단계 / 핸드오프 메모

- 후속 A: `/sfs loop complete <task>` / `fail <task>` / `retry <task>` subcommands.
- 후속 B: claimed queue task body 를 executor prompt 로 넘기는 live execution path.
- 후속 C: task `verify` field runner + failure auto-classification.
- 후속 D: dependency / files_scope collision guard.
