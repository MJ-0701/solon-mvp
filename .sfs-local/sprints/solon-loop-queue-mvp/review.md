---
phase: review
gate_id: "G4"
sprint_id: "solon-loop-queue-mvp"
goal: "Solon loop queue MVP: file-backed queue for /sfs loop"
created_at: "2026-04-30T23:18:27+09:00"
last_touched_at: "2026-05-01T02:05:00+09:00"
evaluator_role: CPO
evaluator_persona: ".sfs-local/personas/cpo-evaluator.md"
evaluator_executor: "claude (queue task loopq-20260430T165820Z-8266)"
generator_executor: "codex (per log.md §3)"
---

# Review — Solon Loop Queue MVP

> Sprint **CPO Evaluator review** 산출물. G2/G3/G4 중 하나의 gate 에 대한 verdict 기록.
> 각 gate review 마다 `.sfs-local/events.jsonl` 의 `review_open` event append.
> SSoT: `gates.md §1` (7-Gate enum) + `05-gate-framework.md §5.1` (매트릭스).
> 동일 sprint 안에서 G2/G3/G4 review 가 여러 번 발생할 경우 본 파일에 §2 섹션을 추가 append.
> 자체검증 방지: CTO Generator 와 CPO Evaluator 는 같은 산출물을 같은 agent instance 가 통과시키지 않는다.

---

## §1. 대상 Gate

- **gate_id**: G4 (Check Gate, 5-Axis CPO)
- **scope**: file-backed loop queue MVP — `sfs-loop.sh` queue helpers/subcommands (`queue` / `enqueue` / `claim` + default run queue-first pick), active/dist parity, README/GUIDE wording. AC1~AC6 from `plan.md §2`. 코드 변경 자체 + docs wording risk + handoff clarity.
- **trigger**: queue task `loopq-20260430T165820Z-8266` (claimed by `claude-overnight`, 2026-04-30T16:59:31Z) 자율 실행.
- **CPO persona**: `.sfs-local/personas/cpo-evaluator.md`
- **review executor/tool**: claude (different runtime/instance from codex generator → self-validation 방지 정합).
- **generator executor/tool**: codex (per `log.md §3 CTO 구현 메모`).

## §2. 평가 항목

### G4 — Check Gate (5-Axis CPO)

- [x] 설계 vs 구현 gap (정량)
- [x] 5-Axis (사용자가치 / 안정성 / 일정 / 비용 / 학습) 점수
- [x] partial 시 잔여 작업 → 다음 sprint 또는 별도 WU 로 분기 (해당 없음, pass 권고)

### §2.1 AC matrix (plan.md §2 vs CPO 독립 검증)

| AC | 요구 | CPO 독립 검증 방법 | 결과 |
|:---|:---|:---|:---|
| AC1 | queue scaffold 5 path 존재 | `find .sfs-local/queue -name .gitkeep` + dist 동일 | **PASS** — active 5/5, dist 5/5 (`pending/claimed/done/failed/abandoned`) |
| AC2 | `enqueue "<title>"` 가 pending md task 생성 | sandbox `cp -a .sfs-local /tmp/...` 후 `sfs-loop.sh enqueue 'CPO smoke "quoted" title'` | **PASS** — `loopq-<UTC>-<pid>-cpo-smoke-quoted-title.md` 생성, frontmatter `status: pending` + escaped title |
| AC3 | `queue` 가 상태별 count 출력 | sandbox stdout: `queue · pending N · claimed N · done N · failed N · abandoned N` | **PASS** — 5-state counts 정상 |
| AC4 | `claim --owner X` 가 task 를 `claimed/X/` 로 이동 | sandbox `claim --owner cpo-review-smoke` → file path 확인 | **PASS** — `claimed/cpo-review-smoke/<task>.md`, frontmatter `status: claimed` + `owner: cpo-review-smoke` + `claimed_at: <UTC>` 갱신 |
| AC5 | `--dry-run` 이 pending queue task 를 먼저 pick | code path inspection (`cmd_loop_run` line 712~733: `_pick_queue_task` 가 `_pick_domain` 보다 앞) + log.md 의 sandbox PASS 증거 | **PASS** — queue-first 분기가 domain sweep 앞에 위치, dry-run 시 `[DRY-RUN] would claim_queue_task for $LOOP_OWNER` 만 출력하고 file mv 안 함 |
| AC6 | `bash -n` 양쪽 PASS | `bash -n .sfs-local/scripts/sfs-loop.sh` + `bash -n 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh` | **PASS** — 양쪽 PASS |

