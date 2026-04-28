---
doc_id: sfs-v0.4-review-2026-04-29-contradiction-sweep
title: "2026-04-29 Review — v0.4-r4 모순 전수검사"
status: draft
created: 2026-04-29
visibility: raw-internal
source_thread: "Codex user-active conversation"
related_docs:
  - "../../00-intro.md"
  - "../../02-design-principles.md"
  - "../../03-c-level-matrix.md"
  - "../../05-gate-framework.md"
  - "../../08-observability.md"
  - "../../10-phase1-implementation.md"
  - "../../gates.md"
  - "../commands/plan.md"
  - "../commands/act.md"
  - "../commands/retro.md"
  - "../commands/escalate.md"
---

# 2026-04-29 Review — v0.4-r4 모순 전수검사

## 1. 목적

사용자가 "모순이 발생하진 않는지 전수검사"를 요청했다. 본 문서는 2026-04-28 foundation hardening 이후 docset 전체를 대상으로 확인한 모순 후보, 실제 수정, 남은 예외를 기록한다.

## 2. 검사 범위

검사 대상은 다음 두 층으로 나눴다.

1. **현재 스펙으로 읽히는 문서**: `00~10`, `README`, `INDEX`, `gates.md`, `appendix/commands`, `appendix/schemas`, `appendix/templates`, `phase1-mvp-templates`, `solon-mvp-dist`.
2. **역사/운영 로그 문서**: `WORK-LOG`, `PROGRESS`, `sessions`, `sprints`, `MIGRATION-NOTES`, `CROSS-ACCOUNT-MIGRATION`, `cross-ref-audit`, `learning-logs`.

역사/운영 로그 문서의 `v0.4-r3`, `G1~G5`, `15~19주` 표현은 당시 사실을 기록한 것이므로 자동 수정 대상에서 제외했다. 현재 스펙 문서 안에서 같은 표현이 현재 계약처럼 보이는 경우만 수정했다.

## 3. 발견 및 수정

### A. Gate vocabulary drift

일부 현재 문서가 여전히 `G-1 + G1~G5` 또는 `7 gate`를 전체 Gate 집합처럼 설명했다.

수정:
- `00-intro.md`: 프로세스를 `G-1/G0/G1~G5/RELEASE Gate vocabulary`로 정정.
- `02-design-principles.md`: 원칙 1의 공통 frame을 `G-1/G0/G1~G5/RELEASE`로 정정.
- `gates.md`: 7 gate enum에서 8 gate vocabulary로 확장하고, `/sfs review --gate`는 WU-25 구현 contract 때문에 7개만 허용한다는 예외를 명시.
- `10-phase1-implementation.md`: production open 시 Release Readiness 조건부 적용으로 정리.

판단:
`RELEASE`는 schema와 §5 vocabulary에는 있어야 하지만, 사용자-facing command surface는 아직 미결이다. 따라서 `gates.md`가 "vocabulary는 8개, 현재 review CLI enum은 7개"라고 분리하는 것이 가장 모순이 적다.

### B. Division id drift

현재 division id는 `strategy-pm`, `qa`인데 일부 문서가 `strategy/pm`, `quality/qa`, "PM 본부"를 현재 id처럼 사용했다.

수정:
- `05-gate-framework.md`: operator/evaluator table의 `strategy/pm`, `quality/qa`를 `strategy-pm`, `qa`로 정정.
- `06-escalate-plan.md`: conflict 예시와 escalation schema 예시를 `strategy-pm`, `qa`로 정정.
- `appendix/commands/plan.md`, `act.md`, `retro.md`, `escalate.md`, `check.md`, `README.md`: operator id 정합화.
- `09-differentiation.md`: division mapping을 `division/strategy-pm`, `division/qa`로 정정.

판단:
`division/pm -> division/strategy-pm` 같은 rename 설명은 역사로 남겨도 된다. 하지만 operator field, schema 예시, command spec 안에서는 새 id만 써야 한다.

### C. L3 default drift

