---
doc_id: wu-27-sfs-loop-review-gate
title: "WU-27 sub-task 4 — /sfs loop Pre-execution Review Gate spec (§6.6 PLANNER+EVALUATOR persona invocation)"
visibility: business-only
parent_wu: WU-27
parent_file: 2026-04-19-sfs-v0.4/sprints/WU-27.md
sub_task: 4
opened_at: 2026-04-29T00:05:00+09:00
session_opened: admiring-zealous-newton
spec_source: 2026-04-19-sfs-v0.4/tmp/sfs-loop-design.md (v0.3 §6.6 verbatim mapping + CLAUDE.md §1.15 정합)
related_rule: CLAUDE.md §1.15 (자율진행 Pre-execution Review Gate, 24th-52 신설)
related_persona: agents/planner.md (CEO) + agents/evaluator.md (CPO)
---

# WU-27 sub-task 4 — /sfs loop Pre-execution Review Gate spec (§6.6 PLANNER + EVALUATOR persona invocation)

> main `sprints/WU-27.md §∗` 분할 plan 정합. 본 file = §6.6 Pre-execution Review Gate (PLANNER CEO + EVALUATOR CPO 두 페르소나 review 의무 + cascade depth cap=3) + CLAUDE.md §1.15 SSoT 정합.

---

## §6.6.1 사용자 발화 verbatim (24th-52 brave-gracious-mayer continuation 5)

> **2026-04-28T20:48 KST**: "자율진행은 기본적으로 작은작업 위주보다는 큰 작업을 위주로 하는게 맞음 그게 내가 스케줄러를 돌리고 loop를 돌릴려는 이유야, + 자율진행을 진행하기 전에 항상 CPO와 CEO리뷰를 받고 승인이 나면 진행 하도록 해 -> 승인이 나지 않으면 왜 안나는지 나한테 보고문서 작성하고, 다시 조금 더 작은단위의 작업 승인요청 이런식으로 cascade"

> **추가 컨펌 (2026-04-28T21:10 KST)**: "PLANNER(CEO) + EVALUATOR(CPO) 인데 docset에 있는 agent 사용해도 됨" → `agents/planner.md` (CEO) + `agents/evaluator.md` (CPO) 활용. 새 페르소나 정의 신설 0.

---

## §6.6.2 Review gate flow

```
worker proposes 자율진행 plan
   ↓
[CEO hat = agents/planner.md] review
   ├─ Verdict: PASS / FAIL / PASS-with-conditions
   └─ 사유 prose (business value, scope, WHO benefits, WHY now)
   ↓
[CPO hat = agents/evaluator.md] review
   ├─ Verdict: PASS / FAIL / PASS-with-conditions
   └─ 사유 prose (product quality, outcome, "is this useful")
   ↓
둘 다 PASS or PASS-with-conditions → 사용자 (CEO final approver) 승인 요청
   ├─ 승인 → 본 작업 진행 (status=PROGRESS, claim_lock)
   ├─ 미승인 → 미승인 사유 보고 + cascade 분할 (depth cap=3)
   └─ 다른 방향 → 사용자 결정 영역 (W10 TODO)
```

---

## §6.6.3 "큰 작업" 자동 detection (review gate 적용 대상)

자율진행 시작 전 review 의무 작업 = 다음 중 **하나 이상** 해당:

- 예상 분량 ≥ 10분 (wall-clock estimate)
- `files_touched` (frontmatter 또는 plan) ≥ 3 file
- `decision_points` (WU spec) 신설 또는 수정
- spec change (CLAUDE.md / draft v0.X / 도메인 정의 등 framework 영향)
- visibility 등급 변경 (raw-internal → business-only 등)

**작은 작업** (review gate skip, 자동 진행 OK):
- heartbeat (PROGRESS.md frontmatter `last_overwrite` 갱신)
- scheduled_task_log entry append (helper-driven, ≤ 5 lines)
- 단순 row 마킹 (`[ ] → [x]` + 1줄 narrative)
- file 1개의 1줄 sed (예: WU-27 referent 갱신 같은 mechanical fix)

---

## §6.6.4 PLANNER + EVALUATOR 호출 spec

worker 가 review gate 진입 시:

1. `agents/planner.md` 페르소나 read (frontmatter + Identity + Authority + Skills)
2. CEO hat 으로 plan 검토 → verdict + 사유 prose 산출 (≤ 5 sentences)
3. `agents/evaluator.md` 페르소나 read
4. CPO hat 으로 plan 검토 → verdict + 사유 prose 산출 (≤ 5 sentences)
5. 두 verdict + 사유 결합 → 사용자 final 승인 요청 doc 작성 (`tmp/sfs-briefing-template.md §2` 7 단계 형식, framework 결정은 +3 추가 = §1.17 정합)

---

## §6.6.5 "PASS with conditions" 처리

CPO (또는 CEO) 가 PASS-with-conditions 산출 시 = "작업 자체는 OK, 단 추가 deliverable 필요". conditions 종류:

- **(cond-N) 본 작업 안에서 자동 충족 가능** → review 통과, 작업 안에 condition 처리 포함 (e.g. cond-1 = "검증 smoke 5건 추가" → bash -n + smoke 자동 추가)
- **(cond-N) 후속 작업 필요** → review 통과, `tmp/sfs-loop-design.md §9` 또는 sub-task TODO 에 추가
- **(cond-N) 별도 사용자 결정 필요** → review FAIL 로 격상 + cascade (§6.6.6)

---

## §6.6.6 미승인 (FAIL) 시 cascade

