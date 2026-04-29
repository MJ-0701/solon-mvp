---
doc_id: cross-ref-audit-solon-v0.4-r3-2026-04-20
title: "Cross-Reference Audit — CROSS-ACCOUNT-MIGRATION.md §1.5 결과"
version: 1.0
created: 2026-04-20
author: "Claude (direct 지시 by 채명정)"
purpose: "이관 전 docset cross-reference 정합성 전수 검증 결과 + fabrication 방지 후처리 기록."
applies_to: "Solon v0.4-r3 이관 준비"
status: "MIG-5 (Task #7) 완료 직전 최종 stamp."
related_docs:
  - "CROSS-ACCOUNT-MIGRATION.md §1.5 cross-reference 정합성 검증"
  - "MIGRATION-NOTES.md §4 fabrication 경보"
  - "HANDOFF-next-session.md §7 파일 Inventory"
  - "INDEX.md §5 의존성 그래프 + §4 Cross-Reference Matrix"
---

# Cross-Reference Audit

> **결론**: Round 3 작업에서 발견된 fabrication 패턴 **7건** 전수 정리 완료. INDEX.md + README.md 에 `🚧 Phase 1` 또는 `❌ Phase 1 구현 시 작성` 마커로 통일. 추가로 v0.4-r2 시점 설계에 포함된 4건의 "Phase 1 생성 예정" 파일도 INDEX.md §5 하단 pending 테이블에 모두 편입.

---

## 1. 검증 방법

### 1.1 수행한 Grep 패턴

| # | 패턴 | 목적 |
|:-:|------|------|
| 1 | `dialog-engine\.md\|dialogs/README\.md` | R3 에서 신설 선언된 dialog 파일 실재 확인 |
| 2 | `12대 원칙\|13대 원칙` | 원칙 수 숫자 정합성 (v0.4-r3 는 13대) |
| 3 | `concept/division-activation-state` | R3 핵심 concept 정의/참조 연결 |
| 4 | `원칙\s*7\|principle/cli-gui-unified-backend` | 원칙 7 fabrication 잔재 흔적 |
| 5 | `\[appendix/[^)]+\.(md\|yaml\|ts)\]` | Markdown 링크로 걸린 모든 appendix 파일 샘플 |
| 6 | `g-1-signature\.schema\.yaml\|discovery-report\.schema\.yaml` | Phase 1 pending schema 실재 여부 |
| 7 | `existing-implementation\.schema\.yaml\|discovery-report\.(md\|template\.md)` | P-1 Discovery 관련 보조 artifact 실재 여부 |

### 1.2 수행한 실물 파일 검증 (ls)

- `appendix/commands/` — 14 files (모두 존재) ✅
- `appendix/dialogs/` — `division-activation.dialog.yaml` + `branches/` + `traces/` ✅, README.md + phase-a~e.md ❌
- `appendix/engines/` — `alternative-suggestion-engine.md` ✅, `dialog-engine.md` ❌
- `appendix/schemas/` — 5 files (dialog-state / divisions / escalation / gate-report / l1-log-event) ✅, discovery-report / existing-implementation / g-1-signature ❌
- `appendix/templates/` — 5 files (analysis / brainstorm / design / plan / report) ✅, discovery-report.template.md ❌
- `appendix/drivers/` — 3 files (_INTERFACE + notion + none) ✅
- `appendix/hooks/` — 1 file (observability-sync.sample.ts) ✅
- `appendix/tooling/` — 1 file (sfs-doc-validate.md) ✅
- `appendix/samples/` — 1 file (plugin.json.sample) ✅ **WU-7 추가 (2026-04-20)** — 07 §7.2 inline JSON 블록을 재사용 가능한 seed 매니페스트로 분리. Phase 1 W13 Plugin Packaging 시 진입점.

---

## 2. 발견된 Fabrication / Forward-reference 11건 전수 정리

### 2.1 R3 신설 선언된 파일 중 실재하지 않는 것 (7건)

R3 Task #26 에서 INDEX.md / README.md 작성 시 **실물 생성 없이 링크만 먼저 걸린** 파일들.

