---
phase: retro
gate_id: G5
sprint_id: "solon-loop-queue-mvp"
goal: "Solon loop queue MVP: file-backed queue for /sfs loop"
created_at: "2026-04-30T23:18:27+09:00"
last_touched_at: "2026-05-01T09:15:03+09:00"
closed_at: "2026-05-01T09:15:03+09:00"   # manual close (option β + manual-repair tag, F-4b adapter emit gap 정합)
---

# Retro — Solon Loop Queue MVP

> Sprint **G5 — Sprint Retro** 산출물. 학습 루프 (정성, N PDCA 집계).
> `/sfs retro --close` 로 본 sprint 의 `closed_at` 을 frontmatter 에 기록 + `.sfs-local/events.jsonl` 의 `sprint_close` event append.
> SSoT: `gates.md §1` (G5) + `05-gate-framework.md §5.1.3` (Sprint Retro).
> ⚠️ 본 retro 직후 close 자동 진행 금지 — `§5. G5 close 체크` 의 F-4b backfill 결정이 사용자 손에서 끝날 때까지.

---

## §1. KPT (Keep / Problem / Try)

### Keep — 잘 된 것 (계속)

- **AC1~AC6 6개 single sprint 안에 닫힘** + CPO 측 독립 재검증 PASS. queue scaffold (5 dir × active+dist), `enqueue/queue/claim` 3 subcommand, queue-first dry-run, bash -n 양쪽 PASS — 모두 review.md §2.1 매트릭스에 evidence 누적.
- **active vs dist byte-identical sync 정합** — 985L 시작 시점 + 1207L mid-review 시점 모두 `cmp -s` IDENTICAL. R-D1 (CLAUDE.md §1.13 dev-first sync) 정합 그대로 유지. drift 0.
- **CTO Generator (codex) ↔ CPO Evaluator (claude) 분리 운영 PASS** — self-validation 방지 정합 (CLAUDE.md §1 hint + 본 sprint plan.md §5). 같은 산출물을 같은 instance 가 통과시키지 않는 원칙 첫 worked example.
- **file-backed queue 설계가 chunky overnight task 흡수까지 잘 확장** — single-mv claim atomicity, awk frontmatter rewrite, python3 fallback parser 등의 base 가 lifecycle/verify/sizing/depends-on/files-scope 까지 +222L 자연 확장. 추후 dependency-graph / retry policy 확장 base 로 학습 가치 있음.
- **Mid-review docs auto-mitigation worked example** — 본 review 가 F-1 (queue=실행대기열 vs scope SSoT cross-ref) + F-2 (default loop claim-leak doc) 를 권고로 등재한 후, codex 02:21 entry 가 같은 review window 안에서 README/GUIDE 갱신 → 두 권고 모두 RESOLVED. CPO finding 이 review 외부 worker 에게 자연 전파되는 process 의 첫 case.

### Problem — 안 된 것 / 막힌 것

- **F-3 (Process drift)**: plan.md §3 Out of scope 였던 chunky follow-up 6 항목 (lifecycle / autonomous backlog resize / run artifacts / verify / sizing / max-attempts+abandoned / depends-on+files-scope) 이 같은 `solon-loop-queue-mvp` sprint dir 의 `log.md §1` 에 inline append 됨. sprint contract 형식 (1 sprint = 1 commit, plan.md §3 In/Out scope 가 sprint scope SSoT) 이탈. 결과적으로 backlog→ship→docs reflect 까지 한 번에 닫힌 R-D1 정합은 좋았으나, 사후 sprint history audit 시 "queue MVP" sprint id 가 실제로는 "Queue Bundle" 이어서 retro 시 명시적 reframe 필요.
- **F-4a (Adapter dispatch drift, codex cross-check)**: `bin/sfs` dispatch table 에 `sfs log` 부재. README/GUIDE 의 11 명령 surface (`status / start / guide / auth / brainstorm / plan / review / decision / retro / loop` + init/update 류) 와 adapter 실 동작 사이에 gap. 사용자가 docs 에서 본 명령이 silent 하게 unknown command + exit 7 로 떨어짐. 본 review.md §2.9 + invocation log 에 evidence.
- **F-4b (Runtime emit drift, codex cross-check)**: `.sfs-local/events.jsonl` 의 마지막 entry 가 `2026-04-30T23:18:43+09:00 plan_open`. 그 이후 본 sprint 의 queue 구현 / lifecycle / verify / sizing / review / 본 retro 작업 어디서도 `review_open` / `retro_open` / `sprint_close` event 가 emit 되지 않음. adapter 가 promise 한 event timeline (review.md template 본문 + GUIDE §1.4 약속) 과 실 동작 mismatch. **본 retro entry 자체도 emit 안 됨 — F-4b 의 self-evidence**.
- **결정 escalation 누적**: F-4b backfill 정책 (do nothing / repair-tag backfill / pretend-normal-금지) 는 사용자 결정 영역 (CLAUDE.md §1.3 self-validation-forbidden). 본 retro 안에서 자동 결정 안 함. §4 결정 대기 항목으로 escalate.

### Try — 다음 sprint 시도