v0.4-r4 기준 Phase 1 default L3 driver는 `none`이다. 그런데 일부 현재 문서가 `L3 Notion`을 기본값처럼 말했다.

수정:
- `08-observability.md`: Phase 1 default를 `none`으로 정정하고, Notion은 optional driver로 설명.
- `05-gate-framework.md`, `06-escalate-plan.md`, `07-plugin-distribution.md`, `09-differentiation.md`, `10-phase1-implementation.md`: `L3 Notion dashboard` 표현을 `L3 driver view` 또는 `local report` 포함 표현으로 정정.

판단:
Notion은 L3 구현체 중 하나다. 현재 구조에서는 Git/L2가 SSoT이고, Notion은 사람이 보는 외부 view일 뿐이다.

### D. Phase 1 기간/성공 기준 drift

일부 문서가 `15~19주`, `6 본부 x 5 Gate`, `Phase 1 active >= 4`처럼 r2/r3 기준을 현재 기준처럼 보이게 했다.

수정:
- `03-c-level-matrix.md`: 16~20주 + 기본 2 active + 최소 1 abstract 승격으로 정정.
- `10-phase1-implementation.md`: 성공 기준을 1~6 필수 + 7 Release Readiness 조건부로 명시.
- `09-differentiation.md`: active 본부 목표를 `dev + strategy-pm + 최소 1개 abstract 승격`으로 정정.

판단:
Phase 1은 모든 본부를 처음부터 fully active로 여는 설계가 아니다. 원칙 13 때문에 "기본 2 active + 필요 시 승격"이 현재 SSoT다.

### E. CLAUDE.md docset version drift

운영 SSoT인 `CLAUDE.md` 의 제목과 프로젝트 정체성이 `Solon v0.4-r3` 로 남아 있었다.

수정:
- `CLAUDE.md`: title / updated / §2 프로젝트 정체성을 `v0.4-r4` 로 정정. line count 는 170 lines 로 §1.14의 200 line 제한을 유지한다.

### F. Template link false positives

Markdown link 검사에서 `appendix/templates/report.md`의 예시 링크가 실제 파일 없음으로 잡혔다.

수정:
- 예시 링크를 markdown link가 아니라 code path로 바꿨다. Template placeholder가 broken link로 오해되는 것을 방지한다.

## 4. 검증 결과

실행한 검사:

- `git diff --check`: PASS
- command file count: `appendix/commands/*.md = 14` (README 1 + slash command 13)
- active spec grep: `strategy/pm`, `quality/qa`, `docset version: v0.4-r3`, `14개 command`, `Phase 1 default=notion`, `L3 Notion 대시보드` 등 현재 스펙 충돌 패턴 0건
- markdown link scan: 138개 md 파일 확인, broken link 5건

남은 broken link 5건은 현재 스펙 모순이 아니라 아래 유형이다.

1. `PROGRESS.md -> 2026-04-25-admiring-nice-faraday.md`: 운영 로그의 상대 링크 경로 문제.
2. `cross-ref-audit.md -> link` 2건: 감사 템플릿 placeholder.
3. `appendix/tooling/sfs-doc-validate.md -> {s06#anchor}`: validator 문서의 placeholder.
4. `learning-logs/... -> ./<file>.md`: 템플릿성 예시.

## 5. 남은 설계 결정

모순은 아니지만 아직 의사결정이 열린 항목:

1. Release Readiness command surface: `/sfs check --release-readiness` vs `/sfs release`.
2. GateReport schema의 release-blocker 전용 필드 추가 여부.
3. Historical docs의 r3 표현을 그대로 둘지, 문서 상단에 "historical snapshot" 주석을 일괄 추가할지.

## 6. Claude agent 에게 주는 판단 기준

반박하려면 다음을 구분해야 한다.

- 현재 스펙 문서의 drift인가?
- 역사 로그/마이그레이션 기록의 당시 사실인가?
- command 구현 contract 인가?
- schema/vocabulary contract 인가?

특히 `gates.md`의 "vocabulary 8개 vs `/sfs review --gate` 7개"는 모순이 아니라 command surface 미결에 따른 의도적 분리다.
