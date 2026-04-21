---
doc_id: sessions-index
title: "sessions/ — 세션별 3-part 로그 인덱스"
visibility: raw-internal
updated: 2026-04-21
---

# sessions/ — 세션 로그 인덱스

> **역할**: 세션 단위 히스토리 (3-part: squashed WU 목록 + 대화 요약 + decision log).
> **v1 대비 차이**: 기존 `WORK-LOG.md` 의 append 방식 대신, **세션 단위 독립 파일**로 분리. WORK-LOG 는 index 용도로 보존 (§4 9번).
> **파일명**: `<YYYY-MM-DD>-<session-codename>.md` (Cowork 세션 코드네임 기반).

---

## 세션 목록

| Date | Session codename | WU 진행 | 파일 |
|:---|:---|:---|:---|
| 2026-04-19 | (자연어 codename 없음 — 1~2번째 세션) | WU-1 ~ WU-6 시도, BLOCKED WU-6 발생 | 이관 대기 (WU-16) |
| 2026-04-20 | `funny-compassionate-wright` | WU-7 / WU-7.1 / 이관 (회사→개인 계정) | 이관 대기 (WU-16) |
| 2026-04-21 | `serene-fervent-wozniak` | WU-14 / WU-14.1 / WU-10 / WU-10.1 + CLAUDE.md 신설 + v2 design | 이관 대기 (WU-16) |
| 2026-04-21 | `relaxed-vibrant-albattani` | WU-15 진행 중 (본 세션) | `2026-04-21-relaxed-vibrant-albattani.md` (WU-15 완료 시 생성) |

---

## 3-part 구조 (각 세션 파일)

1. **Squashed WU 목록** — 세션 중 완료된 WU 들 (final_sha + title + line 수)
2. **대화 요약** — 주요 discussion points + option β/γ 선택 이력 + 토큰/compact 이벤트
3. **Decision log** — 이번 세션에서 확정된 결정 (W10 TODO 이관 건 포함)

## Backfill 우선순위 (WU-16 대상)

- 과거 3 세션 retrospective 를 **메모리 + WORK-LOG.md + cross-ref-audit §4** 기반으로 재구성.
- 대화 요약은 재구성 불가 항목 존재 (transcript 부재 구간) — `[재구성 한계: <구체적 사유>]` 명시.
