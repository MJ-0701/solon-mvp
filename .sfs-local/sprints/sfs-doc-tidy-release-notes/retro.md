---
phase: retro
gate_id: G5
sprint_id: "sfs-doc-tidy-release-notes"
goal: "SFS doc tidy command + update awareness + release notes policy"
created_at: "2026-05-01T18:27:08+09:00"
last_touched_at: ""  # filled by /sfs retro
closed_at: ""        # filled by /sfs retro --close
---

# Retro — <sprint title>

> Sprint **G5 — Sprint Retro** 산출물. 학습 루프 (정성, N PDCA 집계).
> `/sfs retro --close` 로 본 sprint 의 `closed_at` 을 frontmatter 에 기록 + `.sfs-local/events.jsonl` 의 `sprint_close` event append.
> SSoT: `gates.md §1` (G5) + `05-gate-framework.md §5.1.3` (Sprint Retro).
> 생명주기: `retro.md` 는 history/learning 을 보존하는 문서다. 실제 작업 결과는 close 전
> `report.md` 로 정리하고, workbench/tmp 산출물 원문은 archive 로 이동해 보존한다.

---

## §1. KPT (Keep / Problem / Try)

### Keep — 잘 된 것 (계속)

- …

### Problem — 안 된 것 / 막힌 것

- …

### Try — 다음 sprint 시도

- …

## §2. PDCA 학습

- **Plan**: 의도와 결과 간 차이가 컸던 항목
- **Do**: CTO 구현 중 발견된 실무 패턴 (`learning-logs/` 후보 P-…)
- **Check**: CPO review verdict / G4 partial 항목과 retro 시점에서의 후속 plan
- **Act**: 본 sprint 학습을 다음 sprint plan / convention 문서에 어떻게 반영할지

## §3. 정량 메트릭 (선택)

- 계획 대비 실제 시간 (estimate vs actual)
- AC 통과율 (G4 verdict 분포)
- ahead 변화량 (sprint 시작 ↔ 종료)

## §4. 다음 sprint 인계

- **이어가는 항목**: …
- **분기되는 WU/sprint**: …
- **결정 대기 (W10 후보)**: …

## §5. G5 close 체크

- [ ] events.jsonl 마지막 entry = `gate_review G5:<verdict>`
- [ ] `closed_at` frontmatter 기록 (`/sfs retro --close` 가 자동 채움)
- [ ] HANDOFF / sessions log 에 본 sprint 결과 link 1줄 추가