- **chunky follow-up 발견 시 즉시 별도 sprint 분기 trigger** — plan.md §3 "Out of scope" 에 명시된 항목이 새 backlog 로 surface 하면 같은 sprint dir 이 아니라 새 sprint id (예: `solon-loop-queue-lifecycle` / `solon-loop-queue-runtime` / `solon-loop-queue-deps`) 로 분리. retro 시점에 sprint dir history audit 가 명확해짐.
- **adapter dispatch table audit single-task** — README/GUIDE 가 약속한 11 명령 vs `bin/sfs` 실 dispatch 의 1:1 매트릭스 검증. F-4a 같은 surface gap 추가 발견 시 issue 등재. 별도 sprint 또는 single-task queue item 으로.
- **events.jsonl emit site restore sprint** (`solon-events-emit-restore` 가칭) — bash adapter 의 review/retro/decision/start/loop 명령에서 emit_event call 이 누락된 site 찾기. 본 sprint 에서 누락된 event 의 backfill 정책은 별도 결정 (§4 결정 대기). emit site 자체 fix 와 backfill 결정은 별개 step.
- **queue task multi-worker contention smoke** (queue MVP 의 5-Axis 안정성 -1 회수) — sandbox 에서 동시 worker 2~3개로 같은 pending task 를 동시 claim 시도 → 단 하나만 성공하는지 확인. 본 sprint 의 `_claim_queue_task` 는 single-mv atomic 이라 이론적으로 OK 이지만 정량 evidence 누적 필요.
- **Mid-review docs auto-mitigation 패턴화** — 본 sprint 에서 발생한 "CPO finding 등재 → 외부 worker 가 같은 review window 안에서 자연 fix" pattern 을 `learning-logs/2026-05/P-mid-review-doc-mitigation.md` 으로 정형화 (post-fact 관찰 vs 사전 design 구분).

## §2. PDCA 학습

- **Plan**: 의도와 결과 간 차이가 컸던 항목.
  - 본 sprint 의 plan.md §3 In scope 는 **queue MVP (5 helper + 3 subcommand + queue-first pick)** 였으나, 실제 결과는 **Queue Bundle (lifecycle + run artifacts + verify + sizing + max-attempts + depends-on + files-scope)** 7배 size. 이는 plan 의도와 결과가 일치 안 한 게 아니라, plan §3 Out of scope 가 chunky overnight backlog 로 변환되어 같은 sprint window 안에 흡수된 것. 다음 sprint kickoff 시 plan.md §3 "Out of scope 항목이 backlog 로 surface 시 즉시 별도 sprint 분기" 룰을 명시 추가.
- **Do**: CTO 구현 중 발견된 실무 패턴 (`learning-logs/` 후보 P-…).
  - **P-mid-review-doc-mitigation** (가칭) — CPO finding 등재 → 외부 worker (codex) 가 같은 review window 에서 자연 fix → CPO finding RESOLVED. 본 review.md §2.8 의 worked example 자체가 첫 evidence.
  - **P-codex-cross-check-runtime-drift** (가칭) — primary CPO review 외에 second cross-check (별도 runtime instance) 가 adapter/runtime 영역의 drift (F-4a/F-4b) 를 surface 시킨 case. self-validation 방지 원칙의 second-order 적용 (review 의 review).
- **Check**: CPO review verdict / G4 partial 항목과 retro 시점에서의 후속 plan.
  - G4 verdict = pass (5-Axis 22/25 = 88%). queue MVP code 영역에는 partial 항목 없음.
  - retro 시점 추가 surface 한 F-4a/F-4b 는 queue MVP scope 밖 → adapter/runtime 영역의 **별도 sprint** 후보.
- **Act**: 본 sprint 학습을 다음 sprint plan / convention 문서에 어떻게 반영할지.
  - **CLAUDE.md / 5-step convention** 에 "plan.md §3 Out of scope 항목이 backlog 로 surface 하면 같은 sprint dir 이 아니라 새 sprint id 로 분리" 룰 추가 검토.
  - **adapter dispatch table audit** 와 **events emit restore** 두 sprint 를 다음 cycle backlog 로 등재.
  - **mid-review doc mitigation pattern** 을 learning-logs 로 정형화 + 향후 review template 의 "잔여 권고 status (post-review reconciled)" section 을 의무화.

## §3. 정량 메트릭

- **시간 (estimate vs actual)**:
  - Plan 의도: queue MVP 단일 sprint, 약 1~2 시간 (G1~G4 lifecycle).
  - Actual: 23:18 (sprint_start) → 02:30 (CPO G4 review 완료) = **약 3.2 시간** (queue MVP scope 본체).
  - Mid-review chunky 6 follow-up: 02:07 → 02:25 = **약 18 분** (codex 자율 진행으로 빠름).
  - 누적 sprint window: 23:18 → 08:55 (본 retro draft) = **약 9.6 시간** (overnight 자율주행 포함).