| # | 파일 경로 | 선언된 곳 | 실재 | 조치 |
|:-:|-----------|-----------|:-:|------|
| 1 | `appendix/dialogs/README.md` | INDEX.md §5 Dialogs / §3.8 reader path / §4 cross-ref (3+회) / README.md §5 tree | ❌ | 🚧 Phase 1 W1~W2 마커 + link 제거 |
| 2 | `appendix/dialogs/phase-a-context.md` | INDEX.md §5 / README.md §5 | ❌ | 🚧 Phase 1 W1~W2 마커 |
| 3 | `appendix/dialogs/phase-b-why-now.md` | 동상 | ❌ | 🚧 Phase 1 W1~W2 |
| 4 | `appendix/dialogs/phase-c-clarify.md` | 동상 | ❌ | 🚧 Phase 1 W1~W2 |
| 5 | `appendix/dialogs/phase-d-option-card.md` | 동상 (+ §4 cross-ref 6회) | ❌ | 🚧 Phase 1 W1~W2 |
| 6 | `appendix/dialogs/phase-e-terminal.md` | 동상 | ❌ | 🚧 Phase 1 W1~W2 |
| 7 | `appendix/engines/dialog-engine.md` | INDEX.md §5 Engines / §3.8 / §4 cross-ref (4회) / README.md §5 tree | ❌ | 🚧 Phase 1 W1~W2 마커 + link 제거 |

> 🔑 **R3 에서 실재하는 대체 artifact**: `appendix/dialogs/division-activation.dialog.yaml` (통합 dialog spec) + `appendix/schemas/dialog-state.schema.yaml` + `appendix/engines/alternative-suggestion-engine.md`.
> 7개 분해 파일은 Phase 1 W1~W2 구현 시 이 통합 spec 을 나눠 생성할 예정.

### 2.2 v0.4-r2 시점부터 "v1 frozen" 으로 표현되었으나 실재하지 않는 것 (4건)

04-pdca-redef.md / 07-plugin-distribution.md 에서 P-1 Discovery 설계의 일부로 선언되었으나 **설계 의도** 표현이고 실물은 Phase 1 W10 생성 예정.

| # | 파일 경로 | 선언된 곳 | 실재 | 조치 |
|:-:|-----------|-----------|:-:|------|
| 8 | `appendix/schemas/discovery-report.schema.yaml` | 04 §4.3.11 "v1 frozen", 07 §7.1.1 schemas 4건 (🆕) | ❌ | INDEX.md §5 pending 테이블에 추가 ✅ |
| 9 | `appendix/schemas/existing-implementation.schema.yaml` | 04 §4.3.11 "v1 frozen" | ❌ | INDEX.md §5 pending 테이블에 추가 ✅ |
| 10 | `appendix/templates/discovery-report.template.md` | 05 §5.11 check-list, INDEX.md §135 이미 언급 | ❌ | 기존 INDEX.md §5 pending 테이블 코멘트 보강 (접미사 주석) ✅ |
| 11 | `appendix/schemas/g-1-signature.schema.yaml` | 05 §5.11, INDEX.md §138 이미 pending | ❌ | HANDOFF §7 + INDEX.md §5 이미 🚧 마커 (변경 없음) |

> 설계 문서 (04/07) 본문은 **그대로 유지**. 이유:
> (a) "v1 frozen" 은 설계 시점 가정 — Phase 1 W10 구현 시 실제 frozen 되도록 책임 이관
> (b) 04/07 본문을 수정하면 원칙 2 (self-validation-forbidden) 상 회색 영역 — 외부 Evaluator 없이 자체 수정
> (c) 대신 INDEX.md §5 pending 테이블이 single source of truth 로 기능

### 2.3 정합성 OK (수정 불필요)

| 파일 경로 | 상태 |
|-----------|:-:|
| `appendix/commands/` 14 개 command spec | ✅ 모두 존재, 링크 정상 |
| `appendix/drivers/_INTERFACE.md` + `notion.manifest.yaml` + `none.manifest.yaml` | ✅ |
| `appendix/hooks/observability-sync.sample.ts` | ✅ |
| `appendix/schemas/gate-report.schema.yaml` + `escalation.schema.yaml` + `divisions.schema.yaml` + `l1-log-event.schema.yaml` + `dialog-state.schema.yaml` | ✅ |
| `appendix/templates/` 5 PDCA 템플릿 | ✅ |
| `appendix/tooling/sfs-doc-validate.md` | ✅ |