### §2.2 Active vs Dist parity

- 본 review 도중 codex 의 parallel queue task (`loopq-...8208-codex-implement-queue-lifecycle-subcommands`) 가 **lifecycle subcommand `complete/fail/retry` 를 동일 `sfs-loop.sh` 에 mid-review 추가** (985 → 1207 lines, +222 lines). 이는 본 sprint plan.md §3 Out of scope 였던 후속 항목으로 **별도 sprint 에서 처리되었으나 동일 file 을 mutate**.
- 두 시점 모두 (review 시작 985L 시점 + review 중 1207L 시점) `cmp -s` **IDENTICAL** byte-for-byte 유지. R-D1 dev-first sync (§1.13) 정합.
- 두 시점 모두 `bash -n` 양쪽 PASS.
- queue scaffold `.gitkeep × 5` active = dist 동일.
- 본 sprint scope (queue MVP, AC1~AC6) 의 코드 영역은 lifecycle 변경에 의해 영향받지 않음 — `_pick_queue_task` / `_claim_queue_task` / `_queue_counts` / `usage_loop` / `parse_args queue|enqueue|claim` 분기는 그대로. lifecycle 은 `complete|fail|retry` 별도 case + helper 만 추가.
- 결론: drift 0, 본 sprint 의 G4 verdict 에 영향 없음. lifecycle 영역의 docs 갱신 여부는 §2.7 별도 관찰로 분리.

### §2.3 회귀/안전성 체크 (plan.md §5 CPO 검증)

- [x] `status / stop / replay / domain_locks fallback` 가 깨지지 않는지: `parse_args` switch 에 `queue|enqueue|claim` 만 추가, 기존 sub-cmd 분기 (`status|stop|replay`) 보존 확인. `cmd_loop_run` 도 `_pick_queue_task` 가 빈 결과를 반환하면 기존 `_pick_domain` fallback 으로 그대로 진입. **회귀 없음**.
- [x] queue claim 의 atomicity: `_claim_queue_task` 가 단일 `mv` 로 pending → claimed/<owner>/ 이동 후 frontmatter rewrite. mv 가 atomic 이라 동시 worker 가 같은 file 을 둘 다 claim 할 가능성은 사실상 없음 (mv 가 1번만 성공). **OK**.
- [x] quoted title 처리: `enqueue` 의 `safe_title="$(printf '%s' "$title" | sed 's/"/\\"/g')"` 로 frontmatter `title: "<safe>"` 안전. sandbox 에서 `'CPO smoke "quoted" title'` 입력 → `title: "CPO smoke \"quoted\" title"` 정상 생성 확인. **OK**.

### §2.4 Wording 위험 — queue vs sprint scope SSoT

- README.md `### /sfs loop 자세히` (line 263~280) 에서 **명시적 분리 문장 1개** 존재:
  > "queue 는 실행 대기열이고, sprint scope 의 SSoT 는 여전히 `brainstorm.md` / `plan.md` / decision file 입니다."
  → **OK, 충분**. 새 사용자가 queue 를 scope SSoT 로 오해할 위험은 이 한 문장으로 차단됨.
- GUIDE.md 는 §6 Multi-vendor 섹션 (line 340~347) + §5 cheatsheet (line 300~303) 에서 queue 명령만 소개하고 SSoT 분리 문장이 없음. **약한 경고** — README 가 1차 docs 이고 GUIDE 가 onboarding 보조 (advanced 섹션) 인 것을 고려하면 blocking 은 아님.
- 결론: blocking 아님, **F-1 (Doc, optional)** 권고로 분류 (§3 잔여 항목 참조).

### §2.5 Wording 위험 — default `/sfs loop` MVP claimed-task leak

