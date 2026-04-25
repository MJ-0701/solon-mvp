---
pattern_id: P-04-session-hang-takeover
title: "세션 활성 유지하지만 진척 0 (hang) → 다음 세션이 mutex stale takeover"
status: resolved
severity: medium
first_observed: 2026-04-25
observed_by: epic-brave-galileo (20번째 세션, 19번째 eager-elegant-bell hang 감지)
resolved_at: 2026-04-25
resolved_by: epic-brave-galileo (20번째 세션, takeover 후 즉시 처리) + trusting-stoic-archimedes (21번째 세션, learning pattern 실체화)
resolved_via: |
  (1) §1.12 mutex 프로토콜의 'stale takeover 시 사용자 명시 confirm 필수' 원칙 추가 +
  (2) WU 문서 안에 §N takeover 기록 섹션 (hang cause + 근거 + 작업 상세) 표준화 +
  (3) PROGRESS released_history.last_reason 에 hang 사실 명시 (자발 release 아니어도 expired) +
  (4) 본 P-04 learning pattern 으로 일반화.
related_wu: WU-22 (19번째 open / 20번째 close, §7 takeover 기록)
related_docs:
  - sprints/WU-22.md §7 (20번째 세션 takeover 기록 SSoT)
  - PROGRESS.md frontmatter released_history.last_reason (hang 명시)
  - CLAUDE.md §1.12 (Session mutex protocol)
visibility: raw-internal
applicability:
  - "사용자 응답 수신 후 세션이 파일 수정/커밋/PROGRESS 갱신 0건 상태로 정지 (정상 처리 시간 초과)"
  - "다음 세션 진입 시점에 mutex TTL 초과 + 직전 세션의 진척 0 확인 가능"
  - "사용자 명시 발화 (예: '이어받아서 진행 ㄱㄱ') 로 stale takeover 정당성 확보"
reuse_count: 1   # 20번째 세션이 1회 사용. 21번째 세션이 fallback 정의 시 본 패턴 재참조.
related_patterns:
  - P-03   # staged-uncommitted-on-session-crash (작업 유실 패턴, 세션 종료 종류 차이)
---

# P-04 — session-hang-takeover

> **visibility: raw-internal** — 사용자 개인 운영 데이터 (세션 codename + mutex 프로토콜 내부 사항). OSS 마케팅 프로덕트에는 미공개.

---

## 문제

세션이 mutex `current_wu_owner` 를 정상 claim 한 상태에서 **사용자 응답 수신 직후 진척 0 으로 멈춤** (file edit 0, commit 0, PROGRESS 덮어쓰기 0). 외부에서는 "활성" 처럼 보이지만 실제로는 hang. mutex 자동 release 안 되므로 다음 세션이 진입 시 §1.12 의 충돌 처리 옵션 (a) 다른 WU / (b) takeover 승인 / (c) 중단 중 하나를 선택해야 함.

- **증상**: 마지막 commit 시각 ↔ 현재 시각 차이 큼 (TTL × N배). PROGRESS `last_overwrite` 갱신 안 됨. WU 체크리스트 진행 안 됨.
- **발생 조건**: 세션이 사용자 응답을 받았으나 후속 처리 (파일 변경 + commit + PROGRESS 갱신) 가 누락. 토큰 한계, runtime 오류, network drop, 또는 모종의 LLM 응답 실패.
- **원인**: §1.8 (작업 유실 최소화) 의 매 micro-step PROGRESS 갱신 + wip commit 강제력 부재. 사용자 답변 수신 단계가 commit 단위 안에 포함 안 되어 있음.
- **영향**: 결정 lost (예: 19번째 hang 시 사용자 β 결정 수신 후 56분간 미반영 → 20번째 takeover 로 복구).

## 해결 패턴

### 단계