- **AC 통과율**: AC1~AC6 = **6/6 PASS** (G4 verdict 매트릭스 review.md §2.1).
- **files touched**:
  - `.sfs-local/scripts/sfs-loop.sh` (985L → 1207L, +222L)
  - `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh` (동일 sync)
  - `.sfs-local/queue/{pending,claimed,done,failed,abandoned}/.gitkeep` × 5
  - `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/queue/{...}/.gitkeep` × 5
  - `2026-04-19-sfs-v0.4/solon-mvp-dist/{README.md,GUIDE.md,templates/SFS.md.template}` × 3
  - sprint files (`brainstorm.md`, `plan.md`, `log.md`, `review.md`, `retro.md`) × 5
  - 누계: **~25 file** (active + dist parity 포함).
- **ahead 변화**:
  - sprint 시작 시점 git HEAD = `0b43423 docs(learning): record Claude worktree gitlink incident`.
  - sprint retro 시점 git HEAD = 동일 (본 모든 변경이 dirty worktree, 사용자 manual commit pending).
  - ahead 변화 = **0** (CLAUDE.md §1.5 push 사용자 manual + §1.5' commit 도 사용자 영역 정합). 단 dirty worktree 의 file 수가 +25 정도.
- **5-Axis CPO**: 22/25 = 88% (review.md §2.6).

## §4. 다음 sprint 인계

- **이어가는 항목**: 없음 (queue MVP code scope 닫힘).
- **분기되는 WU/sprint** (사용자 결정 후 backlog 등재):
  - `solon-loop-queue-lifecycle` (가칭) — codex 가 inline append 한 lifecycle/verify/sizing/depends-on/files-scope 6 항목의 **retro-light** + 별도 sprint id 인계. F-3 Process drift 의 사후 정합.
  - `solon-events-emit-restore` (가칭) — F-4b 의 adapter emit gap 점검 sprint. bash adapter review/retro/decision/start/loop 명령에서 emit_event call 누락 site identification + fix.
  - `solon-adapter-dispatch-audit` (가칭, 또는 single-task) — F-4a 의 docs vs `bin/sfs` dispatch 1:1 매트릭스 검증.
  - `solon-loop-queue-multi-worker-smoke` (가칭) — 본 sprint 5-Axis 안정성 -1 회수용 multi-worker contention smoke.
- **결정 대기 (W10 후보)**:
  - ⚠️ **F-4b events.jsonl backfill 정책** — pretend-normal 은 금지 (정상 adapter log 으로 가장 = audit trail 오염). 옵션 = (a) do nothing + close path 차단 수용 / (b) repair-tag backfill (`{"ts":"...", "type":"...", "by":"manual-repair", "note":"..."}` 형태). 사용자 결정 후 진행 (CLAUDE.md §1.3).
  - 위 결정이 끝나야 §5 G5 close 체크 진입 가능.

## §5. G5 close 체크

- [x] **events.jsonl 마지막 entry 가 본 sprint 의 `gate_review G5:pass` + `sprint_close`** — 사용자 옵션β 승인 (timestamp=현재 / by=manual-repair / note="backfill: adapter emit gap (F-4b)") 후 manual emit 4건 append: `review_open G4` (09:15:00) + `retro_open` (09:15:01) + `gate_review G5:pass` (09:15:02) + `sprint_close` (09:15:03). pretend-normal 금지 정합 — 4 entry 전부 `by:"manual-repair"` + note 명시. JSON validity python json.loads PASS.
- [x] **`closed_at` frontmatter 기록** — `2026-05-01T09:15:03+09:00` (sprint_close event ts 와 동일). 본 manual close 는 `sfs retro --close` 자동 commit (CLAUDE.md §1.5 / 원본 queue task spec "Do not git add/commit/push" 위배) 대신 file 편집만으로 처리.
- [ ] **HANDOFF / sessions log 에 본 sprint 결과 link 1줄 추가** — 사용자 manual 영역 (HANDOFF-next-session.md / sessions/_INDEX.md).
- [ ] **F-3 / F-4a / F-4b 의 별도 sprint 분기 등재** — §4 분기되는 WU/sprint 의 가칭 4 항목 (`solon-loop-queue-lifecycle` / `solon-events-emit-restore` / `solon-adapter-dispatch-audit` / `solon-loop-queue-multi-worker-smoke`) 을 backlog (queue/pending/) 로 enqueue 또는 sprint dir 신설. 사용자 결정 후 진행.
- [ ] **사용자 manual git commit + push (잔여)** — 사용자가 이미 sprint bundle 을 `7e19a36 sfs(loop): ship queue bundle and runtime ownership rule` 로 commit 완료 (`0b43423` 위에). 잔여 dirty 2 file = `.sfs-local/sprints/solon-loop-queue-mvp/{log.md, retro.md}` (본 G5 close 결과물). events.jsonl 은 gitignored. CLAUDE.md §1.18 형식 따라 retro/close commit 1건 (사용자 manual): `cd ~/agent_architect && git add .sfs-local/sprints/solon-loop-queue-mvp/{log.md,retro.md} && git commit -m "retro(solon-loop-queue-mvp): G5 close (pass) + manual events backfill"` + push (사용자 결정).

> **본 retro 의 status**: G5 close **완료** (manual close, β + manual-repair tag). 사용자 manual 잔여 = HANDOFF link + 분기 sprint 등재 + git commit/push.
