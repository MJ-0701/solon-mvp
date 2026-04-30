---
phase: do
sprint_id: ""    # filled by /sfs start
goal: ""         # filled by /sfs start <goal>
created_at: ""   # filled by /sfs start
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

### YYYY-MM-DDTHH:MM:SS+09:00 — sprint kickoff

- `/sfs start` 로 본 sprint dir 생성
- Plan 단계 진입 — `plan.md` 의 R/AC 채우기
- 다음: G1 review 통과 후 Do 진입

## §2. 발견된 결정 / 블로커 (decision log 후보)

- 결정 갈림길 발견 시 `.sfs-local/decisions/<topic>.md` 로 mini-ADR 분리.
- 차단 요소 (외부 답변 대기, 리소스 부족 등) 는 본 섹션에 기록 후 `review.md` 에서 verdict 로 반영.

## §3. 다음 단계 / 핸드오프 메모

- G3 Pre-Handoff Gate 통과를 위한 산출물 목록 정리.
- 인계받을 사람이 추가 컨텍스트 없이 진행 가능한 상태 점검.