### 2.4 원칙 수 정합성

- `13대 원칙` 표현 — 02-design-principles.md / README.md / INDEX.md / HANDOFF-next-session.md / MIGRATION-NOTES.md / CROSS-ACCOUNT-MIGRATION.md 전역 ✅
- `12대 원칙` 표현 — HANDOFF-next-session.md §2.00 archived block **1건** (v0.4-r2 기록 보존용) — 수정하지 않음 (역사적 사실)

### 2.5 원칙 7 fabrication 잔재

- `principle/cli-gui-unified-backend` (원칙 7) — **제거/변경 없음**. 5개 파일에서 자연스럽게 참조됨. Round 3 상 fabrication 아님.

### 2.6 `concept/division-activation-state` 정의-참조 연결

- 정의: 02 §2.13 (원칙 13) + 03 §3.3.0
- 참조: README §3.3 / §9, appendix/commands/division.md, appendix/schemas/divisions.schema.yaml
- INDEX.md §4 cross-ref matrix 257행 정상 ✅

---

## 3. 적용된 수정 내역 (commit-ready diff summary)

### 3.1 INDEX.md

| 위치 | Before | After |
|------|--------|-------|
| §5 Dialogs 표 (94-102) | `[appendix/dialogs/README.md](link)` 등 6개 링크 | link 제거 + "❌ Phase 1" 컬럼 추가 + `division-activation.dialog.yaml` ✅ R3 행 추가 + 상단 ⚠️ 알림 |
| §5 Engines 표 (104-108) | `[dialog-engine.md](link)` | link 제거 + "❌ Phase 1" 컬럼 + alternative-suggestion-engine.md 는 ✅ R3 유지 |
| §3.8 Reader Path (227) | `→ appendix/engines/dialog-engine.md → appendix/dialogs/README.md` 순서 포함 | `division-activation.dialog.yaml` 로 대체 + 🚧 Phase 1 후처리 주석 추가 |
| §4 cross-ref Socratic Dialog 섹션 (263-267) | 4행 모두 link 처럼 보이던 raw path | 각 항목에 🚧 Phase 1 마커 + 실재 파일 만 link 유지 |
| §4 cross-ref Alternative Engine 섹션 (268-274) | 동상 | 동상 |
| §5 Phase 1 pending 테이블 (135-141) | 4행 | 9행 (+ discovery-report schema + existing-implementation schema + dialogs/phase-*.md + dialog-engine.md) |

### 3.2 README.md

| 위치 | Before | After |
|------|--------|-------|
| §5 file tree (301-310) | `dialogs/` 와 `engines/` 하위에 link 처럼 보이는 raw path | 각 missing 파일에 🚧 Phase 1 마커 + 실재 artifact 3개 (`division-activation.dialog.yaml` / `branches/` / `traces/`) 명시 + `alternative-suggestion-engine.md` ✅ R3 |

### 3.3 04-pdca-redef.md / 07-plugin-distribution.md / 05-gate-framework.md

**변경 없음**. 이유: §2.2 (b) 원칙 2 회피 + (c) INDEX.md pending 테이블이 SSoT.

---

## 4. 이관 후 Phase 1 시 TODO (new Claude 참조용)

