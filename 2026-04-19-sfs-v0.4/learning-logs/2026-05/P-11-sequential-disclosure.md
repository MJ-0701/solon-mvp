---
pattern_id: P-11
title: sequential-disclosure
status: documented
severity: medium
first_observed: 2026-04-29
observed_by: 사용자 비판 — 26th-1 admiring-compassionate-euler (Cowork user-active-deferred Cowork conversation)
resolved_at: 2026-04-29
resolved_by: admiring-compassionate-euler + 사용자 명시 등재 결정
resolved_via:
  - "[1] CLAUDE.md §1.20 신설 — 정상 흐름 (다음 1 step 만) / 문제 발견 흐름 (즉시 stop + 그 문제만) / 옵션 분기 (결정 갈림길에서만) 3 case 명시."
  - "[2] CLAUDE.md version 1.19 → 1.20 bump."
  - "[3] cross-ref-audit.md §4 W-26 resolved entry append."
  - "[4] 본 P-11 신설 (worked example 3건 = bad case 2 + good case 1)."
related_rule: CLAUDE.md §1.20 (단계적 안내 원칙, Sequential Disclosure)
related_docs:
  - 2026-04-19-sfs-v0.4/CLAUDE.md §1.20 (Spec SSoT)
  - 2026-04-19-sfs-v0.4/CLAUDE.md §1.17 (7-step 브리핑 prose, 본 §1.20 의 cousin)
  - 2026-04-19-sfs-v0.4/cross-ref-audit.md §4 W-26 (resolved entry)
visibility: business-only
applicability:
  - "AI 가 사용자에게 절차 / 진단 / 옵션 송출 시 적용"
  - "특히 '진단 → 결과 → 옵션 → 다음 단계' 같은 multi-step UX 영역"
  - "review gate 미적용 영역 (작은 작업 / dialogue 위주 영역) 에 §1.17 7-step 보다 lightweight 운영 가능"
reuse_count: 0   # 본 신설 자체가 dogfooding 첫 case, 적용 검증은 27th 사이클부터
---

# P-11 — 단계적 안내 원칙 (Sequential Disclosure)

## 1. 사용자 verbatim 비판 (26th-1 admiring-compassionate-euler)

> "진단도 단계가 여러개인데, 하나에서 문제가 발견되면 그걸 수정을 먼저 해야되는데 이때는 단계적으로 하나씩 절차대로 진행해야되는데 지금 쓸데없이 옵션이나 다음단계가 같이 튀어나옴 필요한 부분만 → 정상흐름일땐 다음단계 안내까지만"

→ 핵심 = **AI 가 사용자에게 절차 안내 시 한 단계 끝낼 때마다 결과 보고 + 다음 1 step 만 안내**. 다다음 step / 옵션 분기 / 후속 plan 미리 던지기 금지.

## 2. 3 case 명세 (CLAUDE.md §1.20 verbatim)

### Case 1 — 정상 흐름

진단 또는 작업 1 step 후 **다음 1 step 만** 안내.
- 다다음 step / 옵션 분기 / 후속 plan **송출 금지** (다음 step 끝난 후 분리 송출).

### Case 2 — 문제 발견 흐름

진단 중 문제 발견 시 **즉시 stop + 그 문제만 안내 + 사용자 결정 또는 fix**.
- 다른 단계 송출 금지.
- 문제 해소 후에야 다음 단계 진입.

### Case 3 — 옵션 분기

결정 갈림길에서만 송출.
- 단순 정상 흐름에선 옵션 던지기 금지 (사용자 결정 부담 누적 방지).

## 3. Worked Examples (26th-1 dogfooding 데이터)

### Bad case 1 — sub-task 6.8 진입 시 batch dump

**상황**: ε WU-27 sub-task 6.8 buffer 자율진행 사용자 승인 직후, AI 가 mutex claim → sub-task 6.8.1 audit 진행.

