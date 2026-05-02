---
doc_id: gates-enum-spec
title: "Solon Gate number reference (Solon report 표기 + sfs CLI 참조용)"
version: 1.2
created: 2026-04-25
created_session: adoring-trusting-feynman   # 22nd 세션
created_in_wu: WU-22nd-step4   # 8 step batch step 4
ssot_pointer: "Gate 정의 SSoT = 05-gate-framework.md (§5.1 Gate 매트릭스 + §5.11 Intake + §5.12 Release Readiness). 본 파일은 Solon report 사용자 표기 + sfs CLI 참조용 컴팩트 enum + WU-23 §1.4 draft 정정 기록."
related_docs:
  - "05-gate-framework.md §5.1 Gate 매트릭스 (Gate 1~7 + RELEASE)"
  - "02-design-principles.md §2.9 Gate 2 Brainstorm (legacy title: G0 Brainstorm Gate)"
  - "04-pdca-redef.md §4.2.2 Gate 2 Brainstorm (legacy title: Brainstorm Gate (G0))"
  - "appendix/schemas/l1-log-event.schema.yaml (gate_id field)"
  - "PHASE1-KICKOFF-CHECKLIST.md L215 (실 L1 log entry 예시)"
  - "sprints/WU-23.md §1.4 (sfs review --gate <1..7> 정정 대상)"
visibility: business-only
purpose: "WU-23 §7.1 (block) 사용자 결정 1번 (c) 별도 spec 파일 신설 — `/sfs review --gate <1..7>` 의 valid enum 을 1곳에서 정의하고, 05-gate-framework.md SSoT 와 정합 유지."
---

# Solon Gate number reference (sfs CLI 참조용)

> ⚠️ **SSoT 분리**: 본 파일은 enum 만 모은 컴팩트 reference. **gate 의 의미 / Evaluator 매핑 / verdict 의미 / Failure Mode** 등 모든 상세는 `05-gate-framework.md` 가 SSoT. 본 파일에서 의미 기술 변경 시 `05-gate-framework.md` 를 먼저 갱신하고 본 파일 sync.

---

## §1. Gate enum

사용자에게 보이는 Solon report / 안내 문구 / 새 CLI 예시는 `Gate 1..7` 숫자를 사용한다.
기존 `gate_id` 값은 오래된 파일 frontmatter 와 `.sfs-local/events.jsonl` 호환을 위한 내부 필드로만 유지한다.

| display label | number | legacy storage id | 위치 | 1줄 목적 | 적용 모드 | SSoT 본문 |
|:---:|:---:|:---:|------|---------|:---:|-----------|
| **Gate 1 (Intake)** | **1** | G-1 | install.sh `--mode brownfield` 후 P-1 종료점 | Intake — discovery-report 완성도 + 사람 최종 서명 | brownfield only | 05 §5.11 |
| **Gate 2 (Brainstorm)** | **2** | G0 | Initiative 진입점 | Brainstorm Gate — 문제 정의 + scope 합의 | 공통 | 02 §2.9, 04 §4.2.2 |
| **Gate 3 (Plan)** | **3** | G1 | Plan 문서 완료 시 | Plan Gate — 요구사항·AC 측정 가능성 | 공통 | 05 §5.1 |
| **Gate 4 (Design)** | **4** | G2 | Design 문서 완료 시 | Design Gate — 설계 완성도 | 공통 | 05 §5.1 |
| **Gate 5 (Handoff)** | **5** | G3 | Do 완료 직전 | Pre-Handoff Gate — 산출물 핸드오프 가능성 (binary) | 공통 | 05 §5.1.2 |
| **Gate 6 (Review)** | **6** | G4 | Do 완료 후 | Check Gate — 실제 vs 설계 gap (정량+정성, 5-Axis CPO) | 공통 | 05 §5.1, §5.5, §5.6 |
| **Release Readiness** | n/a | RELEASE | Gate 6 이후, production deploy 직전 | Release Readiness — secret/auth/data/monitoring/rollback/cost 준비성 | production open 시 | 05 §5.12 |
| **Gate 7 (Retro)** | **7** | G5 | Sprint 종료 시 | Sprint Retro — 학습 루프 (정성, N PDCA 집계) | 공통 | 05 §5.1.3 |