- `sfs-loop.sh` line 894 (review 중 codex 가 lifecycle 추가하면서 line shift; 의미는 동일): 사용자가 `--dry-run` 없이 default loop 를 실행하면 queue task 를 claim 만 하고 실행 site 를 stub 처리:
  > `loop:   [MVP] queue task execution is not wired yet; leaving task claimed`
- 즉 사용자가 `enqueue` → `/sfs loop` 를 돌리면 task 가 `claimed/<owner>/` 에 자동 남음. 다음 loop iter 에 같은 task 가 다시 pick 되지는 않으나 (`_pick_queue_task` 가 `pending/` 만 sweep), 사용자가 "loop 가 done 시킨 줄" 알고 `claimed/` 를 정리 안 하면 dust 가 누적.
- **부분 완화 (review 중 발생)**: codex 가 mid-review 에 `loop complete <task>` / `loop fail <task>` / `loop retry <task>` 를 출시 → 사용자가 **수동으로** lifecycle 을 닫을 수 있음. 단 default loop run 의 자동 stub 메시지는 그대로이므로 사용자가 메시지를 보고 "다음에 어떻게 처리하라" 는 hint 가 부족.
- README/GUIDE 어디에도 이 동작 (auto-stub + manual lifecycle path) 이 명시 안 됨 (CTO 메모 §3 만 "non-live default run 이 queue task 를 claimed 로 남기는 MVP 정책이 acceptable 한가" 자문). **handoff 위험 = mid → low** (lifecycle 출시 후 mitigated, 단 docs 가이드 부재).
- 결론: blocking 아님, **F-2 (Doc, recommended)** 권고로 분류 — 권고문은 §3 에서 lifecycle 명시까지 포함하도록 갱신.

### §2.7 Mid-review 발생 parallel 작업 관찰 (out-of-scope, 정보)

> 본 §2.7 은 본 sprint G4 verdict 의 직접 입력이 **아니다** (lifecycle/verify/sizing 은 plan.md §3 Out of scope). 별도 sprint 의 wording 검토용 자료로만 기록.

- 본 review (claude G4) 진행 도중 codex 가 backlog 의 large/medium queue task 들을 자율 진행하면서 `sfs-loop.sh` 와 docs 를 다음 항목까지 확장:
  - 02:07 KST — `complete / fail / retry` lifecycle subcommands.
  - 02:11 KST — autonomous queue backlog 자체를 chunky 로 resize (large/medium task 3건 추가).
  - 02:14 KST — task body execution prompt artifacts (`.sfs-local/queue/runs/<task-id>/<ts>/PROMPT.md` + `metadata.env`).
  - 02:18 KST — `verify <task>` subcommand + auto lifecycle (verify pass→done, fail→failed).
  - 02:21 KST — `--size small|medium|large` + `--target-minutes N` + stale claimed visibility + **README/GUIDE/SFS.md.template 문서 갱신** (queue=execution-backlog wording, manual lifecycle path 명시, non-live prompt artifact behavior, `SFS_LOOP_LLM_LIVE` / `SFS_LOOP_VERIFY` 환경변수).
  - 02:23 KST — max-attempts + abandoned policy + `abandon <task>` subcommand.
  - 02:25 KST — `depends_on` + files-scope guard (queue picker 가 dependency unmet 또는 scope conflict 시 skip + visibility).
- 누적 결과: `sfs-loop.sh` 985L → 1207L (+222L), 그리고 추가 변경분이 cmp/bash -n 양쪽 PASS 유지 채로 dist 와 byte-identical sync.
- codex 의 모든 sprint log entry 가 본 sprint (`solon-loop-queue-mvp`) log §1 에 append 되어 plan.md §3 "Out of scope" 와 충돌하는 운영 결정. 다만 결과적으로 backlog → ship → docs reflect 까지 한 번에 닫혀 R-D1 (§1.13) 정합. **F-3 (Process observation, info-only)**: 향후 lifecycle/verify/sizing 같은 chunky follow-up 은 별도 sprint id 로 분리하는 것이 sprint contract 정합 측면에서 더 깨끗 — 단 본 G4 verdict 에 영향 없음.

