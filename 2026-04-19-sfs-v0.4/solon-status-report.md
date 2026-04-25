---
doc_id: solon-status-report-spec
title: "Solon Session Status Report — v0.6.3 spec (CLAUDE.md ≤200 lines 메타 규칙 §1.14 정합으로 분리)"
version: 0.6.3
created: 2026-04-21   # CLAUDE.md §14 신설 시점
extracted: 2026-04-25  # 22nd 세션이 CLAUDE.md 에서 분리
extraction_reason: "CLAUDE.md ≤200 lines 메타 규칙 (§1.14, 22nd 사용자 결정) 충족을 위한 분리. 의미 변경 0, line-by-line 이동만."
visibility: raw-internal
ssot_pointer: "본 파일이 Solon Status Report 의 SSoT. CLAUDE.md §14 는 link 1줄로 대체."
related_docs:
  - "CLAUDE.md §1.14 (≤200 lines 메타 규칙)"
  - "CLAUDE.md §1.10 (Status Report 렌더링 규칙 — triple-backtick code fence 필수)"
  - "CLAUDE.md §1.2 (bkit Feature Usage Report 미출력 + Solon Session Status Report 출력)"
---

# Solon Session Status Report (v0.6.3, 확정 — WU 완료 dashboard)

> **role**: WU dashboard — WU 전환 시 1회 출력되는 1줄 summary dashboard. 상세 drill-down 은 기존 3 체계에 위임:
> - **PDCA Check** (전체 Plan↔Do gap analysis) — 본 spec 과 보완 관계
> - **cross-ref-audit §4** (W10 TODO SSoT) — ⚠️ Escalation 은 TODO 포인터
> - **sessions/ 3-part 로그** (squashed WU + 대화 요약 + decision log) — 본 spec 은 live, sessions 는 히스토리
>
> **대체 목적**: bkit Feature Usage Report 대신 Solon WU 완료 증적 + 상태 summary.
> **Visibility**: `raw-internal` (사용자 개인 세션 전용).

---

## 1. 출력 빈도 (확정)

- **WU 전환 시에만** — WU 완료 commit 직후 또는 다음 WU 착수 직전.
- 매 응답 말미·micro-step 완료 시 출력 **금지** (토큰 낭비).
- 세션 자연 종결점·사용자 명시 요청 시 수시 출력 허용.

---

## 2. 포맷 (v0.6.3 — topic별 1-line summary)

> 🚨 **렌더링 규칙 (필수, CLAUDE.md §1.10 정합)**: 리포트는 **반드시 triple-backtick code fence 안에 출력**. Plain text 출력 시 markdown 이 줄바꿈 삭제 → 한 줄 벽 텍스트로 붕괴됨.

> 📐 **Topic별 1-line 규칙 (v0.6.3)**: 각 zone/topic 은 **1 줄 summary** 로 끝낸다. `<N 건> — <핵심 1줄 요약>` 패턴. 상세는 WU 파일·sessions/·learning-logs/ 등 해당 소스에 위임. Status Report 는 **dashboard 용도 only**.

> ⚠️ **Wrap column**: 한글 혼용 60 cell · ASCII 70 cell 이내 유지. 초과 시 auto-wrap 으로 indent 깨짐 → 요약 더 축약.

> **설계 원칙**: 5 zone · 각 topic 1 줄 · heavy divider (`━━`) 리포트 경계 · light divider (`───`) zone 구분. 값 없는 topic 은 `0 건 — 없음`.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 SOLON STATUS — WU 완료 리포트
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 WU     <id> · <title>                    [<status>]
⏱️ Time   <opened> → <closed>  (<duration>)
───────────────────────────────────────────────────
🔧 Steps   <N>건 — <핵심 주제 1줄>
📁 Files   <N>개 — <핵심 파일/주제 1줄>
💾 Commits <N>건 — <sha 또는 "없음 (사유)">
📊 Health  ahead <a>·대기 <p> | PROG <HH:MM> <✓/⚠> | Snap <−/HH:MM> | 원칙2 <○/△/×> | <tier>
───────────────────────────────────────────────────
⚠️ Escalation <N>건 — <1줄 요약 또는 "없음">
📚 Learning   <N>건 — <1줄 요약 또는 "없음">
───────────────────────────────────────────────────
⏭️ Next  <다음 WU/action 1줄>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 3. 범례

- **Zone ① Identity**: 🎯 WU id/title/status + ⏱️ opened→closed + duration (2 줄).
- **Zone ② Work evidence**: 🔧 Steps · 📁 Files · 💾 Commits 각 1 줄 summary (3 줄 총). label 뒤 공백으로 col 정렬.
- **Zone ③ Health**: `|` 가로 bar 1 줄 — ahead/대기 + PROG + Snap + 원칙2 + tier.
- **Zone ④ Alerts**: ⚠️ Escalation · 📚 Learning 각 1 줄.
- **Zone ⑤ Next**: 1 줄.
- **총 라인 수**: divider 포함 ~13 줄 dashboard. 상세 drill-down 은 원본 문서로.

---

## 4. 변경 이력

- **v0.6.3** (2026-04-21, CLAUDE.md §14 신설 시점) — topic별 1-line 규칙 확정.
- **분리 이전 sub-versions** (0.1 ~ 0.6.2) — CLAUDE.md §14 inline 시절의 draft 진화. 분리 후 본 파일에서 후속 버전 관리.
- **0.6.3 (분리)** (2026-04-25, 22nd 세션 `adoring-trusting-feynman`) — CLAUDE.md §1.14 메타 규칙 충족을 위한 line-by-line 이동. 의미 변경 0.

## 5. 후속 TODO

- 사용자 명시 요청 시 v0.7 — Status Report 자동 생성 helper script (`scripts/render-solon-status.sh`) 검토.
- W10 TODO 19항목 정합 시 ⚠️ Escalation zone 의 `<1줄 요약>` 자동 매핑.
