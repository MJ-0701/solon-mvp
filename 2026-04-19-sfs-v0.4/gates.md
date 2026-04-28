---
doc_id: gates-enum-spec
title: "Solon Gate enum reference (sfs CLI 참조용 + WU-23 §1.4 정정 기록)"
version: 1.1
created: 2026-04-25
created_session: adoring-trusting-feynman   # 22nd 세션
created_in_wu: WU-22nd-step4   # 8 step batch step 4
ssot_pointer: "Gate 정의 SSoT = 05-gate-framework.md (§5.1 Gate 매트릭스 + §5.11 G-1 Intake + §5.12 Release Readiness). 본 파일은 sfs CLI 참조용 컴팩트 enum + WU-23 §1.4 draft 정정 기록만."
related_docs:
  - "05-gate-framework.md §5.1 Gate 매트릭스 (G-1 + G0 + G1~G5 + RELEASE)"
  - "02-design-principles.md §2.9 G0 Brainstorm Gate"
  - "04-pdca-redef.md §4.2.2 Brainstorm Gate (G0)"
  - "appendix/schemas/l1-log-event.schema.yaml (gate_id field)"
  - "PHASE1-KICKOFF-CHECKLIST.md L215 (실 L1 log entry 예시)"
  - "sprints/WU-23.md §1.4 (sfs review --gate <id> 정정 대상)"
visibility: business-only
purpose: "WU-23 §7.1 (block) 사용자 결정 1번 (c) 별도 spec 파일 신설 — `/sfs review --gate <id>` 의 valid enum 을 1곳에서 정의하고, 05-gate-framework.md SSoT 와 정합 유지."
---

# Solon Gate enum (sfs CLI 참조용)

> ⚠️ **SSoT 분리**: 본 파일은 enum 만 모은 컴팩트 reference. **gate 의 의미 / Evaluator 매핑 / verdict 의미 / Failure Mode** 등 모든 상세는 `05-gate-framework.md` 가 SSoT. 본 파일에서 의미 기술 변경 시 `05-gate-framework.md` 를 먼저 갱신하고 본 파일 sync.

---

## §1. Gate enum

| gate_id | 위치 | 1줄 목적 | 적용 모드 | SSoT 본문 |
|:-------:|------|---------|:---:|-----------|
| **G-1** | install.sh `--mode brownfield` 후 P-1 종료점 | Intake — discovery-report 완성도 + 사람 최종 서명 | brownfield only | 05 §5.11 |
| **G0**  | Initiative 진입점 | Brainstorm Gate — 문제 정의 + scope 합의 | 공통 | 02 §2.9, 04 §4.2.2 |
| **G1**  | Plan 문서 완료 시 | Plan Gate — 요구사항·AC 측정 가능성 | 공통 | 05 §5.1 |
| **G2**  | Design 문서 완료 시 | Design Gate — 설계 완성도 | 공통 | 05 §5.1 |
| **G3**  | Do 완료 직전 | Pre-Handoff Gate — 산출물 핸드오프 가능성 (binary) | 공통 | 05 §5.1.2 |
| **G4**  | Do 완료 후 | Check Gate — 실제 vs 설계 gap (정량+정성, 5-Axis CPO) | 공통 | 05 §5.1, §5.5, §5.6 |
| **RELEASE** | G4 이후, production deploy 직전 | Release Readiness — secret/auth/data/monitoring/rollback/cost 준비성 | production open 시 | 05 §5.12 |
| **G5**  | Sprint 종료 시 | Sprint Retro — 학습 루프 (정성, N PDCA 집계) | 공통 | 05 §5.1.3 |

**총 8 gate vocabulary**. greenfield 모드는 G-1 skip (`G0 → G1 → G2 → G3 → G4 → [RELEASE] → G5`). brownfield 모드는 G-1 시작 (`G-1 → G0 or G1 → G1 → G2 → G3 → G4 → [RELEASE] → G5`). `RELEASE` 는 production open 을 수반할 때만 적용한다.

---

## §2. Verdict enum (3-value, 공통)

```
verdict ∈ { pass, partial, fail }
```

근거: `02-design-principles.md` (G0 routing) + `03-c-level-matrix.md:432` + `appendix/templates/brainstorm.md:102`. 05 §5.4.1 의 `verdict vs pass` 관계 (audit 블록 의미) 는 SSoT 본문 참조.

⚠️ G3 만 binary (pass / fail) — partial 미사용 (05 §5.1.2). 기타 gate 는 3-value 전부 가능.

---

## §3. sfs CLI 매핑 (`/sfs review --gate <id>`)

WU-25 (#1 sfs slash command 구현 part 2) 이후 다음과 같이 enforce:

```sh
# valid gate_id (case-sensitive, hyphen 포함)
G-1 | G0 | G1 | G2 | G3 | G4 | G5

# invalid → exit 6, stderr:
"unknown gate <id>, valid: G-1, G0, G1, G2, G3, G4, G5"
```

`/sfs review --gate <id>` 의 현재 구현 contract 는 WU-25 기준 7개만 허용한다. `RELEASE` 는 v0.4-r4에서 schema와 §5 vocabulary 에 먼저 추가됐고, command surface (`/sfs check --release-readiness` vs `/sfs release`) 는 미결이다. L1 event payload 의 `gate_id` 필드는 `RELEASE` 도 허용한다 (`appendix/schemas/l1-log-event.schema.yaml`).

---

## §4. WU-23 §1.4 draft 정정 기록 (22nd 세션 결정)

WU-23 §1.4 (`/sfs review` minimal contract spec) 1차 draft 의 stderr 메시지:

```
"unknown gate <id>, valid: G0/G1/G2/G4"
```

**불일치 사항** (docset SSoT 와 차이):
- ❌ G-1 (Intake, brownfield) 누락
- ❌ G3 (Pre-Handoff) 누락
- ❌ G5 (Sprint Retro) 누락

**정정** (22nd 세션 사용자 결정 1번 (c) + 본 §3 enum 기준):
- ✅ valid = `G-1, G0, G1, G2, G3, G4, G5` (7 gate 전체)
- ✅ WU-25 구현 시 본 §3 형식 stderr 사용
- ✅ WU-23 §1.4 의 `⚠️ pending product decisions` 항목 중 "gate id schema 정의 위치" 는 본 파일 신설로 resolved

---

## §5. 변경 이력

- **v1.0** (2026-04-25, 22nd 세션 `adoring-trusting-feynman`) — 신설. SSoT pointer 명시 + 7-gate enum + verdict enum + sfs CLI 매핑 + WU-23 §1.4 정정 기록.
- 향후 변경: `05-gate-framework.md` 변경 시 §1 표 sync 필수.