```
review FAIL → 사유 보고 doc 작성 (≤ 200 word, tmp/sfs-fail-report-<wu>-<ts>.md)
   ↓
사용자에게 cascade 분할 옵션 제시:
   ├─ (option-1) 작업 abandon (yagni)
   ├─ (option-2) 작업 분할: 큰 unit → 작은 unit N개로 (e.g. 1 WU → 5 sub-task)
   ├─ (option-3) prerequisite 작업 먼저 (e.g. 다른 도메인 first)
   └─ (option-4) 사용자 직접 가이드 (custom plan)
   ↓
사용자 선택 → 새 plan 으로 review gate 재진입 (recursive)
```

**cascade depth cap = 3** (retry_count cap 정합, CLAUDE.md §1.16 매핑).
depth ≥ 3 시 사용자 manual 진행 강제 (자율 진행 abort + W10 TODO escalate).

---

## §6.6.7 24th-52 + 25th-1 self-application (본 §6.6 의 첫 dogfooding 사례)

본 spec 자체가 review gate 의 첫 적용 case 누적:

- **24th-52 brave-gracious-mayer continuation 5** = §6.5 + §6.6 보강 작업 자체. CEO (PLANNER) PASS + CPO (EVALUATOR) PASS-with-2-conditions (cond-1 = §6.0.2 false-positive 검증 = §9 후속 TODO 추가, cond-2 = §6.5/§6.6 prose 채우기 = 본 작업 자체) → 사용자 final 승인 → 진행.
- **25th-1 admiring-zealous-newton continuation 1** = WU-27 sub-task 1 신설 (frontmatter + §0 + §1.1~1.3 + §3.1 Solon-wide executor convention). PLANNER PASS-with-cond + EVALUATOR PASS-with-cond (cond-1 = main file ≤200L 분할 plan 사전 합의, cond-2 = sub-task 1 scope frontmatter+§0+§1.3 narrow) → 사용자 'ㄱㄱ' final approval → 진행 + (b) Solon-wide 추가 confirm → §1.18 신설 + path-neutral self-correction.
- **25th-1 continuation 2~3** = sub-task 2 (sfs-loop-flow.md) + sub-task 3 (sfs-loop-locking.md) = light review gate (sub-task 1 framework 그대로, mechanical translation, decision_points 신설 0) 자동 PASS.

→ 본 §6.6 spec = **사후 검증된 prototype 의 명령어화** (실 dogfooding 데이터 4건 누적).

---

## §6.6.8 Implementation scope (sub-task 6 후속)

bash 함수 spec (sfs-loop.sh 안 또는 sfs-common.sh):

```sh
review_with_persona <persona-path> <plan-doc>
  # agents/<persona>.md read + plan 검토 + verdict (PASS|FAIL|PASS-with-cond) + 사유 prose
  # 출력: stdout = verdict + reason, exit 0=PASS, 1=FAIL, 2=PASS-with-cond

submit_to_user <plan-doc> <reviews-doc>
  # tmp/sfs-briefing-template.md §2 7-단계 (framework 결정은 +3 추가) 형식 변환
  # 출력: tmp/sfs-review-submit-<wu>-<ts>.md 신설 (사용자 결정 대기 file)

cascade_on_fail <fail-reason> <original-plan>
  # fail 사유 보고 doc 신설 (≤200 word) + 4 옵션 (abandon/split/prereq/custom) prose
  # depth counter 갱신 (≥3 시 W10 TODO escalate)

is_big_task <plan>
  # §6.6.3 5 criteria 체크 (예상분량 / files_touched / decision_points / spec change / visibility)
  # exit 0 = 큰 작업 (review gate 적용) / 1 = 작은 작업 (skip OK)
```

---

## §6.6.9 CLAUDE.md §1.15 SSoT 정합

본 §6.6 spec = CLAUDE.md §1.15 (자율진행 Pre-execution Review Gate, 24th-52 신설) 의 inflation. §1.15 verbatim:

> "AI 가 '큰 작업' (≥10분 / files_touched ≥3 / decision_points 신설 / spec change / visibility 등급 변경 중 하나) 자율진행 시작 전 **PLANNER(CEO, `agents/planner.md`) + EVALUATOR(CPO, `agents/evaluator.md`) 두 페르소나 review 의무**. 둘 다 PASS 시 사용자 (CEO final approver) 승인 요청 → 승인 받고 진행. 미승인 시 사유 보고 + 작은 단위 cascade (depth cap=3). 작은 작업 (heartbeat / log entry append / row 마킹 등) 은 review gate skip 자동 진행 OK. Spec SSoT: `tmp/sfs-loop-design.md §6.6` (24th-52 brave-gracious-mayer continuation 5 사용자 결정 + self-application worked example)."

→ 본 sfs-loop-review-gate.md = `tmp/sfs-loop-design.md §6.6` 의 분할 이관 + dogfooding 사례 4건 누적 (24th-52 + 25th-1 × 3) 명시.

---

## §∗. 다음 sub-task

- **sub-task 5** = `sprints/WU-27/sfs-loop-multi-worker.md` (~100-120L) — §6.0 Worker Independence Invariant + §6.4 Multi-worker spawn / aggregation (`--parallel` / `--isolation` / mental coupling 진단 + worker-domain-pin 정책) ← 다음 진행 추천
- sub-task 6 (구현) = sfs-loop.sh ~500-650L + sfs-loop-coord.sh + sfs-common.sh helper 7건 (claim_lock / release_lock / detect_stale / mark_fail / mark_abandoned / auto_restart / escalate_w10_todo) + review-gate helpers 4건 (review_with_persona / submit_to_user / cascade_on_fail / is_big_task) + executor helper 1건 (resolve_executor) + sfs.md adapter +1 row "loop"