### §2.8 Mid-review 진행분이 F-1 / F-2 권고에 미친 영향 (post-review state)

> 본 review 의 F-1 / F-2 권고는 **review 시작 시점 (sfs-loop.sh 985L)** 의 README/GUIDE 상태 기준으로 작성되었다. review 도중 codex 02:21 entry 가 docs 를 갱신했으므로 권고 status 를 재검증한다.

- **F-1 (queue=실행 대기열 vs sprint scope SSoT cross-ref in GUIDE)** → **RESOLVED in mid-review**. GUIDE.md line 342~343 신규 문장 검증:
  > "고급 사용자는 큰 정합성 작업을 queue 에 먼저 넣을 수 있다. queue 는 execution backlog / 실행 대기열이고, sprint scope SSoT 는 여전히 `brainstorm.md` / `plan.md` / decision file 이다."
  → 권고 의도가 그대로 반영. F-1 closed.
- **F-2 (default `/sfs loop` 의 claim-but-no-execute 동작 + manual lifecycle 명시)** → **RESOLVED in mid-review**. 검증:
  - README line 285~294: non-live default loop 동작 (`PROMPT.md` + `metadata.env` 만 만들고 executor 호출 안 함), `SFS_LOOP_LLM_LIVE=1` 토글, `SFS_LOOP_VERIFY=1` 자동 close, manual `complete / fail / retry / abandon / verify` lifecycle 모두 명시.
  - GUIDE.md cheatsheet line 304~305: `loop verify` + `loop complete|fail|retry|abandon <task>` 추가.
  - GUIDE.md §6 line 354~357: non-live default loop 동작 + verify auto lifecycle + retry/abandoned 정책 명시.
  → F-2 closed.
- **F-3 (process observation, lifecycle 작업이 본 sprint log 에 inline 흡수)** → **그대로 유효** (info-only).
- 결론: §2.4 / §2.5 본문은 review 의 historical record 로 보존, 단 §3 Verdict 의 잔여 권고 list 는 §2.8 의 closing 을 반영해 갱신.

### §2.9 외부 cross-check (codex) 추가 finding — adapter / runtime drift

> 본 G4 review verdict (pass) 직후 codex 가 sprint state cross-check 를 실행하면서 surface 한 추가 fact 2건. 본 sprint scope (queue MVP, AC1~AC6) 의 코드/AC 에는 영향 없으므로 G4 verdict 변경 없음. 다만 **adapter/runtime 영역의 docs vs 실제 동작 drift** 라 retro 안건으로 기록.

- **F-4a (Adapter drift, retro 안건)**: README.md `## Product Surface` (line 244~257) 와 `bin/sfs` dispatch table 사이에 `sfs log` 같은 명령어 surface gap 가능성. codex 직접 검증: `sfs log` 실행 → unknown command, exit 7. 실제 dispatch table 명령은 11개 (`status / start / guide / auth / brainstorm / plan / review / decision / retro / loop` + init/update 류). 사용자가 docs 에서 본 명령이 adapter 에 없으면 silent 한 어색함을 만든다. **fix scope**: 본 G4 review 가 다룬 queue MVP 영역은 아님. retro 시점에 adapter dispatch table audit 단발 작업 또는 별도 sprint 분리.
- **F-4b (Runtime drift, retro 안건)**: `.sfs-local/events.jsonl` 마지막 entry 가 `2026-04-30T23:18:43+09:00 plan_open`. 그 이후 본 sprint 의 queue MVP 구현 / lifecycle / verify / sizing / review 작업 전부에서 `review_open` / `retro_open` / `sprint_close` event 가 emit 되지 않았음. README/GUIDE 가 약속한 "각 gate review 마다 `.sfs-local/events.jsonl` 의 `review_open` event append" (review.md template 본문 + GUIDE §1.4 promise) 와 **실제 bash adapter 의 실 동작이 일치하지 않음**. 결과:
  - sprint state machine (`/sfs status` ahead count / last_event) 가 stale 한 picture 를 보여줄 수 있음.
  - `sfs retro --close` 가 events.jsonl 안의 `review_open` 존재 여부를 gate 로 사용한다면 (현재 codex 분석 시점), **본 sprint 는 close path 진입 시 exit 8 가능성**. 수동 backfill 시 반드시 "repair/backfill" tag 명시, 정상 adapter log 처럼 가장 금지.
  - **fix scope**: review/retro/close 어느 명령이든 events.jsonl emit 책임이 누락. retro 시 adapter implementation gap 으로 기록 + 후속 sprint (`solon-events-emit-restore` 가칭) 에서 emit site 점검.