**잘못된 송출 패턴**: audit 결과 (LLM 호출 / race window / FSM ABANDONED 3 site finding) + 옵션 (A 즉시 / B β default / C abort / D mid-ground) + 다음 단계 (6.8.2 ~ 6.8.6 plan 전체) 한꺼번에 1 응답에 dump.

**사용자 비판** (1차): D′ 결정 송출. 단 옵션 / 다다음 단계 batch 부담 누적.

**올바른 패턴**: audit 결과 보고 + decision_point 발견 1건만 결정 요청 (escalation briefing) → 사용자 결정 후 다음 단계 (6.8.2) 진입 + 보고 → 6.8.3 진입 ...

### Bad case 2 — stable repo 14 file 발견 시 batch dump

**상황**: stable sync 1 file (sfs-common.sh) 의도였는데 git status 결과 14 file modified.

**잘못된 송출 패턴**: 진단 + 가능성 (A/B/C 3 cases) + 옵션 (A/B/C/D 4 options) + 다음 단계 (release cut α/β 분기) 한꺼번에 1 응답에 dump.

**사용자 비판** (2차, verbatim): "진단도 단계가 여러개인데, 하나에서 문제가 발견되면 그걸 수정을 먼저 해야되는데..."

**올바른 패턴**: 진단 결과 보고 (14 file 분석) → 사용자가 원인 이해 → β default 1 option 만 권장 → 사용자 진행 후 → 다음 단계 (release cut) 별도 송출.

### Good case 1 — 26th-1 종결 시점 작업 1 등재

**상황**: 사용자 비판 후 즉시 §1.20 등재 micro-cycle.

**올바른 패턴** (본 cycle 적용): 작업 1 (CLAUDE.md §1.20 + cross-ref + P-11 신설) 만 진행. 작업 2 (release cut) + 작업 3 (stable 13 file 처리) 은 작업 1 끝난 후 결과 보고 → 사용자 다음 작업 진입 결정 후 별도 진행.

→ §1.20 신설 자체가 §1.20 적용 첫 case (self-application).

## 4. 검증 / Anti-pattern 진단 신호

다음 패턴 발견 시 §1.20 위반 의심:

- 1 응답 안에 "진단 + 옵션 + 다음 단계" 3 종 모두 등장.
- "추천: X. 또는 Y / Z 옵션 가능" + 즉시 다음 단계 명령 송출.
- 사용자가 결정 안 한 분기 영역의 후속 plan 미리 송출.
- 옵션 list 4개 이상 (실제 결정 갈림길보다 많을 가능성, 부담 누적).

## 5. §1.17 (7-step briefing) 와의 관계

- §1.17 = **결정 요청 시점** 의 의무 형식 (질문 / 배경 / 현재 상태 / 옵션 / 추천 / 미결정 시 영향 / 답변 형식, prose 7 단계). 큰 결정 framework / architecture 시 +3 단계 추가 (4.5 prior art / 5.5 fact 출처 / 6.5 cascade).
- §1.20 = **절차 안내 시점** 의 단계적 송출 원칙. 결정 갈림길 아닌 routine 절차 영역 (진단 → 보고 → 다음 step) 에 적용.
- 두 규율 차이 = §1.17 은 "사용자 결정 요청" 영역 / §1.20 은 "AI 절차 진행 + 보고" 영역.
- 둘 다 적용 = "decision required + multi-step procedure" 복합 case (예: review gate 진입 시 §1.17 + §1.20 동시 적용).

## 6. 후속 dogfooding 권장

- 27th 사이클 진입 시 본 §1.20 자동 적용 검증 — 진단 / 옵션 / 다음 단계 batch dump 패턴이 줄어드는지 측정.
- reuse_count 갱신: 적용 사례 N건 누적 시 본 frontmatter `reuse_count` += 1.
- 위반 사례 발견 시 본 P-11 §3 worked examples 에 bad case 추가.

## 7. 관련

- CLAUDE.md §1.20 (Spec SSoT)
- CLAUDE.md §1.17 (cousin = 결정 브리핑 prose 7 단계)
- cross-ref-audit.md §4 W-26 (resolved entry)