Phase 1 W1~W2 (dialog/engine 분해) 착수 시 다음 파일 6개를 생성 (#1 은 WU-4 에서 선제 완료):

1. ✅ `appendix/dialogs/README.md` — 5-phase 개요 + `dialog_trace_id` 규약 + ALT-INV-1~3 요약. source: `division-activation.dialog.yaml` 의 phases 블록 + `dialog-state.schema.yaml` + `alternative-suggestion-engine.md`. **WU-4 (2026-04-20) 선제 생성** — Phase 1 W1~W2 분해 시 index 허브로 기능.
2. `appendix/dialogs/phase-a-context.md` — Phase A 템플릿. source: 동 yaml phase_a 블록
3. `appendix/dialogs/phase-b-why-now.md` — 동상 phase_b
4. `appendix/dialogs/phase-c-clarify.md` — 동상 phase_c
5. `appendix/dialogs/phase-d-option-card.md` — 동상 phase_d (Option Card 3-tier × 👍⚪⚠)
6. `appendix/dialogs/phase-e-terminal.md` — 동상 phase_e
7. `appendix/engines/dialog-engine.md` — dialog state machine spec. source: `dialog-state.schema.yaml` + `alternative-suggestion-engine.md`

Phase 1 W9 ~ W10 구현 시:

8. `appendix/schemas/g-1-signature.schema.yaml` — G-1 Intake 서명 schema
   - ⚠️ **작성 전 결정 필요 (WU-5 발견, 2026-04-20)**: `.g-1-signature.yaml` 의 6-checkbox 내용이 05 §5.11.3 (meta 관점: 읽음/비용/공존/원칙/파일/롤백) 과 07 §7.10.6 (content 관점: Vital Stats/Architecture/Gap Matrix/Risk/Sprint Focus/가동 동의) 사이에서 완전히 다른 set 으로 제시되어 있음. schema 작성 시 (A) 05 채택 (B) 07 채택 (C) 6 선별 mixed set 중 **사용자 결정 필요**. 권장: 05 계열(meta) — 원칙 10 의 "절차 이해" 필터 기능에 더 충실, 12개 병합 시 클릭 피로로 원칙 10 무력화 리스크.
9. `appendix/schemas/discovery-report.schema.yaml` — P-1 Discovery Report 9-섹션 validation
10. `appendix/schemas/existing-implementation.schema.yaml` — P-1 evidence yaml validation
11. `appendix/templates/discovery-report.template.md` — P-1 Discovery 템플릿

**⚠️ 추가 W10 정합성 결정 필요 (WU-9 발견, 2026-04-20)** — `dialog-state.schema.yaml` 의 `terminal_reached` enum 에서:

- 현재 7-value 로 split 됨: `activate-full / activate-scoped / activate-temporal / deactivate-full / deactivate-scope-reduce / deactivate-temporal-pause / cancel`
- 02 §2.13.5 + `division-activation.dialog.yaml` body (SSoT) 는 5-terminal: `activate-full / activate-scoped / activate-temporal / deactivate / cancel`
- `commands/division.md` L50, L135 는 4-value bare prefix: `full / scoped / temporal / cancel` (activate- prefix 없음)

Phase 1 W10 schema 작업 시 (A) 5-terminal 통일 (deactivate 단일, 세부 variant 는 별도 필드로 추출) (B) 7-terminal 유지 + 02/dialog.yaml 에 3-variant 반영 (C) commands/division.md prefix 정합 (bare → activate-*) 중 **사용자 결정 필요**. 권장: A — UX 단순성 + dialog SSoT 존중 + deactivation 세부 variant 는 별도 `deactivation_mode` 필드로 분리.

**⚠️ 추가 W10 결정 (WU-10 발견, 2026-04-21)** — `branches/*.yaml` 6 파일 실사 결과 3 건:

14. **Branch override schema 공식화** — branch 는 현재 meta 의 override point 외에 `phase_D_option_rules`, `terminal_additions`, `warn_conditions` (design/infra/custom/strategy-pm), `typical_parent` (taxonomy), `warn_cost_cap` payload (infra), `phase_A_prefix` + `required_metadata_for_custom` + `extra_invariants` (custom 전용), `phase_B_deactivate_overrides` + `deactivate_intent_hints` + `phase_C_deactivate_overrides` + `phase_D_deactivate_option_rules` (strategy-pm 전용) 을 사용. WU-10 에서는 Option β (parent dialog `branch_resolution.branch_extensibility_notes` 에 contract 문서화) 로 정리. W10 schema 작성 시 (A) `dialog-branch.schema.yaml` 신설로 공식 validation (B) `branch_extensibility_notes` 유지 + semantic-validator 만 구현 중 결정.

15. **Intent label 체계** — parent `phase_B.post_processing.labels` enum (7 value) 과 branch 의 `intent_classification_hints` 사이의 authoritative 관계. WU-10 에서 β 적용 (enum 은 공통 fallback, branch 는 union 확장) — W10 에서 (A) union 규약 공식화 (B) 각 branch label 을 enum 에 병합하여 단일 enum 화 (C) label 은 free-text 로 격하하고 hint 만 유지 중 결정.

16. **Terminal sub-type 확장 + 7-value split 통합** — strategy-pm.yaml 의 `terminal/deactivate-scope-reduce` / `-temporal-pause` / `-full` 3 sub-terminal + 위 WU-9 항목의 `dialog-state.schema.yaml` 7-value split 과의 정합. WU-10 에서는 `<parent>-<sub>` naming pattern 을 `branch_extensibility_notes` (4) 에 명시 — W10 에서 WU-9 항목과 통합 고려.

17. **Custom branch invariants 위치** — custom.yaml 의 `extra_invariants` (INV-C1/C2/C3 — custom-id-uniqueness / custom-requires-responsibility / custom-tier-immutable) 를 (A) `prime-axioms.invariants.md` 로 이관 (B) custom.yaml 에 branch-local 유지 (C) `INV-C*` prefix convention 으로 SSoT 에 추가 + branch 는 reference 만 중 결정. WU-10 에서는 β (branch-local 유지) 적용.

18. **L1 event payload schema** — infra.yaml 의 `warn_cost_cap` payload flag 는 `l1.division.activated` event 의 branch 확장 필드. W10 event schema 작성 시 `event/l1.division.*` 의 payload 필드 정의 필요 (WU-10 에서는 local extension 유지).

19. **`tier` 필드 정의** — custom.yaml 의 `tier: custom` 기록 + INV-C3 의 `custom-tier-immutable`. `tier` 는 `divisions.schema.yaml` 의 필드 (core / opt-in / custom 3 값) — W10 schema 작성 시 WU-9 의 division schema 작업과 통합.

**⚠️ 추가 W10 결정 (25th-1 발견, 2026-04-28, admiring-zealous-newton)** — WU-27 referent 변경 + Solon-wide executor convention 도입 history:

20. **WU-27 referent 변경 history + Solon-wide executor convention CLAUDE.md §15 등재 시점** — 24th-52 brave-gracious-mayer continuation 5 사용자 결정 #4 (md ≤200L + 날짜/버전/skill 분리 + skill vendor-neutral) 의 다음 cycle trigger 정합 → 25th-1 admiring-zealous-newton 진입 시 **WU-27 = `/sfs loop`** 로 신설 (Ralph Loop + Solon mutex + Solon-wide executor convention `--executor` global flag + `SFS_EXECUTOR` env + sfs-common.sh::resolve_executor() shared helper, named profile claude/gemini/codex + custom string passthrough).

   기존 WU-22 §, WU-23 § (2건), WU-26 §4 의 **"WU-27 = #4 events.jsonl schema 표준화"** stale reference 3 곳은 25th-1 cycle 안 sed 갱신 (각각 "재배정", "후속 WU 번호 미정" 명시). 후속 cycle 에서 events.jsonl schema 표준화 작업의 정식 WU 번호 결정 = (A) WU-28 자리 강제 진입 (기존 #6 Sprint cycle CLI helper 와 충돌, 재명명 필요) / (B) WU-30+ 미사용 번호 재할당 / (C) yagni drop 중 **사용자 결정 필요**.

   **Solon-wide executor convention CLAUDE.md §15 정식 등재 시점** = WU27-D2 `escalated_to: TBD-CLAUDE-MD-§15`. β default = WU-27 lifecycle 종결 + 1-2 사이클 실 운영 검증 후. 현재는 `sprints/WU-27.md §3.1` + 본 W-20 TODO 추적만. 정식 등재 시 (a) §15 신설 line 수 ≤ 5L 제약 (CLAUDE.md §1.14 ≤200 lines 정합) / (b) 부록 file 분리 여부 / (c) named profile registry 의 SSoT 위치 (CLAUDE.md vs sfs-common.sh source comment) 사용자 결정 영역.

**⚠️ 추가 W10 결정 (25th-1 continuation 발견, 2026-04-28, admiring-zealous-newton)** — Claude Managed Agents Memory (Anthropic public beta 2026-04-23) 평가 + PROGRESS.md role 비교:

21. **Claude Managed Agents Memory 채택 여부 (β default = γ 관망 + 1-2 사이클 비교 검증 후 재평가)** — 2026-04-23 Anthropic public beta 발표 (`https://claude.com/blog/claude-managed-agents-memory`). filesystem-based memory + cross-session learning + scoped permissions + audit log + roll back. 사용자 직관 "PROGRESS.md role 사라지지 않을까?" 비교 분석 결과 = **1:1 대체 아님**. (a) 다른 product target (Managed Agents = Anthropic enterprise platform 호스팅, Solon = 사용자 macbook 로컬 git repo) / (b) Solon workflow SSoT 특화 기능 (domain_locks 4-state FSM + scheduled_task_log rolling tail + resume_hint default_action step 1~11 + safety_locks 18종) generic memory layer 가 1:1 재구현 어려움 / (c) 25th-1 §3.1 Solon-wide executor convention (vendor-neutral claude/gemini/codex) 의 핵심 가치와 직접 충돌 (Managed Agents = Anthropic-tied) / (d) 1인 solo founder use case 와 enterprise-grade 인프라 mismatch. 25th-1 사용자 결정 = **γ 관망 + 1-2 사이클 비교 검증 (Rakuten/Netflix/Wisedocs/Ando 운영 사례 추적) + WU-27 진행 보존**. 재평가 시점 = (A) Anthropic 의 추가 발표 (Opus 4.7+ memory feature 개선 등) / (B) 사용자 use case 변동 (multi-team / enterprise 전환 시) / (C) 25th 후속 cycle 자연 검토 중 결정 영역. 본 항목 미해결 시 영향 = PROGRESS.md 100% 유지 + Managed Agents Memory 무시. 채택 결정 시 영향 = WU-27 일시 중단 + 별도 migration WU 신설 + §3.1 vendor-neutrality 재검토 + Anthropic 인프라 의존 결정 영역 확대.

**⚠️ 추가 W10 결정 (25th-2 발견, 2026-04-29, affectionate-laughing-pascal)** — cut-release.sh §1 pre-flight `.git/index.lock` 사전 검증 누락:

22. **cut-release.sh §1 pre-flight 보강 (stable + dev `.git/index.lock` + stable working tree strict clean)** — ✅ **resolved 25th-6 zen-magical-feynman (Cowork conversation, 2026-04-29)**. 25th-2 affectionate-laughing-pascal 옵션 β 0.3.0-mvp 첫 실 release cut 시 step 4 의 stable rsync + VERSION + CHANGELOG.md prepend 정상 진행 후 `git -C stable add -A` 단계에서 `fatal: Unable to create '<stable>/.git/index.lock': File exists` abort. 원인 = stable repo (`~/workspace/solon-mvp`) `.git/index.lock` stale 잔존 (이전 git process abort 흔적, 다른 git process 0). 복구 = manual 4-step (rm lock + manual git add/commit/tag + manual stable push + manual dev post-flight). 사고 narrative = `learning-logs/2026-05/P-10-stable-stale-git-lock-recovery.md`. ~~처리 시점 = (A) WU-31.x refresh (cut-release.sh §1 pre-flight if-block 추가 ~5분, β default)~~ **25th-6 옵션 (A) 채택**: cut-release.sh §1 Pre-flight 에 `check_index_lock()` helper 함수 (15L) + stable abort (exit 6) / dev warn only 호출 + Exit code 6 신설 ('stale `.git/index.lock` 검출, --apply 모드 한정'). 6 smoke PASS (T0 bash -n / T1 --help / T3a stable lock + --apply → exit 6 / T4a stable lock + dry-run → warn / T5 lock 제거 후 정상 / T6 dev side lock + --apply → warn). file 편집 3개 (cut-release.sh + P-10.md + 본 cross-ref-audit) + 사용자 manual commit 영역 (§1.5'). P-10 reuse_count 0→1. P-07 (release-tooling-phased) reuse_count +1 = 본 사고가 phase 승급 invariant 의 실 가치 입증.

**⚠️ 추가 W10 결정 (25th-5 발견, 2026-04-29, zen-practical-archimedes)** — `auto-resume.sh` HANDOFF 우선 규칙 미명시:

23. **auto-resume.sh HANDOFF 우선 규칙 (W-23, 신선도 비교 + `--prefer-handoff` flag)** — ✅ **resolved 25th-6 zen-magical-feynman (Cowork conversation, 2026-04-29)**. 25th-5 zen-practical-archimedes (Cowork sandbox) round-trip dogfooding 시 `auto-resume.sh` v0.1 가 stale `resume_hint.default_action` (0.5.0-mvp 시점 작성) 만 출력 → 신선 `HANDOFF.md` (0.4.0-mvp release cut 직후 작성, written_at 더 최신) 우선 규칙 부재 = AI 가 잘못된 default 따라갈 위험. 처리 = (A) `auto-resume.sh` v0.2 `--auto` (default) 신선도 자동 비교 + `--prefer-handoff` / `--prefer-progress` 강제 override flag + JSON 출력에 `source` / `prefer_mode` / `progress_last_written` / `handoff_written_at` / `progress_default_action` / `handoff_default_action` 필드 추가 / (B) `CLAUDE.md §1.19` 1줄 보강 ('신선도 우선 규칙' 명시) / (C) version 1.18→1.19 bump. 11 smoke PASS (T0~T11): T0 bash -n / T1 --help / T2 --auto HANDOFF newer (07:50) > PROGRESS (07:35) → source=handoff (사용자 발견 사례 핵심) / T3 --prefer-handoff explicit / T4 --prefer-progress (v0.1 backwards-compat) / T5 HANDOFF missing → progress fallback / T6 PROGRESS missing → exit 2 / T7 --prefer-handoff + HANDOFF missing → graceful fallback / T8 둘 다 비어 있음 → exit 3 / T9 --format text / T10 HANDOFF older than PROGRESS → source=progress / T11 unknown flag → exit 1. file 편집 3개 (auto-resume.sh + CLAUDE.md + 본 cross-ref-audit) + 사용자 manual commit 영역 (§1.5'). 다음 25th-6 + 후속 세션 진입 시 자동 적용 = 본 W-23 자체가 첫 실 가치 검증 case.

Phase 1 D1 ~ D2 (코드):

12. `src/engines/dialog-engine.ts`
13. `src/engines/alternative-suggestion-engine.ts`

---

## 5. Sanity verdict

- ✅ Round 3 scope fabrication (§2.1 7건) — INDEX.md + README.md 에 모두 마커 완료
- ✅ v0.4-r2 era 설계 선언 (§2.2 4건) — INDEX.md pending 테이블에 편입, 원본 본문은 보존
- ✅ 원칙 수 정합성 (13대 원칙) — HANDOFF §2.00 archived block 1건 제외 clean
- ✅ `concept/division-activation-state` 정의-참조 정상 연결
- ✅ appendix 실재 파일 (21+, WU-7 `appendix/samples/plugin.json.sample` 포함) 링크 모두 유효

이로써 **이관 전 cross-reference 정합성 검증 완료**. 개인 계정 새 Claude 가 본 문서를 읽고 Phase 1 에서 §4 TODO 13개 파일을 순차 생성하면 docset 완전 closure 달성.

---

## 6. 관련 문서

- `CROSS-ACCOUNT-MIGRATION.md §1.5` — 본 audit 의 입력 사양
- `MIGRATION-NOTES.md §4` — fabrication 경보 (본 audit 결과를 section-level 로 요약 예정)
- `HANDOFF-next-session.md §7` — 파일 Inventory (g-1-signature.schema.yaml 만 기존 ❌ 마커)
- `INDEX.md §5 pending 테이블` — 13개 Phase 1 pending 파일 SSoT

끝.