- 결론: F-4a/b 는 queue MVP code 영역 ≠ adapter/runtime 영역이라 본 G4 verdict (pass) 변경 없음. 단 sprint close 전에 retro 에서 명시적으로 다뤄야 하는 안건. F-3 (chunky follow-up 분리) 와 함께 retro 의 D4 (Decision/Drift) 또는 KPT 의 P (Problem) 에 묶어 기록 권고.

### §2.6 5-Axis CPO 점수

- **사용자가치**: 4/5 — queue-first pick 으로 `/sfs loop` 의 backlog 가시성 확보. complete/fail 까진 못 가서 -1.
- **안정성**: 4/5 — single-mv claim atomicity OK, frontmatter rewrite awk 안전. 다중 worker contention test 가 sandbox 에 없어서 -1 (다음 sprint 후보).
- **일정**: 5/5 — sprint 단일 do entry, scope 안에서 닫힘.
- **비용**: 5/5 — bash + python3 fallback, 외부 의존성 없음, dist 와 sync 됨 (drift 비용 0).
- **학습**: 4/5 — `_pick_queue_task` 의 python3 frontmatter parser 가 추후 dependency-graph / retry 확장 base 가 될 수 있음. -1 = decision log (`.sfs-local/decisions/`) 가 본 sprint 에서 mini-ADR 으로 분리 안 됨 (queue schema 결정이 plan.md 에 inline 됨, 큰 위험은 아님).

평균: **22/25 = 88%** → **pass 권고**.

## §3. Verdict

- **verdict**: **pass**
- **근거 (정량)**:
  - AC1~AC6 6개 전부 CPO 측 독립 재검증 PASS (§2.1).
  - active vs dist parity = byte identical (§2.2).
  - bash -n 양쪽 PASS, sandbox enqueue/queue/claim 양쪽 PASS, dry-run code path 정합 (§2.1).
  - 회귀 0 (§2.3).
- **근거 (정성)**:
  - queue 는 도입 의도대로 "execution backlog" 이고 sprint scope SSoT 는 brainstorm/plan/decision 으로 README 가 명시 분리. 핵심 wording risk 차단 (§2.4).
  - MVP claim-but-no-execute 정책은 plan §3 Out of scope 와 정합 (`task body execution` 명시 제외). 사용자 noise 는 docs F-2 로 보조하면 됨 (§2.5).
  - 5-Axis 평균 88% (§2.6).
- **partial 시 잔여 항목**: 해당 없음.
- **잔여 권고 status (post-review reconciled)**:
  - **F-1 (Doc, optional) → RESOLVED in mid-review**: GUIDE.md line 342~343 신규 wording 으로 queue=실행대기열 vs sprint scope SSoT cross-ref 반영됨. §2.8 참조.
  - **F-2 (Doc, recommended) → RESOLVED in mid-review**: README line 285~294 + GUIDE line 304~305 / 354~357 으로 default loop non-live behavior + manual `complete/fail/retry/abandon` + auto `verify` lifecycle 모두 docs 에 반영됨. §2.8 참조.
  - **F-3 (Process, info-only) → 유효**: chunky follow-up 작업 (lifecycle/verify/sizing/depends/files-scope) 이 본 sprint log §1 에 inline append 된 운영 결정. §2.7 참조. retro D4/Drift 안건. 본 G4 verdict 에 영향 없음.
  - **F-4a (Adapter drift, retro 안건, codex cross-check) → 유효**: `sfs log` dispatch table 미존재. §2.9 참조. queue MVP scope 밖. 본 G4 verdict 에 영향 없음.
  - **F-4b (Runtime drift, retro 안건, codex cross-check) → 유효**: `.sfs-local/events.jsonl` emit 누락 (queue 구현 / review / retro 시 `review_open`/`retro_open`/`sprint_close` 없음). §2.9 참조. retro D4/Drift + close 직전 backfill 정책 결정 필요. 본 G4 verdict 에 영향 없음.
  - 결론: 본 review 시작 시점 doc gap (F-1/F-2) 은 mitigated. F-3/F-4a/F-4b 는 retro 안건. 코드 변경 권고 0. 본 G4 통과를 막는 항목 없음. 단 `sfs retro --close` 직전에 F-4b 의 events backfill 정책을 사용자가 결정해야 안전.

