---
doc_id: wu-27-sfs-loop-locking
title: "WU-27 sub-task 3 — /sfs loop locking spec (§6.5 Optimistic Locking + Status FSM 4-state)"
visibility: business-only
parent_wu: WU-27
parent_file: 2026-04-19-sfs-v0.4/sprints/WU-27.md
sub_task: 3
opened_at: 2026-04-28T23:25:00+09:00
session_opened: admiring-zealous-newton
spec_source: 2026-04-19-sfs-v0.4/tmp/sfs-loop-design.md (v0.3 §6.5 verbatim mapping + CLAUDE.md §1.16 정합)
related_rule: CLAUDE.md §1.16 (Optimistic Locking + Status FSM, 24th-52 신설)
---

# WU-27 sub-task 3 — /sfs loop locking spec (§6.5 Optimistic Locking + Status FSM 4-state)

> main `sprints/WU-27.md §∗` 분할 plan 정합. 본 file = §6.5 Optimistic Locking + Status FSM 4-state (PROGRESS / COMPLETE / FAIL / ABANDONED) + auto-retry + crash recovery + idempotency 요구사항. CLAUDE.md §1.16 정문 SSoT 와 직접 매핑.

---

## §6.5.1 사용자 발화 verbatim (24th-52 brave-gracious-mayer continuation 5)

> **2026-04-28T20:48 KST**: "일단 작업을 시작하면 버저닝관리를 해 백엔드 개념에 낙관적 락 개념이 있고 Spring JPA에서도 회원정보 수정 같은거 할때 버저닝 관리를 하잖아?? 진입하는 시점에 버전을 업데이트 해주고, 상태도 COMPLETE, PROGRESS, FAIL 이렇게 3개의 상태를 두고, 버전업이 되면서 작업이 진행중이면 상태를 PROGRESS 완료되면 COMPLETE로 해두고, 네트워크오류나 기타등등의 장애로 제대로 작업이 안끝난거 같으면 다음 세션에서 동작할때 확인 후 FAIL상태로 두고 FAIL이면 재작업 -> 다시 PROGRESS이런식으로 진짜 시스템 처럼 움직이는게 낫지 않을까???"

> **추가 컨펌 (2026-04-28T21:05 KST)**: "자동재시작 그리고 Spring JPA처럼 인거지 Spring JPA를 구현하라는거 아님" → **Spring JPA conceptual borrowing only**, 실 JPA / annotation / persistence framework 구현 0. PROGRESS.md frontmatter yaml 필드 + bash 함수 전부.

---

## §6.5.2 4-state FSM (PROGRESS / COMPLETE / FAIL / ABANDONED)

```
        ┌──────────────────────────────────────────────┐
        │                                              │
        ▼                                              │
   ┌──────────┐  claim 성공     ┌─────────────┐       │
   │  (none)  │ ───────────────▶│  PROGRESS   │       │
   └──────────┘                  └─────────────┘       │
        ▲                              │               │
        │                              │               │
        │ next domain claim            ├──── 정상 ────▶┌──────────┐
        │                              │     release   │ COMPLETE │
        │                              │               └──────────┘
        │                              │
        │                              ├──── stale detect or safety_lock trip
        │                              ▼
        │                         ┌──────────┐
        │      retry_count < 3    │   FAIL   │  retry_count >= 3   ┌────────────┐
        │      (auto-retry) ◀─────┤          ├────────────────────▶│ ABANDONED  │
        │                         └──────────┘                     └────────────┘
        │                                                                │
        └────────────────────────────────────────────────────────────────┘
                                                       (escalate to user
                                                        + W10 TODO + ⚠️)
```

---

## §6.5.3 Schema (PROGRESS.md frontmatter, `domain_locks.<X>` 안 추가 필드)

```yaml
domain_locks:
  D-I-WU-27:
    # 기존 필드 (CLAUDE.md §1.12 mutex)
    owner: <codename | null>
    claimed_at: <ISO8601 | null>
    last_heartbeat: <ISO8601 | null>
    ttl_minutes: <int>
    next_step: <int>
    last_step_done: { ... }
    # § 6.5 추가 필드 (Optimistic Locking + Status FSM)
    status: PROGRESS | COMPLETE | FAIL | ABANDONED   # default = COMPLETE (closed)
    version: <int>           # claim 시점 +1, JPA @Version 차용 (race 감지)
    retry_count: <int>       # 0 ~ 3, FAIL → PROGRESS auto-retry 시 +1
    failed_at: <ISO8601 | null>   # FAIL 마킹 시점
    fail_reason: <string | null>  # detect_stale | explicit_abort | verify_fail | safety_lock_<id>
```

---

## §6.5.4 Transition trigger rule

| from | to | trigger | action |
|---|---|---|---|
| (none) | PROGRESS | claim 성공 | `version+=1`, `retry_count=0`, `status=PROGRESS`, `owner=self`, `claimed_at=now` |
| PROGRESS | COMPLETE | 정상 release | `status=COMPLETE`, `owner=null`, `last_step_done` 갱신 |
| PROGRESS | FAIL | 다음 worker 진입 시 stale detect (`last_heartbeat > ttl_minutes` + `owner != self`) | `status=FAIL`, `failed_at=now`, `fail_reason=detect_stale`, `owner=null` |
| PROGRESS | FAIL | 진행 중 safety_lock trip (mental-coupling / git-commit-self / 등) | `status=FAIL`, `failed_at=now`, `fail_reason=safety_lock_<id>`, `owner=null` |
| FAIL | PROGRESS | 다음 worker 진입 시 auto-retry (`retry_count < 3`) | `retry_count+=1`, `version+=1`, `status=PROGRESS`, `owner=self`, `last_step` = 직전 FAIL 의 `last_step` (idempotent 가정 → 같은 micro-step 재시작) |
| FAIL | ABANDONED | `retry_count >= 3` | `status=ABANDONED`, escalate to user (W10 TODO append + ⚠️ marker, PROGRESS 본문 ②/③ stuck 섹션 표기) |
| COMPLETE | (none) | next domain claim | `status` field 유지, history only |