1. **다음 세션 진입 시 mutex 검증** (resume-session-check.sh 가 자동 수행) — `current_wu_owner.last_heartbeat` 확인.
2. **TTL 초과 + 진척 0 확인** — `git log --oneline | head -3` + `git diff` 로 직전 세션 작업 진척 검증.
3. **사용자 명시 confirm 요청** — "직전 세션이 hang 한 것 같습니다. takeover 승인하시겠어요?" (자동 takeover 절대 금지, §1.12).
4. **사용자 명시 발화** (예: "ㄴㄴ 이어받아서 바로 진행 ㄱㄱ") **수신 후 takeover 진행**.
5. **takeover 작업** (대상 WU 마무리 또는 close):
   - 대상 WU 문서 안에 `§N takeover 기록` 섹션 추가:
     - hang cause (마지막 commit 시각, 진척 0 증거)
     - takeover 근거 (TTL × 배수, 사용자 confirm 발화 verbatim)
     - 본 세션의 takeover 후 작업 상세
     - learning pattern 후보 명시 (P-04 재사용 또는 P-NN 신규)
   - PROGRESS.md `released_history.last_reason` 에 hang 사실 명시 (자발 release 아니어도 expired 처리).
6. **scheduled_task_log entry append** — hang 세션도 trace 보존 (실 ahead_delta 와 결정 반영 위치 명시).
7. **본 P-04 패턴 재참조** — 같은 상황 재발 시 본 문서를 SSoT 로 활용.

### 샘플 명령 / 코드

```bash
# 1. 진입 직후 mutex 검증
bash 2026-04-19-sfs-v0.4/scripts/resume-session-check.sh
# → exit 16 (sched_log_drift) 또는 다른 신호 확인

# 2. 직전 세션 진척 확인
git log --oneline -5
git rev-list --count origin/main..HEAD

# 3. 사용자 confirm 받은 후, WU 문서에 takeover 기록 추가 (Edit 도구)

# 4. PROGRESS frontmatter 의 released_history 갱신 + scheduled_task_log entry append
bash 2026-04-19-sfs-v0.4/scripts/append-scheduled-task-log.sh <new-codename> <check_exit> "<takeover narrative>" "<ahead_delta>"
```

## 재사용 체크리스트

- [ ] 전제 조건 확인: mutex `current_wu_owner` claimed + TTL 초과 + 직전 세션 진척 0 (commits 0건, PROGRESS 갱신 0건).
- [ ] 사이드 이펙트 검토: hang 세션이 부분 작업 (예: file edit 일부, commit 누락) 했는지 확인 — staged/untracked diff 우선 처리 (P-03 연계).
- [ ] 롤백 가능 여부: takeover 후 작업이 hang 세션 의도와 일치하는지 사용자 검증 권장.
- [ ] 원칙 2 (self-validation-forbidden) 위반 여부 검토: takeover 자체가 의미 결정 아님 (사용자 confirm 필수). 단 hang 세션이 의미 결정 받았던 경우 그 결정만 반영하고 추가 의미 결정 자율 진행 금지.

## 관련 WU / 세션

- **최초 발견**: WU-22 (`a66cf2e` · session: epic-brave-galileo, 20번째 세션). 19번째 eager-elegant-bell 가 사용자 β 결정 수신 후 56분 hang → 20번째가 takeover 로 close 처리.
- **재발견 / 재사용**:
  - WU-23 (21번째 trusting-stoic-archimedes, **P-04 learning pattern 실체화 시점**). 21번째 본인은 hang 아님, 그러나 user-active-deferred 모드 (4시간 자율 작업) 에서 takeover 보호 비활성화 명시 — P-04 의 변종 정의 시점.

## Notes

- **OSS 미공개**: 사용자 codename + 세션 흐름 + 의사 결정 지연 사실은 raw-internal.
- **상위 규율**: §1.12 (mutex protocol) + §1.8 (작업 유실 최소화) + §1.7 (escalation).
- **관련 패턴**: P-03 (commit 전 종료) 와 다름 — P-03 은 staged 상태로 종료, P-04 는 mutex active 상태로 hang. 진척 검출 방식 차이 (staged diff vs commit/PROGRESS heartbeat).
- **변종**: 21번째 세션의 user-active-deferred 모드 = 사용자 부재 4시간 자율 위임 + takeover 보호 비활성화. 이건 P-04 의 inverse — "사용자가 명시적으로 hang 보호 풀어둔 케이스". 이것도 §1.12 mode 필드로 명시.
- **자동 감지 후속 작업 후보**: `scripts/resume-session-check.sh` 에 check #N (hang detector — last commit 시각 vs current_wu_owner.claimed_at + last_heartbeat 비교) 추가 가능. 0.4.0-mvp 후보.