**총 8 gate vocabulary**. greenfield 모드는 Gate 1 skip (`2 → 3 → 4 → 5 → 6 → [RELEASE] → 7`). brownfield 모드는 Gate 1 시작 (`1 → 2 or 3 → 3 → 4 → 5 → 6 → [RELEASE] → 7`). `RELEASE` 는 production open 을 수반할 때만 적용한다.

---

## §2. Verdict enum (3-value, 공통)

```
verdict ∈ { pass, partial, fail }
```

근거: `02-design-principles.md` (Gate 2 routing) + `03-c-level-matrix.md:432` + `appendix/templates/brainstorm.md:102`. 05 §5.4.1 의 `verdict vs pass` 관계 (audit 블록 의미) 는 SSoT 본문 참조.

⚠️ Gate 5 만 binary (pass / fail) — partial 미사용 (05 §5.1.2). 기타 gate 는 3-value 전부 가능.

---

## §3. sfs CLI 매핑 (`/sfs review --gate <1..7>`)

WU-25 (#1 sfs slash command 구현 part 2) 이후 다음과 같이 enforce:

```sh
# valid gate number
1 | 2 | 3 | 4 | 5 | 6 | 7

# invalid → exit 6, stderr:
"unknown gate <id>, valid: 1 (Gate 1 Intake), 2 (Gate 2 Brainstorm), 3 (Gate 3 Plan), 4 (Gate 4 Design), 5 (Gate 5 Handoff), 6 (Gate 6 Review), 7 (Gate 7 Retro)"
```

`/sfs review --gate <1..7>` 의 현재 구현 contract 는 7개 숫자를 표준으로 허용한다. 하위 호환을 위해 오래된 storage id 입력도 normalize 한다. `RELEASE` 는 v0.4-r4에서 schema와 §5 vocabulary 에 먼저 추가됐고, command surface (`/sfs check --release-readiness` vs `/sfs release`) 는 미결이다. L1 event payload 의 `gate_id` 필드는 `RELEASE` 도 허용한다 (`appendix/schemas/l1-log-event.schema.yaml`).

---

## §4. WU-23 §1.4 draft 정정 기록 (22nd 세션 결정)

WU-23 §1.4 (`/sfs review` minimal contract spec) 1차 draft 의 stderr 메시지:

```
"unknown gate <id>, valid: 1/2/3/4/5/6/7"
```

**불일치 사항** (docset SSoT 와 차이):
- ❌ Gate 1 (Intake, brownfield) 누락
- ❌ Gate 5 (Handoff) 누락
- ❌ Gate 7 (Retro) 누락

**정정** (22nd 세션 사용자 결정 1번 (c) + 본 §3 enum 기준):
- ✅ valid = `1, 2, 3, 4, 5, 6, 7` (7 gate 전체)
- ✅ 구현 시 본 §3 형식 stderr 사용
- ✅ WU-23 §1.4 의 `⚠️ pending product decisions` 항목 중 "gate number schema 정의 위치" 는 본 파일 신설로 resolved

---

## §5. 변경 이력

- **v1.0** (2026-04-25, 22nd 세션 `adoring-trusting-feynman`) — 신설. SSoT pointer 명시 + 7-gate enum + verdict enum + sfs CLI 매핑 + WU-23 §1.4 정정 기록.
- **v1.2** (2026-05-02) — 사용자 표기 우선순위 정리. Solon report 와 새 CLI 예시는 `Gate 1..7` 숫자를 사용하고, 기존 storage id 는 호환용으로만 유지.
- 향후 변경: `05-gate-framework.md` 변경 시 §1 표 sync 필수.