---

## §6.5.5 Crash recovery sequence (다음 worker 진입 시)

```sh
worker_pre_flight() {
  # CLAUDE.md SSoT Read + PROGRESS.md frontmatter Read 후 매 도메인 검사
  for domain in $(list_domains); do
    status=$(get_status "$domain")
    last_hb=$(get_last_heartbeat "$domain")
    ttl=$(get_ttl "$domain")
    retry=$(get_retry_count "$domain")

    if [[ "$status" == "PROGRESS" ]] && stale "$last_hb" "$ttl"; then
      mark_fail "$domain" "detect_stale"
      status="FAIL"   # fall-through to next branch
    fi

    if [[ "$status" == "FAIL" ]]; then
      if [[ "$retry" -lt 3 ]]; then
        auto_restart "$domain"   # claim_lock + retry_count+=1 + resume from last_step_done.step
      else
        mark_abandoned "$domain"
        escalate_w10_todo "$domain" "ABANDONED after 3 retries"
      fi
    fi
    # COMPLETE / ABANDONED → 정상 priority sweep 단계로
  done
}
```

---

## §6.5.6 Idempotency 요구사항

Auto-retry 가 안전하려면 **각 micro-step idempotent** 해야 함. WU-25 / WU-26 / WU-27 의 row 단위 작업이 이미 이 조건 충족:
- **file 신설**: `[ ! -f $PATH ]` check → 이미 존재 시 skip / 부분 산출물 발견 시 verify 후 resume
- **frontmatter update**: awk-based replace (existing-key replace path, append 회피)
- **events.jsonl append**: 재실행 시 중복 entry 가능 = 알려진 trade-off (7 sample 중 5건 happy path 수렴, sub-task 6 구현 시 `seen_events.jsonl` dedup helper 후속 검토)
- **PROGRESS heartbeat**: 매 step 덮어쓰기 = idempotent 본질

Non-idempotent micro-step 발견 시 = ⚠️ + retry 금지 + 사용자 수동 복구.

---

## §6.5.7 Implementation scope (sub-task 6 후속)

bash 함수 spec (sfs-common.sh 또는 sfs-loop.sh 안 신설):

```sh
claim_lock <domain>             # version+=1, status=PROGRESS, retry_count 보존
release_lock <domain> <verdict> # verdict ∈ {complete, fail}, status 갱신, owner=null
detect_stale <domain>           # last_heartbeat 검사, exit code = stale 여부
mark_fail <domain> <reason>     # status=FAIL, fail_reason 기록
mark_abandoned <domain>         # status=ABANDONED, retry_count>=3 시
auto_restart <domain>           # retry_count check + claim 재시도
escalate_w10_todo <domain> <msg> # cross-ref-audit.md §4 W-XX append + ⚠️ marker
```

---

## §6.5.8 CLAUDE.md §1.16 SSoT 정합

본 §6.5 spec = CLAUDE.md §1.16 (Optimistic Locking + Status FSM, 24th-52 신설) 의 inflation. §1.16 verbatim:

> "WU/도메인 진입 시 `version+=1`, `status=PROGRESS`, `retry_count` 보존 (claim). 정상 release 시 `status=COMPLETE`. 다음 worker 진입 시 stale PROGRESS detect (`last_heartbeat > ttl_minutes`) → `status=FAIL` + auto-retry (`retry_count<3` 시 재claim) / `retry_count>=3` 시 `ABANDONED` + escalate (W10 TODO + ⚠️). Spring JPA `@Version` **conceptual borrowing only** (실 JPA / persistence framework 구현 0, PROGRESS.md frontmatter yaml + bash 함수 전부). `agents/CLAUDE.md` 'Max 3 rework iterations' 매핑."

→ retry_count cap=3 = `agents/CLAUDE.md` "Score >= 90 = pass, Max 3 rework iterations" invariant 와 직접 매핑.

**주의**: Spring JPA = conceptual borrowing only. 실 JPA / Hibernate / persistence framework 구현 0. PROGRESS.md frontmatter yaml 편집 + bash 함수가 전부.

---

## §∗. 다음 sub-task

- **sub-task 4** = `sprints/WU-27/sfs-loop-review-gate.md` (~120-150L) — §6.6 Pre-execution Review Gate (PLANNER `agents/planner.md` CEO + EVALUATOR `agents/evaluator.md` CPO persona invocation, CLAUDE.md §1.15 정합) ← 다음 진행 추천
- sub-task 5 = `sfs-loop-multi-worker.md` (~100-120L) — §6.0 Worker Independence Invariant + §6.4 Multi-worker spawn (`--parallel` / `--isolation` / mental coupling 진단)
- sub-task 6 (구현) = sfs-loop.sh ~500-650L + sfs-common.sh::claim_lock/release_lock/detect_stale/mark_fail/auto_restart/escalate_w10_todo helper 7건 + sfs.md adapter +1 row "loop"