## §4. 다음 액션

- **pass** → CTO Generator 최종 확인 (codex) 후 G5 retro 진입.
- F-1 / F-2 는 review 진행 중 codex 02:21 doc 갱신으로 자연 RESOLVED — 별도 follow-up 불필요.
- F-3 / F-4a / F-4b 는 retro 안건:
  - F-3 (chunky follow-up 같은 sprint dir inline append) → retro KPT 의 P 또는 D4/Drift.
  - F-4a (`sfs log` adapter dispatch 미존재) → retro D4/Drift + 후속 single-task 로 dispatch table audit 또는 별도 sprint.
  - F-4b (events.jsonl emit 누락) → retro D4/Drift + close 직전 backfill 정책 결정. backfill 시 entry tag = "repair/backfill" 명시 (정상 adapter log 으로 가장 금지).
- queue lifecycle / verify / sizing / depends-on / files-scope 등 codex 가 본 sprint log 에 inline append 한 항목들은 사실상 별도 sprint 에서 처리되었음에도 같은 sprint dir 에 흡수된 상태. retro 시점에 사용자 결정으로:
  - (a) plan.md §3 Out of scope 항목을 retro 에서 명시적으로 "후속 sprint 로 분리됨" 으로 mark, 또는
  - (b) 본 sprint 를 "Loop Queue MVP + Lifecycle Bundle" 로 scope 확장 후 retro 에서 종합 회고.
- ⚠️ **`sfs retro --close` 자동 호출 금지** until F-4b 의 events backfill 정책 + retro.md 본문 refine 이 사용자 손에서 끝날 때까지. 현재 events.jsonl 상태로는 close path 가 exit 8 로 막힐 risk.

## §5. CTO 응답 / 재구현 확인

- **CTO 확인**: TBD (codex generator 재진입 시 기록).
- **반영한 CPO finding**: TBD.
- **재구현 변경 파일/모듈**: TBD.
- **재리뷰 필요 여부**: 코드 영역 = no. F-1/F-2 doc patch 처리 시 = light wording review 만.

## §6. CPO Review Invocation Log

```
2026-05-01T02:05:00+09:00 — CPO G4 review 실행
  evaluator_executor: claude (queue task loopq-20260430T165820Z-8266 / owner claude-overnight)
  generator_executor: codex (per log.md §3)
  scope: AC1~AC6 + active/dist parity + wording/handoff risk
  inputs read:
    - .sfs-local/sprints/solon-loop-queue-mvp/{plan,log}.md
    - .sfs-local/scripts/sfs-loop.sh (985 lines)
    - 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh (985 lines, IDENTICAL via cmp -s)
    - 2026-04-19-sfs-v0.4/solon-mvp-dist/{README,GUIDE}.md
  CPO actions:
    - cmp/diff active vs dist (drift 0)
    - bash -n active + dist (PASS x2)
    - sandbox cp -a .sfs-local → /tmp/cpo-review-loopq-sandbox-<pid>/
        queue / enqueue 'CPO smoke "quoted" title' / queue / claim --owner cpo-review-smoke
        → AC2/AC3/AC4 stdout + filesystem PASS
    - AC5 code path inspection (line 712~733 queue-first → domain sweep fallback)
    - sandbox cleanup
  verdict: pass (5-Axis 22/25 = 88%)
  non-blocking findings: F-1 (GUIDE wording cross-ref) + F-2 (MVP claim-leak doc note)
  no git operations performed (per task spec + CLAUDE.md §1.5)
```
